// dzLander(LandMode,Parm1,Parm2,Parm3,Parm4,Parm5)
//
// LandMode = "HoverMoveLand"
//    Parm1 = Distance to move
//    Parm2 = Height to move at
//    Parm3 = Heading to move towards
//    Parm4 = Max Pitch to move at (0 = autoset)
//
// LandMode = "LandFinal"
//    Parm1 = Approx Height of Craft for ALT:RADAR
//
// LandMode = "LandTargetFromOrbit"
//    Parm1 = Target Distance Offset
//    Parm2 = Approx Lander Height
//    Parm3 = 1=AutoLand 0=HoverWait
//

//RUN dzLander("HoverMoveLand",target:distance-20,5,target:heading,0).
RUN dzLander("HoverMoveLand",1100,20,90,0).

//RUN dzLander("LandFinal",8,0,0,0).

//RUN dzLander("LandTargetFromOrbit",0,5,1,0).

//RUN dzLander("LandFinal",4,0,0,0).

//RUN dzLander("LandFinal",15,0,0,0).

// dzLaunch(OrbitTarget, Heading, AutoStage, GravityTurnOverride, GravityTurnLimit, DeployAllSolar)

//RUN dzLaunch(100000,90,1,0,20,1).
//RUN dzLaunch(20000,90,0,0,0).
//RUN dzLaunch(14000,90,0,0).