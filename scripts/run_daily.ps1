Param(
    [switch]$DryRun,
    [int]$MinApplyCount = 10
)

$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

if (-not (Test-Path '.venv\Scripts\python.exe')) {
    throw 'Missing virtualenv python at .venv\Scripts\python.exe. Create venv first.'
}

$python = Join-Path $repo '.venv\Scripts\python.exe'

if (-not (Test-Path '.env')) {
    throw 'Missing .env file. Copy .env.example to .env and fill keys first.'
}

if (-not (Test-Path 'profile.json')) {
    throw 'Missing profile.json. Run: python -m jobhunt profile --resume <file>'
}

$baseArgs = @('-m', 'jobhunt', 'run')
if ($DryRun) {
    $baseArgs += '--no-draft'
} else {
    $baseArgs += '--send'
}

Write-Host "Running pipeline: $python $($baseArgs -join ' ')"
& $python @baseArgs
if ($LASTEXITCODE -ne 0) {
    throw "jobhunt run failed with exit code $LASTEXITCODE"
}

# Optional check: print quick summary from tracker.
if (Test-Path 'out\tracker.csv') {
    Write-Host 'Tracker updated at out\tracker.csv'
}
