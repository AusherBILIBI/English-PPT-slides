param(
  [string]$VersionFile = "VERSION",
  [string]$OutputDirectory = ".."
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$versionPath = Join-Path $repoRoot.Path $VersionFile
if (-not (Test-Path -LiteralPath $versionPath)) {
  throw "Version file not found: $versionPath"
}

$version = (Get-Content -Raw -LiteralPath $versionPath).Trim()
if ($version -notmatch "^\d+\.\d+\.\d+$") {
  throw "Version must use MAJOR.MINOR.PATCH format. Found: $version"
}

$git = "git"
$desktopGit = Join-Path $env:LOCALAPPDATA "GitHubDesktop\app-3.6.3\resources\app\git\cmd\git.exe"
$codexGit = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\native\git\cmd\git.exe"
if (Test-Path -LiteralPath $desktopGit) {
  $git = $desktopGit
} elseif (Test-Path -LiteralPath $codexGit) {
  $git = $codexGit
}

$outDirPath = Resolve-Path -LiteralPath $OutputDirectory -ErrorAction SilentlyContinue
if (-not $outDirPath) {
  New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
  $outDirPath = Resolve-Path -LiteralPath $OutputDirectory
}

$zipPath = Join-Path $outDirPath.Path "english-courseware-ppt-v$version.zip"
if (Test-Path -LiteralPath $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}

& $git -C $repoRoot.Path archive `
  --format=zip `
  --output=$zipPath `
  --prefix="english-courseware-ppt/" `
  HEAD

if ($LASTEXITCODE -ne 0) {
  throw "git archive failed."
}

$item = Get-Item -LiteralPath $zipPath
[pscustomobject]@{
  Version = "v$version"
  Path = $item.FullName
  Bytes = $item.Length
}
