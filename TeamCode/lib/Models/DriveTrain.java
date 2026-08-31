package org.firstinspires.ftc.teamcode.lib.Models;

public class DriveTrain {
    public double frontLeftPower;
    public double frontRightPower;
    public double backLeftPower;
    public double backRightPower;

    public double frontLeftPowerInitial;
    public double frontRightPowerInitial;
    public double backLeftPowerInitial;
    public double backRightPowerInitial;

    public DriveTrain(double frontLeftPower, double frontRightPower, double backLeftPower, double backRightPower) {
        this.frontLeftPower = frontLeftPower;
        this.frontRightPower = frontRightPower;
        this.backLeftPower = backLeftPower;
        this.backRightPower = backRightPower;
        captureInitialPowers();
    }

    public void setDrivePowers(double frontLeftPower, double frontRightPower, double backLeftPower, double backRightPower) {
        this.frontLeftPower = frontLeftPower;
        this.frontRightPower = frontRightPower;
        this.backLeftPower = backLeftPower;
        this.backRightPower = backRightPower;
    }

    public void stop() {
        setDrivePowers(0.0, 0.0, 0.0, 0.0);
    }

    public void scale(double scaleFactor) {
        setDrivePowers(
            frontLeftPower * scaleFactor,
            frontRightPower * scaleFactor,
            backLeftPower * scaleFactor,
            backRightPower * scaleFactor
        );
    }

    public void normalize() {
        double maxMagnitude = Math.max(
            Math.max(Math.abs(frontLeftPower), Math.abs(frontRightPower)),
            Math.max(Math.abs(backLeftPower), Math.abs(backRightPower))
        );

        if (maxMagnitude > 1.0) {
            scale(1.0 / maxMagnitude);
        }
    }

    public void clip() {
        setDrivePowers(
            clip(frontLeftPower),
            clip(frontRightPower),
            clip(backLeftPower),
            clip(backRightPower)
        );
    }

    public void resetToInitialPowers() {
        setDrivePowers(
            frontLeftPowerInitial,
            frontRightPowerInitial,
            backLeftPowerInitial,
            backRightPowerInitial
        );
    }

    public void captureInitialPowers() {
        frontLeftPowerInitial = frontLeftPower;
        frontRightPowerInitial = frontRightPower;
        backLeftPowerInitial = backLeftPower;
        backRightPowerInitial = backRightPower;
    }

    public void setTankDrive(double leftPower, double rightPower) {
        setDrivePowers(leftPower, rightPower, leftPower, rightPower);
    }

    public void setArcadeDrive(double drive, double turn) {
        double leftPower = drive + turn;
        double rightPower = drive - turn;

        setTankDrive(leftPower, rightPower);
        normalize();
    }

    public void setMecanumDrive(double drive, double strafe, double turn) {
        setDrivePowers(
            drive + strafe + turn,
            drive - strafe - turn,
            drive - strafe + turn,
            drive + strafe - turn
        );
        normalize();
    }

    public double[] toArray() {
        return new double[] {frontLeftPower, frontRightPower, backLeftPower, backRightPower};
    }

    private double clip(double value) {
        return Math.max(-1.0, Math.min(1.0, value));
    }
}
