// dzlaunch.ks
//
// Script for performing launches and circularisation
//  Parameter1 - Target orbit height
//  Parameter2 - Direction of launch
//  Parameter3 - Autostage on/off
//  Parameter4 - Override when the gravity turn should start
//  Parameter5 - Set the gravity turn pitch limit
//  Parameter6 - Auto deploy solar panels once circularised
//
// 1.0 - Initial version for KSP v1.05
// 2.0 - Checked and updated for KSP v1.1
//     - Added code to speed up circularisation calculation
//     - Set all parameter defaults for Kerbin
//

PARAMETER vTargetOrbit IS 80000.
PARAMETER vDirection IS 90.
PARAMETER vAutoStage IS 1.
PARAMETER vGravityTurnOverride IS 0.
PARAMETER vGravityTurnLimit IS 20.
PARAMETER vDeployAllSolar IS 1.

CLEARSCREEN.
RUN dzCommon.
RUN dzPhysics.
RUN dzPID1.

// Stay in this loop until vRunmode=999
// runmode 	000 - Prelaunch
//         	010 - Launch Countdown
//         	100 - Launch
//         	200 - Gravity Turn
//         	300 - Orbit
//			400 - Post orbit actions
//			999 - Done


SET vRunmode TO 000.
UNTIL vRunmode = 9999 {

	// 000 - Prelaunch
	IF vRunmode = 000 {
		SET vThrottle TO 1.
		LOCK THROTTLE TO vThrottle.
		LOCK STEERING TO UP.
		PRINT "(" + vRunmode + ") " + "Target orbit is " + vTargetOrbit.
		fNotify("Target orbit is " + vTargetOrbit).
		PRINT "(" + vRunmode + ") " + "Target heading is " + vDirection.
		fNotify("Target heading is " + vDirection).

		IF ORBIT:BODY:NAME = "Kerbin" {
			SET vRunmode TO 10.
		}.

		IF ORBIT:BODY:NAME = "Minmus" {
			SET vRunmode TO 20.
		}.

		IF ORBIT:BODY:NAME = "Ike" {
			SET vRunmode TO 30.
		}.

		IF ORBIT:BODY:NAME = "Mun" {
			SET vRunmode TO 20.
		}.

		IF vRunmode = 000 {
			PRINT "Launch Location not Setup.".
			fNotify("Launch aborted - location not configured").
			SET vRunmode TO 9999.
		}.

	}

	// 10 - Kerbin Launch
	IF vRunmode = 10 {
		SET vGravityTurnMod TO vTargetOrbit / 10.
		PRINT "(" + vRunmode + ") " + "Gravity Turn Modifier is " + vGravityTurnMod.
		//fNotify("Gravity Turn Modifier is " + vGravityTurnMod).
		PRINT "(" + vRunmode + ") " + "Gravity Turn Limit is " + vGravityTurnLimit.
		fNotify("Gravity Turn Limit is " + vGravityTurnLimit).
		SET vGravityTurnOverrideMod TO vGravityTurnOverride * 0.9.
		IF vGravityTurnOverride > 0 {
			PRINT "Performing Over-ride Gravity Turn at " + vGravityTurnOverride.
			fNotify("Performing Over-ride Gravity Turn at " + vGravityTurnOverride).
		}.
		SET vRunmode TO 100.
	}.

	// 20 - Zero Atmosphere Launch
	IF vRunmode = 20 {
		SET vGravityTurnMod TO vTargetOrbit / 1.
		PRINT "(" + vRunmode + ") " + "Gravity Turn Modifier is " + vGravityTurnMod.
		PRINT "(" + vRunmode + ") " + "Gravity Turn Limit is " + vGravityTurnLimit.
		SET vGravityTurnOverride TO 0.
		SET vGravityTurnOverrideMod TO 0.
		PRINT "Gravity Turn Over-ride not available on Minmus".
		SET vRunmode TO 100.
	}.


	// 20 - Zero Atmosphere Launch with non Reaction Wheel
	IF vRunmode = 30 {
		SET vGravityTurnMod TO vTargetOrbit / 10.
		PRINT "(" + vRunmode + ") " + "Gravity Turn Modifier is " + vGravityTurnMod.
		PRINT "(" + vRunmode + ") " + "Gravity Turn Limit is " + vGravityTurnLimit.
		SET vGravityTurnOverride TO 0.
		SET vGravityTurnOverrideMod TO 0.
		PRINT "Gravity Turn Over-ride not available on Minmus".
		SET vRunmode TO 100.
	}.

	// 100 - Launch
	IF vRunmode = 100 {
		PRINT "(" + vRunmode + ") " + "Launch".
		UNTIL SHIP:AVAILABLETHRUST > 0 {
			WAIT 0.5.
			STAGE.
		}.
		SET vRunmode TO 200.
		PRINT "(" + vRunmode + ") " + "Waiting to start gravity turn".
		fNotify("Waiting to start gravity turn").
	}.

	// 200 - Initialise Gravity Turn
	IF vRunmode = 200 {
		SET vPitch TO 90.
		LOCK STEERING TO HEADING(vDirection,vPitch).

		WHEN vPitch<90 THEN {
			PRINT "(" + vRunmode + ") " + "Starting gravity turn".
			fNotify("Starting gravity turn").
		}

		LOCK vCurrentAscentSpeed TO MAX(0.01,(ABS(SHIP:VERTICALSPEED))^2+(SHIP:GROUNDSPEED)^2)^0.5.
		//SET vSpeedPID TO PIDLOOP(0.05,0.01,0.01,0,1).
		//SET vSpeedPID:SETPOINT TO 300.
		SET vSpeedPID TO PIDLOOP(10,2,.01,0,1).
		SET vSpeedPID:SETPOINT TO 0.20.

		UNTIL SHIP:APOAPSIS >= vTargetOrbit {
			//SET vPitch TO ROUND(MAX(vGravityTurnLimit,(MIN(90,ABS(LOG10((MAX(0.001,SHIP:APOAPSIS+vGravityTurnMod-vGravityTurnOverride))/vTargetOrbit))*90))),2).
			SET vPitch TO ROUND(MAX(vGravityTurnLimit,(MIN(90,ABS(LOG10((MAX(0.001,SHIP:APOAPSIS+vGravityTurnMod-vGravityTurnOverrideMod))/(vTargetOrbit+vGravityTurnMod+vGravityTurnOverrideMod)))*90))),2).

			//SET vPitch TO ROUND(MAX(vGravityTurnLimit,(MIN(90,ABS(LOG10((MAX(0.001,ALT:RADAR+vGravityTurnMod-vGravityTurnOverride))/vTargetOrbit))*90))),2).
			//SET vPitch TO ROUND(MAX(vGravityTurnLimit,(MIN(90,ABS(LOG10((MAX(0.001,ALT:RADAR+vGravityTurnMod-vGravityTurnOverrideMod))/(vTargetOrbit+vGravityTurnMod+vGravityTurnOverrideMod)))*90))),2).
			PRINT "vPitch: " + vPitch + "    " AT (0,20).
			PRINT "Pressure:" + ROUND(SHIP:DYNAMICPRESSURE,5) + "    " AT (0,21).
			PRINT "Throttle:" + ROUND(vThrottle,3) + "    " AT (0,22).

			// Try to keep 300 ascent until 10000 at kerbin
			IF SHIP:ALTITUDE < 30000 AND SHIP:ALTITUDE > 100 {
				//SET vThrottle TO vSpeedPID:UPDATE(TIME:SECONDS,vCurrentAscentSpeed).
				SET vThrottle TO vSpeedPID:UPDATE(TIME:SECONDS,MAX(0.01,SHIP:DYNAMICPRESSURE)).
			} ELSE {
				SET vThrottle TO 1.
				SET vNothing TO vSpeedPID:UPDATE(TIME:SECONDS,MAX(0.01,SHIP:DYNAMICPRESSURE)).
				PRINT "Nothing:" + ROUND(vNothing,3) + "    " AT (0,23).
			}.

			fAutoStage(vAutoStage).
			WAIT 0.001.
		}.

		SET vRunmode TO 220.
	}.

	// 220 - Puff Puff to hold target orbit
	IF vRunmode = 220 {
		SET vThrottle TO 0.
		LOCK STEERING TO SHIP:PROGRADE.
		PRINT "(" + vRunmode + ") " + "Fine tuning orbit target".
		fNotify("Fine tuning orbit target").
		SET vTargetSet TO 0.
		SET vTargetApoapsisC TO SHIP:APOAPSIS.
		SET vTargetApoapsisP TO vTargetApoapsisC.
		WAIT 5.
		SET vTargetApoapsisC TO SHIP:APOAPSIS.
		UNTIL vTargetSet = 1 {
			fAutoStage(vAutoStage).
			IF vTargetApoapsisC > vTargetApoapsisP AND vTargetApoapsisC > vTargetOrbit AND vTargetApoapsisP > vTargetOrbit {
				SET vTargetSet TO 1.
				BREAK.
			} ELSE {
				SET vThrottle TO 1.
				WAIT 0.05.
				SET vThrottle TO 0.
			}.
			SET vTargetApoapsisP TO vTargetApoapsisC.
			WAIT 5.
			SET vTargetApoapsisC TO SHIP:APOAPSIS.
		}.
		// Wait until Apoapsis stabalises
		SET vStable TO 0.
		SET vStableCheckC TO SHIP:APOAPSIS.
		SET vStableCheckP TO vStableCheckC.
		PRINT "(" + vRunmode + ") " + "Waiting for stable target orbit".
		fNotify("Waiting for stable target orbit").
		UNTIL vStable = 1 {
			IF ABS(vStableCheckC-vStableCheckP) < 5 {
				SET vStable TO 1.
			}.
			SET vStableCheckP TO vStableCheckC.
			WAIT 5.
			SET vStableCheckC TO SHIP:APOAPSIS.
		}.
		PRINT "(" + vRunmode + ") " + "Stable target orbit".
		fNotify("Stable target orbit").
		SET vRunmode TO 300.
	}.

	// 300 - Calculate Manuevour  Node
	IF vRunmode = 300 {
		PRINT "(" + vRunmode + ") " + "Calculating orbit node".
		fNotify("Calculating orbit node").
		SET vTIME1 TO TIME:SECONDS.
		SET vDeltaV TO 1.
		SET X TO NODE(TIME:SECONDS + ETA:APOAPSIS, 0, 0, vDeltaV).
		ADD X.
		SET vNodePeriapsis TO X:ORBIT:PERIAPSIS.
		SET vNodeApoapsis TO X:ORBIT:APOAPSIS.
		SET vNodeDifferenceC TO ABS(vNodeApoapsis-vNodePeriapsis).
		SET vNodeDifferenceP TO vNodeDifferenceC.
		SET vNodeCalculated TO 0.
		UNTIL vNodeCalculated = 1 {
			REMOVE X.
			WAIT 0.0001.
			SET vDeltaV TO vDeltaV + 1.
			SET X TO NODE(TIME:SECONDS + ETA:APOAPSIS, 0, 0, vDeltaV).
			ADD X.
			SET vNodePeriapsis TO X:ORBIT:PERIAPSIS.
			SET vNodeApoapsis TO X:ORBIT:APOAPSIS.
			SET vNodeDifferenceC TO ABS(vNodeApoapsis-vNodePeriapsis).
			IF vNodeDifferenceC > vNodeDifferenceP {
				SET vNodeCalculated TO 1.
			}.
			SET vNodeDifferenceP TO ABS(vNodeApoapsis-vNodePeriapsis).
		}.
		PRINT "(" + vRunmode + ") " + "Calculated Initial Node at " + vDeltaV.
		fNotify("Calculated Initial Node at " + vDeltaV).
		SET vRunmode TO 310.
	}.

	// 310 - Fine tune node
	IF vRunmode = 310 {
		PRINT "(" + vRunmode + ") " + "Fine tuning orbit node".
		fNotify("Fine tuning orbit node").
		REMOVE X.
		SET vDeltaV TO vDeltaV-1.
		SET X TO NODE(TIME:SECONDS + ETA:APOAPSIS, 0, 0, vDeltaV).
		ADD X.
		SET vNodePeriapsis TO X:ORBIT:PERIAPSIS.
		SET vNodeApoapsis TO X:ORBIT:APOAPSIS.
		SET vNodeDifferenceC TO ABS(vNodeApoapsis-vNodePeriapsis).
		SET vNodeDifferenceP TO vNodeDifferenceC.
		SET vNodeCalculated TO 0.
		UNTIL vNodeCalculated = 1 {
			REMOVE X.
			WAIT 0.001.
			SET vDeltaV TO vDeltaV + .1.
			SET X TO NODE(TIME:SECONDS + ETA:APOAPSIS, 0, 0, vDeltaV).
			ADD X.
			SET vNodePeriapsis TO X:ORBIT:PERIAPSIS.
			SET vNodeApoapsis TO X:ORBIT:APOAPSIS.
			SET vNodeDifferenceC TO ABS(vNodeApoapsis-vNodePeriapsis).
			IF vNodeDifferenceC > vNodeDifferenceP {
				SET vNodeCalculated TO 1.
			}.
			SET vNodeDifferenceP TO ABS(vNodeApoapsis-vNodePeriapsis).
		}.
		SET vTIME2 TO TIME:SECONDS.
		PRINT "(" + vRunmode + ") " + "Calculated Fine Node at " + vDeltaV.
		PRINT "Time to calculate node: " + ROUND(vTIME2-vTIME1) + " seconds.".
		fNotify("Calculated Final Node at " + vDeltaV).
		SET vRunmode TO 320.
	}.

	// 320 - Circularise Orbit
	IF vRunmode = 320 {
		PRINT "(" + vRunmode + ") " + "Coasting to orbit node".
		fNotify("Coasting to orbit node").
		RUN dzNode.

		// Once we are circulaised we will deply solar panels if required
		SET vRunMode TO 400.


	}.

	// 400 - Check for Solar Deploy
	IF vRunmode = 400 {
		PRINT "(" + vRunmode + ") " + "Post orbit actions".
		IF vDeployAllSolar = 1 {
			fNotify("Deploying Solar Panels").
			TOGGLE PANELS.
		}.

		SET vRunmode TO 999.
	}.

	// 999 - Housekeeping
	IF vRunmode = 999 {
		UNLOCK STEERING.
		UNLOCK THROTTLE.
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
		SET vRunmode TO 9999.
		// Shutdown KOS to save power
		fNotify("Power save: Shutting down kOS").
		SHUTDOWN.
	}.


}.
