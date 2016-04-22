// A LIBRARY OF ROUTINES TO HELP DO BASIC PHYSICS CALCULATIONS

// RETURN THE GRAVITY ACCELERATION AT SHIP'S CURRENT LOCATION.
DECLARE FUNCTION fGHere {
  RETURN CONSTANT:G * ((SHIP:BODY:MASS)/((SHIP:ALTITUDE + BODY:RADIUS)^2)).
}.

// RETURN THE FORCE ON SHIP DUE TO GRAVITY ACCELERATION AT SHIP'S CURRENT LOCATION.
DECLARE FUNCTION fFGHere {
  RETURN SHIP:MASS * fGHere().
}.

// Return the actual compass heading of the ship
DECLARE FUNCTION fGetRealHeading {
	SET vEast TO VCRS(UP:VECTOR, NORTH:VECTOR).
	SET vTrigX TO VDOT(NORTH:VECTOR, SRFPROGRADE:VECTOR).
	SET vTrigY TO VDOT(vEast, SRFPROGRADE:VECTOR).
	SET vRealHeading TO MOD((ARCTAN2(vTrigY,vTrigX)+360),360).
	RETURN vRealHeading.
}.

DECLARE FUNCTION fHeadingDifference {
	DECLARE PARAMETER vHeading1.
	DECLARE PARAMETER vHeading2.
	SET vAngle TO ABS(vHeading1-vHeading2).
	IF vAngle > 180 {
		RETURN 360 - vAngle.
	} ELSE {
		RETURN vAngle.
	}	
}.

DECLARE FUNCTION fGetHeadingOffset {
	DECLARE PARAMETER vHeading1.
	DECLARE PARAMETER vHeading2.
	
	SET vAngle TO vHeading1-vHeading2.
	IF ABS(vAngle) > 180 AND vAngle<0 {
		RETURN -360 - vAngle.
	}.
	IF ABS(vAngle) <= 180 AND vAngle<0 {
		RETURN vAngle.
	}.
	IF ABS(vAngle) >= 180 AND vAngle>=0 {
		RETURN 360 - vAngle.
	}.
	IF ABS(vAngle) <= 180 AND vAngle>=0 {
		RETURN vAngle.
	}.
	
	// If we have missed something !!!
	RETURN vAngle.
}.
