//@LAZYGLOBAL OFF.

DECLARE PARAMETER vLandMode.
DECLARE PARAMETER vParameter1.
DECLARE PARAMETER vParameter2.
DECLARE PARAMETER vParameter3.
DECLARE PARAMETER vParameter4.

SET vRunMode TO 0.

UNTIL vRunMode = -1 {

	// 0 - Initialise
	IF vRunMode = 0 {
		SET vLogMode TO "0".
		CLEARSCREEN.
		
		RUN dzPhysics.
		RUN dzPID1.
		RUN dzDescentSettings.
		
		SAS OFF.
		RCS OFF.
				
		SET vAltRadarInit TO ALT:RADAR.
		SET vApoapsisInit TO SHIP:APOAPSIS.		
		SET vTargetSpeed TO -999.
		SET vPitch TO 90.		
		SET vGroundSpeedAdj TO 1.
		SET vTargetHover TO 500.
		SET vHere TO 0.
		SET vDistance TO -1.
		SET vDistanceToTarget TO -1.
		SET vAction2 TO " ".
		SET vMaxAccel TO -1.
		SET vBurnTime TO -1.
		SET vBurnDist TO -1.
		SET vLanderHeight TO 0.
		SET vMaxPitch TO -1.
		SET vAG TO -1.
		SET vHeight TO -1.
		SET vOffSetHeading TO 0.
		SET vAutoLand TO 0.
		
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.				
		SET vThrottle TO 0.
		
		LOCK THROTTLE TO vThrottle.		
		LOCK vTWR TO MAX(0.01,SHIP:MAXTHRUST/fFGHere()).
		//LOCK vMidThrottle TO fFGHere()/SHIP:AVAILABLETHRUST.
		LOCK vMidThrottle TO 1/vTWR.
		LOCK vCurrentDecentSpeed TO 0-(MAX(0.01,(ABS(SHIP:VERTICALSPEED))^2+(SHIP:GROUNDSPEED)^2)^0.5).
		
		SET vSteering TO UP + R(0,0,0).
		LOCK STEERING TO vSteering.		
		LOCK vHeadingReal TO fGetRealHeading().
		LOCK vAlignment TO ABS(COS(FACING:PITCH) - COS(vSteering:PITCH)) + ABS(SIN(FACING:PITCH) - SIN(vSteering:PITCH))	+ ABS(COS(FACING:YAW) - COS(vSteering:YAW)) + ABS(SIN(FACING:YAW) - SIN(vSteering:YAW)).
		
		LOCK vAltReal TO SHIP:ALTITUDE-SHIP:GEOPOSITION:TERRAINHEIGHT-vLanderHeight.
					
		IF vLandMode = "HoverMoveLand"  { SET vRunMode TO 10. }.
		IF vLandMode = "LandFinal"  { SET vRunMode TO 20. }.
		IF vLandMode = "LandTargetFromOrbit" { SET vRunMode TO 30. }.
		
		SET vSubMode TO " ".
		
		IF vRunMode = 0 {
			PRINT "Invalid LandMode: " + vLandMode.
			SET vRunMode TO -1.
		}.	

		UNTIL SHIP:AVAILABLETHRUST > 0 {
			WAIT 0.5.
			STAGE.
		}.
		
	}.
	
	// 10 - HoverMoveLand - Initialise
	IF vRunMode = 10 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		SET vDistance TO vParameter1.
		SET vHeight TO vParameter2.
		SET vHeading TO vParameter3.
		SET vMaxPitch TO vParameter4.
		
		IF vMaxPitch = 0 {
			SET vMaxPitch TO fGetTargetMoveAngle().
		}.
		
		SET vLanderHeight TO vAltRadarInit.

		LOCK vHere TO MAX(0.01,((vStartPosition:DISTANCE)^2-(vAltReal-vStartPositionOffset)^2))^0.5.
		LOCK vApoapsisReal TO SHIP:APOAPSIS - vApoapsisInit.

		SET vStartPosition TO SHIP:GEOPOSITION.
		SET vStartPositionOffset TO vAltReal - SHIP:GEOPOSITION:DISTANCE.
		
		SET vRunMode TO 100.
	}.

	
	// 20 - LandFinal - Initialise
	IF vRunMode = 20 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		SET vLanderHeight TO vParameter1.
		SET vHeading TO 0.

		SET vGroundSpeedAdj TO 3.
		SET vTargetHover TO fGetTargetHoverHeight().				
						
		SET vRunMode TO 350.
	}.

	
	// 30 - LandTargetFromOrbit - Initialise
	IF vRunMode = 30 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		SET vDistanceOffSet TO vParameter1.
		SET vLanderHeight TO vParameter2.
		SET vAutoLand TO vParameter3.
		
		SET vTargetHover TO fGetTargetHoverHeight().
		SET vMaxPitch TO fGetTargetMoveAngle().		
		
		SET vGroundSpeedAdj TO 3.		
		SET vSubMode TO "LandTargetPhase1".		
		SET vHeading TO TARGET:HEADING.
		SET vHeight TO vTargetHover.
		
		LOCK vDistanceToTarget TO MAX(0.01,((TARGET:DISTANCE)^2-(SHIP:ALTITUDE-TARGET:ALTITUDE)^2))^0.5.
		
		// First we need to align with the target
		SET vRunMode TO 600.
	}.

	
	// 35 - LandTargetFromOrbit - Should be hovering - Setup ready for move to target 	
	IF vRunMode = 35 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		
		SET vDistance TO vDistanceToTarget + vDistanceOffSet.		
		LOCK vHere TO vDistance - vDistanceToTarget.
		SET vHeading TO TARGET:HEADING.
		SET vHeight TO vPrelandTargetHeight.
		
		SET vRunMode To 200.	
	}.

	
	// 100 - HoverMoveLand - Ascend to hover height
	IF vRunMode = 100 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		SET vAction TO "Initial Ascent to Hover".
		SET vAction2 TO "AG9 To Stop Ascent".
		fPrint().
		
		SET vThrottle TO vMidThrottle.

		SET bAscent TO 1.		
		UNTIL bAscent = 0 {
			IF vApoapsisReal + vStartPositionOffset > vHeight {
				SET vThrottle TO 0.
			} ELSE {
				SET vThrottle TO vThrottle + 0.001.
			}.
			IF ABS(vAltReal-vHeight) < 10 {
				SET bAscent TO 0.
			}.
			ON AG9 { SET bAscent TO 0. }.
			fPrint(). 
			WAIT 0.005.
		}.

		SET vAction2 TO "                                         ".
		SET vRunMode TO 200.		
	}.

	
	// 200 - HoverMoveLand - Move towards target heading
	IF vRunMode = 200 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		SET vAction TO "Moving towards target".
		SET vAction2 TO "                                         ".
		fPrint().
		SET vThrottle TO 0.
		SET vHalfWay TO vDistance/2.
		SET vHoverPID TO fPIDINIT1(0.02,0.05,0.05).
		
		SET vPitch TO 90.
		SET vSteering TO HEADING(vHeading,vPitch).
		UNTIL vAlignment < 0.1 {			
			SET vThrottle TO vMidThrottle + fPIDSEEK1(vHoverPID,vHeight,vAltReal).
			fPrint().
			WAIT 0.001.
		}.
		
		UNTIL vHere > (vHalfWay - (ABS(SHIP:GROUNDSPEED)*2)) {
			SET vThrottle TO vMidThrottle + fPIDSEEK1(vHoverPID,vHeight,vAltReal).
			SET vPitch TO vMaxPitch.
			SET vSteering TO HEADING(vHeading,vPitch).
			fPrint().
			WAIT 0.001.					
		}.

		SET vRunMode TO 300.		
	}.

	
	// 300 - HoverMoveLand - Slow towards target
	IF vRunMode = 300 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		SET vAction TO "Slow towards target".
		SET vAction2 TO "                                         ".
		fPrint().
		SET vPitch TO vMaxPitch.
		SET vSteering TO HEADING(180+vHeading,vPitch).
		SET vCurrentGroundSpeed TO ABS(SHIP:GROUNDSPEED).
		SET vPreviousGroundSpeed TO vCurrentGroundSpeed.
		SET bSpeedOK TO 0.	
		UNTIL bSpeedOK=1 {			
			SET vThrottle TO vMidThrottle + fPIDSEEK1(vHoverPID,vHeight,vAltReal).
			SET vPitch TO vMaxPitch.			
			SET vSteering TO HEADING(180+vHeading,vPitch).
			SET vCurrentGroundSpeed TO ABS(SHIP:GROUNDSPEED).				
			IF fHeadingDifference(vHeading,vHeadingReal) > 90 {
				SET bSpeedOK TO 1.				
				BREAK.
			}			
			SET vPreviousGroundSpeed TO vCurrentGroundSpeed.
			
			fPrint().
			WAIT 0.001.
		}.
		
		SET vThrottle TO 0.
		SET vGroundSpeedAdj TO 1.
		SET vRunMode TO 350.	
	}.

	
	// 350 - LandFinal - Preland by reducing groundspeed
	IF vRunMode = 350 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		IF vSubMode = "LandTargetPhase1" {
			SET vAction TO "Pretarget Move - Hover and Reduce Groundspeed".
		} ELSE {
			SET vAction TO "Preland - Reduce Groundspeed".
		}
		
		SET vAction2 TO "Hover set to " + ROUND(vTargetHover).
		fPrint().
		
		SET vPitch TO 90.
		SET vSteering TO HEADING(180+vHeading,vPitch).
		SET vPSPEED TO fGetPIDSettings("PSPEED").
		SET vISPEED TO fGetPIDSettings("ISPEED").
		SET vDSPEED TO fGetPIDSettings("DSPEED").
		SET vSpeedPID TO fPIDINIT1(vPSPEED,vISPEED,vDSPEED).

		SET bReadyToLand TO 0.
		UNTIL bReadyToLand = 1 {
			
			SET vTargetSpeed TO fGetDescentSpeed(vAltReal,vTWR).
			SET vThrottle TO vMidThrottle + fPIDSEEK1(vSpeedPID,vTargetSpeed,vCurrentDecentSpeed).	
			SET vPitch TO MAX(30,85-(vGroundSpeedAdj*ABS(SHIP:GROUNDSPEED))).
			SET vSteering TO HEADING(180+vHeadingReal,vPitch).
			
			IF SHIP:GROUNDSPEED < 1 AND SHIP:VERTICALSPEED > -1 AND vAltReal < vTargetHover {
				SET vPrelandTargetHeight TO vAltReal.
				SET bReadyToLand TO 1.
				BREAK.
			} ELSE {
				IF vAltReal < vTargetHover {
					SET vAction2 TO "Starting Hover Maneouver(1)".
					SET vHoverPID TO fPIDINIT1(0.02,0.05,0.05).	
					SET vPrelandTargetHeight TO vAltReal.
					UNTIL SHIP:VERTICALSPEED > -0.5 {
						SET vPitch TO MAX(30,85-(vGroundSpeedAdj*ABS(SHIP:GROUNDSPEED))).
						SET vSteering TO HEADING(180+vHeadingReal,vPitch).
						SET vThrottle TO vMidThrottle + fPIDSEEK1(vHoverPID,vPrelandTargetHeight,vAltReal).						
						fPrint().
						WAIT 0.001.					
					}.
					SET vPrelandTargetHeight TO vAltReal.
					SET vAction2 TO "Starting Hover Maneouver(2)".
					UNTIL SHIP:GROUNDSPEED < 0.5 {
						SET vPitch TO MAX(30,85-(vGroundSpeedAdj*ABS(SHIP:GROUNDSPEED))).
						SET vSteering TO HEADING(180+vHeadingReal,vPitch).
						SET vThrottle TO vMidThrottle + fPIDSEEK1(vHoverPID,vPrelandTargetHeight,vAltReal).						
						fPrint().
						WAIT 0.001.					
					}.
					SET vPrelandTargetHeight TO vAltReal.
					SET bReadyToLand TO 1.
					BREAK.
				}.
			}
			fPrint().
			WAIT 0.001.				
		}.
		
		IF vSubMode = "LandTargetPhase1" {
			SET vRunMode TO 35.
			SET vSubMode TO " ".
		} ELSE {
			IF vAutoLand = 0 {
				SET vRunMode TO 400.
			} ELSE {
				SET vRunMode TO 410.
			}.
		}.
	}.

	
	// 400 - LandFinal - Hover and allow AG to adjust for a flat location position before actual land.
	IF vRunMode = 400 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		SET vAction TO "Manual adjustment before landing".
		SET vAction2 TO "1=0,2=90,3=180,4=270,5=STOP,6=H-5,7=H+5,8=H-20,9=LAND".
		IF vPrelandTargetHeight > 500 {
			SET vHeight TO 500. 
		} ELSE {
			SET vHeight TO vPrelandTargetHeight.
		}.
		SET vAction TO "Manual adjustment before landing (" + vHeight + ")".
		fPrint().
		
		SET vAG TO 0.
		ON AG1 { SET vAG TO 1. SET vPitch TO 80. SET vSteering TO HEADING(0,vPitch). PRESERVE. }.
		ON AG2 { SET vAG TO 2. SET vPitch TO 80. SET vSteering TO HEADING(90,vPitch). PRESERVE. }.
		ON AG3 { SET vAG TO 3. SET vPitch TO 80. SET vSteering TO HEADING(180,vPitch). PRESERVE. }.
		ON AG4 { SET vAG TO 4. SET vPitch TO 80. SET vSteering TO HEADING(270,vPitch). PRESERVE. }.
		ON AG5 { SET vAG TO 5. SET vAG5 TO 1. PRESERVE. }.
		ON AG6 { SET vAG TO 6. SET vHeight TO vHeight - 5. PRESERVE. }.
		ON AG7 { SET vAG TO 7. SET vHeight TO vHeight + 5. PRESERVE. }.
		ON AG8 { SET vAG TO 8. SET vHeight TO vHeight - 20. PRESERVE. }.
		ON AG9 { SET vAG TO 9. PRESERVE. }.

		SET vHoverPID TO fPIDINIT1(0.02,0.05,0.05).
		SET vReadyToLand TO 0.
		UNTIL vReadyToLand = 1 {			
			SET vThrottle TO vMidThrottle + fPIDSEEK1(vHoverPID,vHeight,vAltReal).						
			
			IF vAG = 0 OR vAG = 5 OR vAG = 6 OR vAG = 7 OR vAG =9 {
				SET vPitch TO MAX(30,85-(3*ABS(SHIP:GROUNDSPEED))).
				SET vSteering TO HEADING(180+vHeadingReal,vPitch).			
			}.
			
			IF vAG = 9 AND SHIP:GROUNDSPEED <= 0.5 {
				SET vReadyToLand TO 1.			
			}.
			
			IF vAG = 9 AND SHIP:GROUNDSPEED > 0.5 {
				SET vAction2 TO "Waiting for groundspeed 0.5".
			}.
			
			SET vAction TO "Manual adjustment before landing (" + vHeight + ")".								
			fPrint().
			WAIT 0.001.					
		}.
		
		SET vRunMode TO 410.
	}.	
	
	
	// 410 - Land (Do not come here unless you have pre-landed first)
	IF vRunMode = 410 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		
		SET vAction TO "Landing".
		SET vAction2 TO "                                         ".
		fPrint().		
		SET vGroundSpeedAdj	TO 0.5.
		UNTIL SHIP:STATUS = "LANDED" {
		
			SET vTargetSpeed TO fGetDescentSpeed(vAltReal,vTWR).
			SET vThrottle TO vMidThrottle + fPIDSEEK1(vSpeedPID,vTargetSpeed,vCurrentDecentSpeed).
			IF SHIP:GROUNDSPEED > 0.5 {
				SET vPitch TO MAX(30,89-(vGroundSpeedAdj*ABS(SHIP:GROUNDSPEED))).
				SET vSteering TO HEADING(180+vHeadingReal,vPitch).
			}
						
			fPrint(). 			
			WAIT 0.001.
		}.
		
		SET vThrottle TO 0.
		SET vRunMode TO 900.	
	}.

	
	// 500 - LandTargetFromOrbit - Deorbit Above the target
	IF vRunMode = 500 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		SET vAction TO "Deorbit above target".
		fPrint().
					
		LOCK vMaxAccel TO MAX(0.01,SHIP:AVAILABLETHRUST/SHIP:MASS).		
		LOCK vBurnTime TO SHIP:GROUNDSPEED/vMaxAccel.
		LOCK vBurnDist TO (SHIP:GROUNDSPEED*vBurnTime).

		//SET vSteering TO RETROGRADE.
		SET vPitch TO 0.
		SET vSteering TO HEADING(vHeadingReal+180,vPitch).				
		
		UNTIL vAlignment < 0.1 {
			fPrint().
			WAIT 0.001.
		}.
					
		// Warp to 30 seconds before burn once we are aligned
		SET vDistanceToGo TO vDistanceToTarget - vBurnDist.
		SET vTimeToBurn TO vDistanceToGo / SHIP:GROUNDSPEED.
		IF vTimeToBurn > 30 {
			RUN dzWarp(vTimeToBurn - 10).
		}.
					
		SET vPDEORBIT TO fGetPIDSettings("PDEORBIT").
		SET vIDEORBIT TO fGetPIDSettings("IDEORBIT").
		SET vDDEORBIT TO fGetPIDSettings("DDEORBIT").
		SET vDEORBITPID TO fPIDINIT1(vPDEORBIT,vIDEORBIT,vDDEORBIT).
		
		SET vSteering TO RETROGRADE.
		//SET vPitch TO 0.
		//SET vSteering TO HEADING(vHeadingReal+180,vPitch).						
				
		SET vBurnDistInit TO vBurnDist.
				
		SET vAboveTarget TO 0.
		UNTIL vAboveTarget = 1 {			
			
			SET vThrottle TO vMidThrottle + fPIDSEEK1(vDEORBITPID,vBurnDist,vDistanceToTarget).
			
			SET vSteering TO RETROGRADE.
			//SET vPitch TO 0.
			//SET vSteering TO HEADING(vHeadingReal+180,vPitch).						
						
			IF SHIP:GROUNDSPEED < 1 {
				SET vThrottle TO 0.
				SET vAboveTarget TO 1.
			}.		
													
			// If we have passed the target then burn until we have 0 groundspeed
			SET vHeadingDifference TO fHeadingDifference(vHeadingReal,TARGET:HEADING).
			IF vHeadingDifference > 135 {
				SET vPitch TO 0.
				SET vSteering TO HEADING(vHeadingReal+180,vPitch).						
				SET vThrottle TO 1.
				SET vBurn TO 1.
				UNTIL SHIP:GROUNDSPEED < 1 {
					fPrint().
					WAIT 0.001.
				}.
				SET vAboveTarget TO 1.
			}.
			
			fPrint().
			WAIT 0.001.
		}.
		
		SET vRunMode TO 350.	
	}.

	
	// 600 - TargetAlign
	IF vRunMode = 600 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		SET vAction TO "Align with Target".
		fPrint().
					
		SET vPitch TO 0.
		SET vSteering TO HEADING(180+vHeadingReal,vPitch).
		SET vOffSetHeading TO fGetHeadingOffset(vHeadingReal,TARGET:HEADING).		
		
		SET vReadyToBurn TO 0.				
		UNTIL vReadyToBurn = 1 {
			IF vAlignment < 0.1 {
				SET vThrottle TO MAX(0.01,ABS(vOffSetHeading/vTWR)).
			} ELSE {
				SET vThrottle TO 0.
			}.
			IF vOffSetHeading < 0 {
				SET vPitch TO 0.
				SET vSteering TO HEADING(TARGET:HEADING+90,vPitch).				
			} ELSE {
				SET vPitch TO 0.
				SET vSteering TO HEADING(TARGET:HEADING-90,vPitch).				
			}
			SET vOffSetHeading TO fGetHeadingOffset(vHeadingReal,TARGET:HEADING).		
			IF ABS(vOffSetHeading) < 0.01 {
				SET vReadyToBurn TO 1.
			}.
			fPrint().
			WAIT 0.001.
		}.
		SET vThrottle TO 0.
				
		SET vRunMode TO 500.
	}.
		
	// 900 - Landed
	IF vRunMode = 900 {
		SET vLogMode TO vLogMode + "|" + vRunMode.
		SET vAction TO "Landed".
		SET vAction2 TO "                                         ".
		
		fPrint(). 
		
		UNLOCK THROTTLE.
		UNLOCK STEERING.
		SET STEERING TO UP.
		SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
			
		SET vRunMode TO -1.
	}.
	
}.


DECLARE FUNCTION fPrint {
	PRINT "Action:      >> " + vAction + "               " AT (0,3).
	PRINT "                " + vAction2 + "              " AT (0,4).
	PRINT "RunMode:        " + VLogMode + "     " AT (0,6).
	PRINT "AltRadar:       " + ROUND(ALT:RADAR,2) + "     " AT (0,7).
	PRINT "AltReal:        " + ROUND(vAltReal,2) + "     " AT (0,8).
	PRINT "VerticalSpeed:  " + ROUND(SHIP:VERTICALSPEED,2) + "     " AT (0,9).	
	PRINT "GroundSpeed:    " + ROUND(SHIP:GROUNDSPEED,2) + "     " AT (0,10).	
	PRINT "DecentSpeed:    " + ROUND(vCurrentDecentSpeed,2) + "     " AT (0,11).
	PRINT "TargetSpeed:    " + ROUND(vTargetSpeed,2) + "     " AT (0,12).	
	PRINT "TWR:            " + ROUND(vTWR,2) + "     " AT (0,13).
	PRINT "Throttle:       " + ROUND(vThrottle,5) + "       " AT (0,14).
	PRINT "vHeight:        " + ROUND(vHeight,2) + "     " AT (0,15).
	PRINT "vDistance:      " + ROUND(vDistance,2) + "     " AT (0,16).
	PRINT "DistToTarget:   " + ROUND(vDistanceToTarget,2) + "     " AT (0,17).
	PRINT "Target Heading: " + ROUND(vHeading,2) + "     " AT (0,18).
	PRINT "Real Heading:   " + ROUND(vHeadingReal,2) + "     " AT (0,19).
	PRINT "vHere:          " + ROUND(vHere,2) + "     " AT (0,20).
	PRINT "vPitch:         " + ROUND(vPitch,2) + "     " AT (0,21).
	PRINT "vMaxPitch:      " + ROUND(vMaxPitch,2) + "     " AT (0,22).
	PRINT "vAlignment:     " + ROUND(vAlignment,2) + "     " AT (0,23).
	PRINT "vAG:            " + vAG + "  " AT (0,24).				
	
	IF vLandMode = "LandTargetFromOrbit" AND vRunMode = 500 {	
		PRINT "vMaxAccel = " + ROUND(vMaxAccel,2) + "      " AT (0,26).
		PRINT "vBurnTime = " + ROUND(vBurnTime,2) + "      " AT (0,27).
		PRINT "vBurnDist = " + ROUND(vBurnDist,2) + "      " AT (0,28).				
	}.
	
	IF vRunMode = 300 {
		PRINT "Predetection: " + ROUND(SHIP:GROUNDSPEED,2) + "   " AT (0,26).
		PRINT "Detected Heading Change: " + ROUND(SHIP:GROUNDSPEED,2) + "   " AT (0,27).			
	}.

	IF vRunMode = 410 {
		PRINT "Start Landing GroundSpeed: " + ROUND(SHIP:GROUNDSPEED,2) + "   " AT (0,30).
		PRINT "During Landing GroundSpeed: " + ROUND(SHIP:GROUNDSPEED,2) + "   " AT (0,31).			
	}.

	IF vRunMode = 600 {	
		PRINT "Deorbit Target Offset: " + ROUND(vOffSetHeading,3) + "     " AT (0,30).		
	}.
	
	IF vRunMode = 900 {
		PRINT "Finished GroundSpeed: " + ROUND(SHIP:GROUNDSPEED,2) + "   " AT (0,32).
	}.
}.








