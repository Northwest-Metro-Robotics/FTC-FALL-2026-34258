package org.firstinspires.ftc.teamcode.lib.Models;

import com.qualcomm.robotcore.hardware.HardwareMap;
import com.qualcomm.robotcore.hardware.DcMotor;
import com.qualcomm.robotcore.hardware.DcMotorEx;
import org.firstinspires.ftc.robotcore.external.Telemetry;


public class Shooter{
    // Define Shoote
    private DcMotorEx shooter = null;
    private Telemetry telemetry = null;

    private static final double TARGET_RPM = 3800;

    // Start with P + F, keep I and D at 0 initially
    private static final double kP = 100;
    private static final double kI = 0.0;
    private static final double kD = 0.0;
    private static final double kF = 12;

    // REV HD Hex bare motor encoder
    private static final double TICKS_PER_REV = 28.0;

    // constructor
    public Shooter(HardwareMap hardwareMap, Telemetry telemetry) {

        // Asighn motor
        shooter = hardwareMap.get(DcMotorEx.class, "shooter");
        // Set the direction,(foward).
        shooter.setDirection(DcMotor.Direction.FORWARD);
        // Set Speed

        
        shooter.setZeroPowerBehavior(DcMotor.ZeroPowerBehavior.FLOAT);

        shooter.setMode(DcMotor.RunMode.STOP_AND_RESET_ENCODER);

        shooter.setMode(DcMotor.RunMode.RUN_USING_ENCODER);

        shooter.setVelocityPIDFCoefficients(kP, kI, kD, kF);

        this.telemetry = telemetry;
    }

    // On method

    public void On() {

     double targetTps = rpmToTicksPerSec(TARGET_RPM);
     double rpmA = ticksPerSecToRpm(shooter.getVelocity());
    this.shooter.setVelocity(targetTps);
    this.telemetry.addData("Target RPM ", "%.0f", TARGET_RPM);
    this.telemetry.addData("Motor A RPM", "%.0f", rpmA);
    this.telemetry.addData("Target tps", "%.0f", targetTps);
    this.telemetry.addData("A tps", "%.0f", shooter.getVelocity());

    }


    // Off Method9
    public void Off() {

    this.shooter.setVelocity(0.0);
    double targetTps = rpmToTicksPerSec(TARGET_RPM);
    double rpmA = ticksPerSecToRpm(shooter.getVelocity());

    this.telemetry.addData("Target RPM", "%.0f", TARGET_RPM);
    this.telemetry.addData("Motor A RPM", "%.0f", rpmA);
    this.telemetry.addData("Target tps", "%.0f", targetTps);
    this.telemetry.addData("A tps", "%.0f", shooter.getVelocity());
    }
     private static double rpmToTicksPerSec(double rpm) {
        return (rpm / 60.0) * TICKS_PER_REV;
    }

    private static double ticksPerSecToRpm(double ticksPerSec) {
        return (ticksPerSec / TICKS_PER_REV) * 60.0;
    }
}
