[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ControlHubIp
)

$ErrorActionPreference = 'Stop'
$adbFromSdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
$adb = if (Test-Path $adbFromSdk) { $adbFromSdk } else { (Get-Command adb -ErrorAction Stop).Source }
$adbTarget = "${ControlHubIp}:5555"

Write-Host "Connecting to Control Hub at $adbTarget..." -ForegroundColor Cyan
& $adb disconnect $adbTarget | Out-Null
& $adb connect $adbTarget
if ($LASTEXITCODE -ne 0) { throw "Could not connect to $adbTarget." }

$deadline = (Get-Date).AddSeconds(20)
$lastState = 'unavailable'
do {
    $savedNativeErrorPreference = $PSNativeCommandUseErrorActionPreference
    try {
        $PSNativeCommandUseErrorActionPreference = $false
        $stateOutput = & $adb -s $adbTarget get-state 2>&1
        $stateExitCode = $LASTEXITCODE
    }
    finally {
        $PSNativeCommandUseErrorActionPreference = $savedNativeErrorPreference
    }
    $lastState = ([string]($stateOutput | Select-Object -Last 1)).Trim()
    if ($stateExitCode -eq 0 -and $lastState -eq 'device') {
        Write-Host "Control Hub is ready: $adbTarget" -ForegroundColor Green
        exit 0
    }
    Start-Sleep -Seconds 1
} while ((Get-Date) -lt $deadline)

throw "Control Hub $adbTarget did not become ready within 20 seconds (ADB state: $lastState)."
