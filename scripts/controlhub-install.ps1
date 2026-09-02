[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ControlHubIp
)

$ErrorActionPreference = 'Stop'

function Invoke-Native([scriptblock]$Command, [string]$FailureMessage) {
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw $FailureMessage
    }
}

function Wait-ForAdbDevice([string]$Adb, [string]$Target, [int]$TimeoutSeconds = 20) {
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    $lastState = 'unavailable'

    do {
        # PowerShell 7 can turn adb's expected offline stderr response into a
        # terminating NativeCommandError when ErrorActionPreference is Stop.
        $savedNativeErrorPreference = $PSNativeCommandUseErrorActionPreference
        try {
            $PSNativeCommandUseErrorActionPreference = $false
            $stateOutput = & $Adb -s $Target get-state 2>&1
            $stateExitCode = $LASTEXITCODE
        }
        finally {
            $PSNativeCommandUseErrorActionPreference = $savedNativeErrorPreference
        }
        $lastState = ([string]($stateOutput | Select-Object -Last 1)).Trim()
        if ($stateExitCode -eq 0 -and $lastState -eq 'device') {
            return
        }
        Start-Sleep -Seconds 1
    } while ((Get-Date) -lt $deadline)

    throw "Control Hub $Target did not become ready within $TimeoutSeconds seconds (ADB state: $lastState). Verify it is powered on and connected to the same network."
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$adbFromSdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
$adb = if (Test-Path $adbFromSdk) { $adbFromSdk } else { (Get-Command adb -ErrorAction Stop).Source }
$adbTarget = "${ControlHubIp}:5555"
$gradleWrapper = Join-Path $projectRoot 'gradlew.bat'
$apkPath = Join-Path $projectRoot 'TeamCode\build\outputs\apk\debug\TeamCode-debug.apk'

Write-Host "Connecting to Control Hub at $adbTarget..." -ForegroundColor Cyan
# Remove a stale TCP transport before reconnecting. `adb connect` otherwise
# reports “already connected” even when that transport is offline.
& $adb disconnect $adbTarget | Out-Null
Invoke-Native { & $adb connect $adbTarget } "Could not connect to $adbTarget. Confirm the hub is on and wireless ADB is enabled."
Wait-ForAdbDevice -Adb $adb -Target $adbTarget

Write-Host 'Building TeamCode debug APK...' -ForegroundColor Cyan
Push-Location $projectRoot
try {
    Invoke-Native { & $gradleWrapper ':TeamCode:assembleDebug' '--console=plain' } 'Gradle could not build the TeamCode debug APK.'
}
finally {
    Pop-Location
}

if (-not (Test-Path $apkPath)) {
    throw "Gradle completed but the expected APK was not found: $apkPath"
}

Write-Host "Installing on $adbTarget..." -ForegroundColor Cyan
Invoke-Native { & $adb -s $adbTarget install -r $apkPath } 'APK installation failed.'
Write-Host 'OTA deployment complete.' -ForegroundColor Green
