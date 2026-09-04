[CmdletBinding()]
param(
    [switch]$SkipAndroidStudio
)

$ErrorActionPreference = 'Stop'

function Write-Step([string]$Message) {
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Invoke-ProcessWithSpinner([string]$FilePath, [string[]]$ArgumentList, [string]$Activity) {
    Write-Host "$Activity This may take several minutes on a first-time setup." -ForegroundColor Yellow

    $process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow -PassThru
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $frames = @('|', '/', '-', '\')
    $frameIndex = 0

    while (-not $process.HasExited) {
        $elapsed = $stopwatch.Elapsed.ToString('m\:ss')
        $status = "Still working [$($frames[$frameIndex % $frames.Count])] Elapsed: $elapsed"
        Write-Progress -Activity $Activity -Status $status
        Write-Host "`r  $status   " -NoNewline -ForegroundColor DarkYellow
        Start-Sleep -Seconds 1
        $frameIndex++
        $process.Refresh()
    }

    # Reload the completed process before reading its exit code. Without this,
    # PowerShell can report a blank exit code even after a successful download.
    $process.WaitForExit()
    $process.Refresh()
    $exitCode = $process.ExitCode
    $stopwatch.Stop()
    Write-Progress -Activity $Activity -Completed
    Write-Host "`r  Completed in $($stopwatch.Elapsed.ToString('m\:ss')).                    " -ForegroundColor Green

    if ($null -ne $exitCode -and $exitCode -ne 0) {
        throw "$Activity failed with exit code $exitCode."
    }
    if ($null -eq $exitCode) {
        # Android CLI's Windows launcher can finish successfully without
        # returning an exit code to Start-Process. The Gradle validation below
        # verifies the SDK installation before setup reports success.
        Write-Warning "$Activity did not report an exit code; continuing to the Gradle validation step."
    }
}

function Test-WingetPackage([string]$Id) {
    $listed = & winget list --id $Id --exact --accept-source-agreements 2>$null | Out-String
    return $LASTEXITCODE -eq 0 -and $listed -match [regex]::Escape($Id)
}

function Install-WingetPackage([string]$Id, [string]$Name) {
    if (Test-WingetPackage $Id) {
        Write-Host "$Name is already installed."
        return
    }

    Write-Step "Installing $Name"
    & winget install --id $Id --exact --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw "winget could not install $Name (package: $Id)."
    }
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget is required. Install or update App Installer from the Microsoft Store, then run this script again.'
}

Install-WingetPackage 'Git.Git' 'Git for Windows'
Install-WingetPackage 'EclipseAdoptium.Temurin.17.JDK' 'Eclipse Temurin JDK 17'
if (-not $SkipAndroidStudio) {
    Install-WingetPackage 'Google.AndroidStudio' 'Android Studio'
}

$jdkRoot = Get-ChildItem 'C:\Program Files\Eclipse Adoptium' -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^jdk-17' } |
    Sort-Object Name -Descending |
    Select-Object -First 1

if (-not $jdkRoot) {
    throw 'JDK 17 was installed but could not be located under C:\Program Files\Eclipse Adoptium.'
}

$sdkRoot = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$cmdlineTools = Join-Path $sdkRoot 'cmdline-tools\latest\bin\sdkmanager.bat'

if (-not (Test-Path $cmdlineTools)) {
    Write-Step 'Installing Android SDK command-line tools'
    Write-Host 'Downloading the Android command-line-tools package (about 156 MB). This may take several minutes, especially on a school network.' -ForegroundColor Yellow
    $repository = Invoke-WebRequest 'https://dl.google.com/android/repository/repository2-1.xml' -UseBasicParsing
    [xml]$repositoryXml = $repository.Content
    $package = $repositoryXml.SelectSingleNode("//*[local-name()='remotePackage' and @path='cmdline-tools;latest']")
    $archive = $package.SelectSingleNode(".//*[local-name()='archive'][.//*[local-name()='host-os' and text()='windows']]/*[local-name()='complete']/*[local-name()='url']")
    if (-not $archive) {
        throw 'Could not find the current Windows Android command-line-tools download.'
    }

    $downloadUrl = "https://dl.google.com/android/repository/$($archive.InnerText)"
    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('ftc-sdk-' + [guid]::NewGuid())
    $zipPath = Join-Path $tempRoot 'command-line-tools.zip'
    $extractPath = Join-Path $tempRoot 'extract'
    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
    Invoke-WebRequest $downloadUrl -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    $destination = Split-Path $cmdlineTools -Parent | Split-Path -Parent
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Move-Item (Join-Path $extractPath 'cmdline-tools\*') $destination -Force
    Remove-Item $tempRoot -Recurse -Force
}

$env:JAVA_HOME = $jdkRoot.FullName
$env:ANDROID_HOME = $sdkRoot
$env:ANDROID_SDK_ROOT = $sdkRoot
[Environment]::SetEnvironmentVariable('JAVA_HOME', $jdkRoot.FullName, 'User')
[Environment]::SetEnvironmentVariable('ANDROID_HOME', $sdkRoot, 'User')
[Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT', $sdkRoot, 'User')

Write-Step 'Installing FTC Android SDK packages'
$cmdlineToolsBin = Split-Path $cmdlineTools -Parent
$androidCli = @(
    (Join-Path $cmdlineToolsBin 'android.bat'),
    (Join-Path $cmdlineToolsBin 'android.exe'),
    (Join-Path $cmdlineToolsBin 'android')
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($androidCli) {
    # Current Android command-line tools use the Android CLI. Its package names
    # use forward slashes, unlike the old sdkmanager semicolon syntax.
    Invoke-ProcessWithSpinner -FilePath $androidCli -ArgumentList @(
        "--sdk=$sdkRoot",
        'sdk',
        'install',
        'platform-tools',
        'platforms/android-30',
        'build-tools/30.0.3',
        'ndk/21.3.6528147'
    ) -Activity 'Downloading and installing FTC Android SDK packages.'
    Write-Host 'Android CLI accepted and saved compatible SDK licenses during installation.' -ForegroundColor Green
}
else {
    # Retain compatibility with older command-line-tools releases.
    Invoke-ProcessWithSpinner -FilePath $cmdlineTools -ArgumentList @(
        "--sdk_root=$sdkRoot",
        'platform-tools',
        'platforms;android-30',
        'build-tools;30.0.3',
        'ndk;21.3.6528147'
    ) -Activity 'Downloading and installing FTC Android SDK packages.'

    Write-Step 'Accepting Android SDK licenses'
    Write-Host 'This is normally quick, but it may take a minute while the SDK checks installed packages.' -ForegroundColor Yellow
    1..100 | ForEach-Object { 'y' } | & $cmdlineTools --sdk_root=$sdkRoot --licenses
    if ($LASTEXITCODE -ne 0) {
        throw 'Android SDK license acceptance failed.'
    }
}

$localProperties = Join-Path $PSScriptRoot '..\local.properties'
$sdkPropertyPath = $sdkRoot.Replace('\', '\\')
Set-Content -Path $localProperties -Value "sdk.dir=$sdkPropertyPath" -Encoding ascii

Write-Step 'Validating the TeamCode Gradle project'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$gradleWrapper = Join-Path $projectRoot 'gradlew.bat'
Push-Location $projectRoot
try {
    # Compile without installing: this downloads dependencies and verifies the
    # TeamCode Android source set.
    & $gradleWrapper ':TeamCode:compileDebugJavaWithJavac' '--console=plain'
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`nSetup troubleshooting:" -ForegroundColor Yellow
        Write-Host '  If the compiler says "package com.qualcomm... does not exist", the FTC SDK Java libraries were not available to Gradle.' -ForegroundColor Yellow
        Write-Host '  This is not an Android SDK installation error. Check that this computer can access the internet, then run this setup task again.' -ForegroundColor Yellow
        Write-Host '  If it fails again, copy the first Gradle error above that starts with "Could not resolve" or "Could not GET"; it identifies the blocked download.' -ForegroundColor Yellow
        throw 'Gradle could not compile TeamCode. Resolve the error above, then run the setup script again.'
    }
}
finally {
    Pop-Location
}

Write-Host "`nSetup complete. Open the repository root in Android Studio, then sync the Gradle project." -ForegroundColor Green
Write-Host '  C:\code\FTC-FALL-2026-34258'
Write-Host 'Restart VS Code so the new Java and Android SDK environment variables are available to its terminals and tasks.'
Write-Host 'To install to a connected Control Hub or Robot Controller, run:'
Write-Host '  .\gradlew.bat :TeamCode:installDebug --console=plain'
