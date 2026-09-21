package org.firstinspires.ftc.teamcode.lib.Models;

import com.qualcomm.robotcore.hardware.DcMotor;

public class Shooter{
    // Define Shoote
    private DcMotor shooter = null;
    // Asighn motor
    shooter = hardwareMap.get(DcMotor.class, "Shooter");
    // Set the direction,(foward).
    shooter.setDirection(DcMotor.Direction.FORWARD);
    // Set Speed

    // On method

    public void On() {

     this.shooter.setPower(1.0);
    }


    // Off Method
    public void Off() {

        this.shooter.setPower(0.0);
    }




}
