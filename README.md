# FTC Robot Base

This repository is set up as a standard FTC Android Studio project for a REV Control Hub using the official `FtcRobotController` / `TeamCode` module layout.

The scaffold was imported from the official `FIRST-Tech-Challenge/FtcRobotController` project at upstream commit `26cd1fdd2a3c4b26173d9ff33a3279c27d1c7ad1`, which corresponds to FTC SDK `11.2.1` for the 2025-2026 DECODE season.

## Project Layout

- `FtcRobotController/`: official FTC Robot Controller app module
- `TeamCode/`: team-owned robot code
- `scripts/`: helper scripts for Control Hub wireless deployment

## Requirements

- Android Studio Ladybug (2024.2) or newer
- A JDK supported by the FTC Android Studio setup
- Android platform tools (`adb`) on your `PATH`

### Windows setup

From PowerShell, run the one-time bootstrap script. It installs Git for Windows,
JDK 17, Android Studio, the Android SDK packages this project requires, writes
the local (ignored) SDK configuration file, and compiles `TeamCode` once to
download dependencies and validate the Gradle source set.

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\setup-windows.ps1
```

After it finishes, open `C:\code\FTC-FALL-2026-34258` (the repository root) in
Android Studio and sync the Gradle project. Restart VS Code so the new Java and
Android SDK environment variables are available to its terminals and tasks.

## Wireless Control Hub Workflow

1. Connect your development machine to the same network as the Control Hub.
2. Enable wireless ADB on the hub once over USB if it is not already enabled.
3. In VS Code, choose **FTC: OTA Connect, Build, and Install** in Run and
   Debug, then press `F5`. Enter the hub IP address when prompted.

   The launcher connects to the hub, builds the debug APK, and installs it
   specifically on that hub. It does not require Git Bash or a USB device.

   To run the same workflow from PowerShell:

   ```powershell
   .\scripts\controlhub-install.ps1 -ControlHubIp 192.168.43.1
   ```

## VS Code Run And Debug

This workspace includes VS Code profiles in `.vscode/`:

- `FTC: Regular Install (USB)`: builds and installs the debug app to a USB-connected device
- `FTC: OTA Connect, Build, and Install`: connects, builds, and installs the debug app over Wi-Fi to the Control Hub
- `FTC: Debug on Control Hub`: launches the Robot Controller app in Android debug mode on the Control Hub, forwards local port `5005`, and attaches the VS Code Java debugger

The first time you open the repo in VS Code, install the recommended extensions:

- `Extension Pack for Java`
- `Gradle for Java`

For the debug profile to work reliably:

- `adb` must be on your `PATH`
- the Control Hub must already be reachable over Wi-Fi
- the VS Code Java debugger must be installed

## Where To Start Coding

Start in:

- `TeamCode/src/main/java/org/firstinspires/ftc/teamcode/opmode/BasicTeleOp.java`

That class is a minimal Linear OpMode with four-motor mecanum/tank-style drivetrain wiring placeholders using standard FTC naming conventions.

## Notes

- The root `LICENSE` file was left untouched from the existing repository.
- The upstream FTC SDK license text is included in `FIRST_LICENSE.txt`.
- If you want Kotlin, a command-based structure, Road Runner, Pedro Pathing, MeepMeep integration, or a subsystem architecture, that can be layered on next without changing the base FTC project layout.
