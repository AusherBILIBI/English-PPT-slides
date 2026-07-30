param(
  [string]$Root = ".",
  [string]$Author = "English Courseware PPT",
  [switch]$ReportOnly
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Set-XmlElementValue {
  param(
    [string]$Text,
    [string]$ElementName,
    [string]$Value
  )

  $escapedValue = [System.Security.SecurityElement]::Escape($Value)
  $escapedName = [regex]::Escape($ElementName)
  $pattern = "(<$escapedName(?:\s[^>]*)?>)(.*?)(</$escapedName>)"
  return [regex]::Replace(
    $Text,
    $pattern,
    {
      param($Match)
      return $Match.Groups[1].Value + $escapedValue + $Match.Groups[3].Value
    },
    [System.Text.RegularExpressions.RegexOptions]::Singleline
  )
}

function Update-PptxMetadata {
  param([System.IO.FileInfo]$File)

  $replacements = @{}

  $zip = [System.IO.Compression.ZipFile]::OpenRead($File.FullName)
  try {
    foreach ($entry in $zip.Entries) {
      if ($entry.FullName -notin @("docProps/core.xml", "docProps/app.xml")) {
        continue
      }

      $reader = [System.IO.StreamReader]::new($entry.Open())
      try {
        $text = $reader.ReadToEnd()
      } finally {
        $reader.Dispose()
      }

      $updated = $text
      if ($entry.FullName -eq "docProps/core.xml") {
        $updated = Set-XmlElementValue -Text $updated -ElementName "dc:creator" -Value $Author
        $updated = Set-XmlElementValue -Text $updated -ElementName "cp:lastModifiedBy" -Value $Author
      }
      if ($entry.FullName -eq "docProps/app.xml") {
        $updated = Set-XmlElementValue -Text $updated -ElementName "Company" -Value ""
        $updated = Set-XmlElementValue -Text $updated -ElementName "Manager" -Value ""
      }

      if ($updated -ne $text) {
        $replacements[$entry.FullName] = [System.Text.Encoding]::UTF8.GetBytes($updated)
      }
    }
  } finally {
    $zip.Dispose()
  }

  if ($replacements.Count -eq 0) {
    return $null
  }

  if ($ReportOnly) {
    return [pscustomobject]@{
      File = $File.FullName
      UpdatedEntries = ($replacements.Keys -join ", ")
      Changed = $false
    }
  }

  $tempPath = $File.FullName + ".tmp"
  if (Test-Path -LiteralPath $tempPath) {
    Remove-Item -LiteralPath $tempPath -Force
  }

  $source = [System.IO.Compression.ZipFile]::OpenRead($File.FullName)
  try {
    $target = [System.IO.Compression.ZipFile]::Open($tempPath, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
      foreach ($entry in $source.Entries) {
        $newEntry = $target.CreateEntry($entry.FullName, [System.IO.Compression.CompressionLevel]::Optimal)
        $outStream = $newEntry.Open()
        try {
          if ($replacements.ContainsKey($entry.FullName)) {
            $bytes = $replacements[$entry.FullName]
            $outStream.Write($bytes, 0, $bytes.Length)
          } else {
            $inStream = $entry.Open()
            try {
              $inStream.CopyTo($outStream)
            } finally {
              $inStream.Dispose()
            }
          }
        } finally {
          $outStream.Dispose()
        }
      }
    } finally {
      $target.Dispose()
    }
  } finally {
    $source.Dispose()
  }

  Move-Item -LiteralPath $tempPath -Destination $File.FullName -Force

  return [pscustomobject]@{
    File = $File.FullName
    UpdatedEntries = ($replacements.Keys -join ", ")
    Changed = $true
  }
}

$resolvedRoot = Resolve-Path -LiteralPath $Root
$results = Get-ChildItem -Recurse -File -Filter "*.pptx" -LiteralPath $resolvedRoot.Path |
  ForEach-Object { Update-PptxMetadata -File $_ } |
  Where-Object { $null -ne $_ }

if ($results) {
  $results | Format-Table -AutoSize
} else {
  Write-Output "No PPTX metadata changes needed."
}
