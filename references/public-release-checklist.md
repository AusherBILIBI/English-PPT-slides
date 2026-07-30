# Public Release Checklist

Use this before sharing a generated deck or the bundled skill assets outside the original private workspace.

## Gold PPT Review

Open each bundled gold PPT and inspect rendered slides, not only package XML.

- Remove private company names, logos, slogans, phone numbers, QR codes, and course-center labels.
- Remove teacher, student, parent, class, school, order, or customer-identifying information.
- Remove local filesystem paths, internal notes, generated QA labels, and "editable" or revision-only markers unless intentionally public.
- Check speaker notes, comments, slide masters, layouts, custom XML, and document properties when practical.
- Replace private brand marks with a neutral course label, public project name, or blank space.
- Confirm images are licensed or generated for public reuse.
- Confirm source text can be redistributed; if not, keep the asset private and use it only as an internal layout reference.
- Run `scripts/scrub-pptx-metadata.ps1` to remove author/company metadata from bundled PPTX files.

## Generated Deck Review

- Public deck uses public style names: `warm-study-space`, `clean-handout`, or `plain-classroom`.
- No private brand text appears in file names, titles, footer labels, notes, or image-based logos.
- No old gold-deck wording remains when the current source is different.
- No answer/explanation pages are included unless intended for the public audience.
- The deck opens in PowerPoint and exported previews match the final PPTX after all scrub edits.

## Fast Package-Text Scan

This scan catches text stored in PPTX XML. It cannot catch logos or words flattened into images.

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
$patterns = @('PRIVATE_BRAND_NAME','LOCAL_PATH_FRAGMENT','STUDENT_NAME')
Get-ChildItem -Recurse -Filter '*.pptx' | ForEach-Object {
  $zip = [System.IO.Compression.ZipFile]::OpenRead($_.FullName)
  try {
    foreach ($entry in $zip.Entries) {
      if ($entry.FullName -notmatch '\.(xml|rels)$') { continue }
      $reader = [IO.StreamReader]::new($entry.Open())
      try { $text = $reader.ReadToEnd() } finally { $reader.Dispose() }
      foreach ($pattern in $patterns) {
        if ($text -match [regex]::Escape($pattern)) {
          [pscustomobject]@{ File = $_.FullName; Pattern = $pattern; Entry = $entry.FullName }
        }
      }
    }
  } finally {
    $zip.Dispose()
  }
}
```
