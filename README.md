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

## Wireless Control Hub Workflow

1. Connect your development machine to the same network as the Control Hub.
2. Enable wireless ADB on the hub once over USB if it is not already enabled.
3. Connect to the hub:

   ```bash
   ./scripts/controlhub-connect.sh 192.168.43.1
   ```

4. Build and install the Robot Controller app over the air:

   ```bash
   ./scripts/controlhub-install.sh 192.168.43.1
   ```

The install script will:

- connect `adb` to the Control Hub
- wait for the device to come online
- run `./gradlew :TeamCode:installDebug`

## VS Code Run And Debug

This workspace includes VS Code profiles in `.vscode/`:

- `FTC: Regular Install (USB)`: builds and installs the debug app to a USB-connected device
- `FTC: OTA Install`: builds and installs the debug app over Wi-Fi to the Control Hub
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
