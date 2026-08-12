Param(
    [string]$TaskName = 'PWP-Jobhunt-Daily',
    [string]$Time = '08:00',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $repo 'scripts\run_daily.ps1'

if (-not (Test-Path $runner)) {
    throw "Runner script not found: $runner"
}

$actionArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$runner`""
if ($DryRun) {
    $actionArgs += ' -DryRun'
}

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $actionArgs -WorkingDirectory $repo
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At $Time
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description 'Daily jobhunt run and optional email send' -Force | Out-Null

Write-Host "Scheduled task '$TaskName' created/updated for weekdays at $Time."
Write-Host "Test now with: powershell -NoProfile -ExecutionPolicy Bypass -File scripts\\run_daily.ps1 -DryRun"
