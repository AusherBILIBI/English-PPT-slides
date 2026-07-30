param(
    [switch]$Help,
    [string]$Pptx,
    [string]$QaDir,
    [int]$ExpectedSlides,
    [string]$LayoutDir,
    [switch]$AllowZeroReveal,
    [switch]$SkipAnimationReport,
    [switch]$CheckFreshness
)

$ErrorActionPreference = "Stop"

if ($Help) {
@"
SYNOPSIS
  Verify English courseware PPTX QA reports against the final PPTX.

USAGE
  powershell -ExecutionPolicy Bypass -File verify-ppt-qa.ps1 -Pptx deck.pptx -QaDir qa
  powershell -ExecutionPolicy Bypass -File verify-ppt-qa.ps1 -Pptx deck.pptx -QaDir qa -ExpectedSlides 32
  powershell -ExecutionPolicy Bypass -File verify-ppt-qa.ps1 -Pptx corpus.pptx -QaDir qa -AllowZeroReveal

CHECKS
  - PPTX slide count by reading ppt/slides/slide*.xml.
  - Optional expected slide count and layout JSON count.
  - source-coverage.json missingCount/missing_count and redMissingCount/red_missing_count.
  - reveal-target-count.json revealTargets against animation-report.json animationTargets.
  - Optional freshness check for reports older than the final PPTX.
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
if ($QaDir) {
    $QaDir = (Resolve-Path -LiteralPath $QaDir).Path
}
if ($LayoutDir) {
    $LayoutDir = (Resolve-Path -LiteralPath $LayoutDir).Path
}

function Get-PptxSlideCount {
    param([string]$Path)
    Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null
    $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
    try {
        return @($zip.Entries | Where-Object { $_.FullName -match '^ppt/slides/slide[0-9]+\.xml$' }).Count
    } finally {
        $zip.Dispose()
    }
}

function Read-Json {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    $text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $text = $text.TrimStart([char]0xFEFF)
    return $text | ConvertFrom-Json
}

function Get-JsonNumber {
    param(
        [object]$Object,
        [string[]]$Names,
        [int]$Default = 0
    )
    if ($null -eq $Object) { return $Default }
    foreach ($name in $Names) {
        if ($Object.PSObject.Properties.Name -contains $name) {
            return [int]$Object.$name
        }
    }
    return $Default
}

function Assert-Equal {
    param(
        [string]$Label,
        [int]$Actual,
        [int]$Expected
    )
    if ($Actual -ne $Expected) {
        throw "$Label mismatch. Expected $Expected, got $Actual."
    }
}

function Assert-Fresh {
    param(
        [string]$ReportPath,
        [datetime]$PptxTime
    )
    if (-not $CheckFreshness) { return }
    if (-not (Test-Path -LiteralPath $ReportPath -PathType Leaf)) { return }
    $reportTime = (Get-Item -LiteralPath $ReportPath).LastWriteTime
    if ($reportTime -lt $PptxTime) {
        throw "Stale QA report: $ReportPath is older than final PPTX."
    }
}

$slideCount = Get-PptxSlideCount $Pptx
$pptxTime = (Get-Item -LiteralPath $Pptx).LastWriteTime
$summary = [ordered]@{
    pptx = $Pptx
    slideCount = $slideCount
}

if ($ExpectedSlides -gt 0) {
    Assert-Equal "Slide count" $slideCount $ExpectedSlides
    $summary.expectedSlides = $ExpectedSlides
}

if ($LayoutDir) {
    $layoutCount = @(Get-ChildItem -LiteralPath $LayoutDir -File -Filter "*.layout.json").Count
    Assert-Equal "Layout JSON count" $layoutCount $slideCount
    $summary.layoutCount = $layoutCount
}

if ($QaDir) {
    $coveragePath = Join-Path $QaDir "source-coverage.json"
    $revealPath = Join-Path $QaDir "reveal-target-count.json"
    $animationPath = Join-Path $QaDir "animation-report.json"

    Assert-Fresh $coveragePath $pptxTime
    Assert-Fresh $revealPath $pptxTime
    Assert-Fresh $animationPath $pptxTime

    $coverage = Read-Json $coveragePath
    if ($null -ne $coverage) {
        $missing = Get-JsonNumber $coverage @("missingCount", "missing_count")
        $redMissing = Get-JsonNumber $coverage @("redMissingCount", "red_missing_count")
        if ($missing -ne 0) {
            throw "Source coverage has missing items: $missing"
        }
        if ($redMissing -ne 0) {
            throw "Red source coverage has missing items: $redMissing"
        }
        $summary.sourceCoverage = "ok"
    }

    $reveal = Read-Json $revealPath
    if ($null -ne $reveal) {
        $revealTargets = Get-JsonNumber $reveal @("revealTargets", "animationTargets", "animation_targets")
        $summary.revealTargets = $revealTargets

        if ($revealTargets -eq 0) {
            if (-not $AllowZeroReveal) {
                throw "Reveal target count is zero. Use -AllowZeroReveal only for corpus/display decks."
            }
            $summary.animationReport = "zero reveal accepted"
        } elseif (-not $SkipAnimationReport) {
            $animation = Read-Json $animationPath
            if ($null -eq $animation) {
                throw "Missing animation report: $animationPath"
            }
            $animationTargets = Get-JsonNumber $animation @("animationTargets", "revealTargets", "animation_targets")
            Assert-Equal "Reveal target vs animation report" $animationTargets $revealTargets
            $summary.animationTargets = $animationTargets
        }
    }
}

($summary | ConvertTo-Json -Depth 5) | Write-Host
Write-Host "English courseware PPT QA checks passed."
