param(
    [switch]$Help,
    [string]$Pptx,
    [string]$Report,
    [string]$BackupDir,
    [double]$MinTop = 200,
    [double]$Duration = 0.35,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if ($Help) {
@"
SYNOPSIS
  Apply simple Fade / On Click reveal animations to red answer shapes in an English courseware PPTX.

USAGE
  powershell -ExecutionPolicy Bypass -File apply-reveal-animations.ps1 -Pptx deck.pptx
  powershell -ExecutionPolicy Bypass -File apply-reveal-animations.ps1 -Pptx deck.pptx -Report qa/animation-report.json -MinTop 220

NOTES
  - Creates a timestamped backup unless -DryRun is used.
  - Targets shapes named ans_* or shapes below -MinTop that contain red text.
  - Removes stale effects on target shapes, sorts targets by slide/top/left, renames them ans_001...
"@ | Write-Host
    exit 0
}

if (-not $Pptx) {
    throw "Missing -Pptx. Use -Help for usage."
}

$Pptx = (Resolve-Path -LiteralPath $Pptx).Path
if (-not (Test-Path -LiteralPath $Pptx -PathType Leaf)) {
    throw "PPTX not found: $Pptx"
}

if (-not $Report) {
    $Report = Join-Path (Split-Path -Parent $Pptx) "animation-report.json"
}
if (-not $BackupDir) {
    $BackupDir = Join-Path (Split-Path -Parent $Pptx) "backups"
}

function Test-RedRgb {
    param([int]$Rgb)
    $red = $Rgb -band 0xFF
    $green = ($Rgb -shr 8) -band 0xFF
    $blue = ($Rgb -shr 16) -band 0xFF
    return ($red -ge 200 -and $green -le 80 -and $blue -le 80)
}

function Get-ShapeText {
    param($Shape)
    try {
        if ($Shape.HasTextFrame -eq 0) { return "" }
        if ($Shape.TextFrame.HasText -eq 0) { return "" }
        return [string]$Shape.TextFrame.TextRange.Text
    } catch {
        return ""
    }
}

function Test-RedText {
    param($Shape)
    try {
        if ($Shape.HasTextFrame -eq 0 -or $Shape.TextFrame.HasText -eq 0) { return $false }
        $range = $Shape.TextFrame.TextRange
        try {
            if (Test-RedRgb ([int]$range.Font.Color.RGB)) { return $true }
        } catch {}

        $length = [int]$range.Length
        for ($i = 1; $i -le $length; $i++) {
            try {
                $rgb = [int]$range.Characters($i, 1).Font.Color.RGB
                if (Test-RedRgb $rgb) { return $true }
            } catch {}
        }
    } catch {}
    return $false
}

function Test-RevealTarget {
    param($Shape)
    if ($Shape.Name -like "ans_*") { return $true }
    if ([double]$Shape.Top -lt $MinTop) { return $false }
    return (Test-RedText $Shape)
}

$msoAnimEffectFade = 10
$msoAnimTriggerOnPageClick = 1
$msoAnimateLevelNone = 0

$backup = $null
if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup = Join-Path $BackupDir ("{0}_before_reveal_{1}.pptx" -f [IO.Path]::GetFileNameWithoutExtension($Pptx), $stamp)
    Copy-Item -LiteralPath $Pptx -Destination $backup -Force
}

$app = $null
$presentation = $null
try {
    $app = New-Object -ComObject PowerPoint.Application
    $app.Visible = -1
    $presentation = $app.Presentations.Open($Pptx, $false, $false, $false)

    $targets = New-Object System.Collections.Generic.List[object]
    foreach ($slide in $presentation.Slides) {
        foreach ($shape in $slide.Shapes) {
            if (Test-RevealTarget $shape) {
                $targets.Add([pscustomobject]@{
                    Slide = $slide
                    Shape = $shape
                    SlideIndex = [int]$slide.SlideIndex
                    Top = [double]$shape.Top
                    Left = [double]$shape.Left
                    Text = (Get-ShapeText $shape)
                })
            }
        }
    }

    $targetIds = @{}
    foreach ($target in $targets) {
        $targetIds[[int]$target.Shape.Id] = $true
    }

    foreach ($slide in $presentation.Slides) {
        $sequence = $slide.TimeLine.MainSequence
        for ($i = $sequence.Count; $i -ge 1; $i--) {
            try {
                $effect = $sequence.Item($i)
                if ($targetIds.ContainsKey([int]$effect.Shape.Id)) {
                    $effect.Delete()
                }
            } catch {}
        }
    }

    $ordered = $targets | Sort-Object SlideIndex, Top, Left
    $counter = 1
    $reportTargets = @()
    foreach ($target in $ordered) {
        $name = "ans_{0:D3}" -f $counter
        if (-not $DryRun) {
            $target.Shape.Name = $name
            $effect = $target.Slide.TimeLine.MainSequence.AddEffect($target.Shape, $msoAnimEffectFade, $msoAnimateLevelNone, $msoAnimTriggerOnPageClick)
            $effect.Timing.Duration = $Duration
        }

        $preview = $target.Text
        if ($preview.Length -gt 120) { $preview = $preview.Substring(0, 120) }
        $reportTargets += [pscustomobject]@{
            slide = $target.SlideIndex
            shape = $name
            effect = "Fade"
            trigger = "On Click"
            top = $target.Top
            left = $target.Left
            textPreview = $preview
        }
        $counter += 1
    }

    if (-not $DryRun) {
        $presentation.Save()
    }

    $payload = [pscustomobject]@{
        pptx = $Pptx
        backup = $backup
        dryRun = [bool]$DryRun
        minTop = $MinTop
        duration = $Duration
        animationTargets = $reportTargets.Count
        targets = $reportTargets
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Report) | Out-Null
    $payload | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Report -Encoding UTF8
    Write-Host ("Animation targets: {0}" -f $reportTargets.Count)
    Write-Host ("Report: {0}" -f $Report)
    if ($backup) { Write-Host ("Backup: {0}" -f $backup) }
} finally {
    if ($presentation -ne $null) { $presentation.Close() | Out-Null }
    if ($app -ne $null) { $app.Quit() | Out-Null }
}
