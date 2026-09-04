# FTC Robot Base

This repository is set up as a standard FTC Android Studio project for a REV Control Hub using the official `FtcRobotController` / `TeamCode` module layout.

The scaffold was imported from the official `FIRST-Tech-Challenge/FtcRobotController` project at upstream commit `26cd1fdd2a3c4b26173d9ff33a3279c27d1c7ad1`, which corresponds to FTC SDK `11.2.1` for the 2025-2026 DECODE season.

## Project Layout

- `FtcRobotController/`: official FTC Robot Controller app module
- `TeamCode/`: team-owned robot code
- `scripts/`: helper scripts for Control Hub wireless deployment

## Windows Setup (First Time)

These steps prepare a new Windows computer for FTC development. You only need
to run the setup task once per computer.

1. Install [Visual Studio Code](https://code.visualstudio.com/) and open it.
2. Open this project folder:
   - Select **File** > **Open Folder...**.
   - Select the folder that contains this `README.md` file, such as
     `C:\code\FTC-FALL-2026-34258`.
   - Select **Select Folder**. If VS Code asks whether you trust the authors,
     select **Yes, I trust the authors** for a copy of this team repository.
3. Install the suggested VS Code extensions when prompted. If no prompt
   appears, select the **Extensions** icon in the left sidebar, search for, and
   install:
   - `Extension Pack for Java`
   - `Gradle for Java`
4. Run the setup task:
   - In the top menu, select **Terminal** > **Run Task...**.
   - Select **FTC: Set Up Windows Development Environment**.
   - Watch the terminal panel at the bottom of VS Code until it reports
     `Setup complete.` This may take a while because it downloads developer
     tools and Android SDK components.
5. Restart VS Code after setup completes. This makes the new Java and Android
   SDK settings available to VS Code.

The setup task installs Git for Windows, JDK 17, Android Studio, and the
required Android SDK packages. It also configures this local checkout and
builds `TeamCode` once to download the Gradle dependencies. You do not need to
open PowerShell or enter commands manually.

If Windows asks for permission to install software, approve the prompt. The
task requires `winget` (included with current versions of Windows 10 and 11).
If it says that `winget` is missing, install or update **App Installer** from
the Microsoft Store, then run the task again.

After setup, you can open the same project folder in Android Studio and allow
it to sync the Gradle project if you prefer to use Android Studio.

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
