//dzNode1
CLEARSCREEN.
SET WARP TO 0.
RUN dzPhysics.
RUN dzCommon.

UNTIL SHIP:AVAILABLETHRUST > 0 {
	WAIT 0.5.
	STAGE.
}.

SET vNodeCompleteText TO " ".

SET X TO NEXTNODE.

SET vDeltaV0 TO X:DELTAV.
SET vThrottle TO 0.

LOCK vVDOTdv TO VDOT(vDeltaV0, X:DELTAV).
LOCK THROTTLE TO vThrottle.
LOCK vAcceleration TO MAX(1,SHIP:AVAILABLETHRUST)/SHIP:MASS.
LOCK vTWR TO MAX(1,SHIP:AVAILABLETHRUST)/fFGHere().
LOCK STEERING TO LOOKDIRUP(X:DELTAV, SHIP:FACING:TOPVECTOR).
LOCK vAlignment TO ABS(COS(FACING:PITCH) - COS(STEERING:PITCH)) + ABS(SIN(FACING:PITCH) - SIN(STEERING:PITCH)) + ABS(COS(FACING:YAW) - COS(STEERING:YAW)) + ABS(SIN(FACING:YAW) - SIN(STEERING:YAW)).
LOCK vBurnDuration TO X:DELTAV:MAG/MAX(0.01,vAcceleration).
LOCK vTimeToBurn TO (X:ETA - (vBurnDuration/2)) + ((vBurnDuration/2)*0.1).

SET vAction TO "Initial Node Alignment (0.1)".
UNTIL vAlignment < 0.1 {
	fPrint().
	WAIT 0.001.
}.

SET vAction TO "Warp to 60s before burn".
fPrint().
fWarp(X:ETA - (vBurnDuration/2) - 60,10).
UNTIL vTimeToBurn < 60 {
	fPrint().
	WAIT 0.001.	
}.
SET WARP TO 0.
WAIT 1.

SET vAction TO "Realign before final warp (0.1)".
fPrint().
UNTIL vAlignment < 0.1 {
	fPrint().
	WAIT 0.001.
}.

SET vAction TO "Warp to 10s before burn".
fPrint().
fWarp(X:ETA - (vBurnDuration/2) - 10,10).
UNTIL vTimeToBurn < 10 {
	fPrint().
	WAIT 0.001.	
}.
SET WARP TO 0.
WAIT 1.

SET vAction TO "Coasting to Burn...".
fPrint().
UNTIL vTimeToBurn < 0 AND vAlignment < 1 {
	fPrint().
	WAIT 0.001.
}.

SET bDone TO FALSE.
SET vAction TO "Execute burn".
UNTIL bDone {

	SET vThrottle TO MIN(1,MAX(0.05,X:DELTAV:MAG/vAcceleration/2)).		
	
	IF vVDOTdv < 0
    {
		SET vThrottle TO 0.
		SET vNodeCompleteText TO "VDOT Check".
		fPrint().
		SET bDone TO TRUE.
        BREAK.
    }.
		
	IF X:DELTAV:MAG < 0.1 AND vVDOTdv < 0.5 {
		SET vThrottle TO 0.
		SET vNodeCompleteText TO "MAG and VDOT Check".
		fPrint().
		SET bDone TO TRUE.	
        BREAK.
	}
	
	fAutoStage().
	fPrint().
	WAIT 0.001.
}.	

SET vAction TO "Burn Complete".
fPrint().

UNLOCK STEERING.
UNLOCK THROTTLE.
REMOVE X.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

DECLARE FUNCTION fPrint {
	PRINT "Action        >> " + vAction + "          " AT (0,20).	
	PRINT "Time until burn: " + ROUND(vTimeToBurn) + "     " AT (0,22).
	PRINT "Burn duration:   " + ROUND(vBurnDuration,2) + "s      " AT (0,23).
	PRINT "Node ETA:        " + ROUND(X:ETA) + "     " AT (0,24).
	PRINT "Node alignment:  " + ROUND(vAlignment,2) + "     " AT (0,25).
	PRINT "Throttle:        " + ROUND(vThrottle,4) + "     " AT  (0,26).
	PRINT "X:DELTAV:MAG:    " + ROUND(X:DELTAV:MAG,2) + "     " AT (0,27).
	PRINT "vVDOTdv:         " + ROUND(vVDOTdv,2) + "     " AT (0,28).
	PRINT "Node Complete:   " + vNodeCompleteText AT (0,29).
}.
			
