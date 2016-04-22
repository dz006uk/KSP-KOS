DECLARE FUNCTION fGetDescentSpeed {
	DECLARE PARAMETER vCurrentHeight.
	DECLARE PARAMETER vTWR.

	IF ORBIT:BODY:NAME = "Minmus" {
		RETURN 0-MAX(1,((vCurrentHeight/200)*vTWR)).
	}.

	IF ORBIT:BODY:NAME = "Ike" {
		RETURN 0-MAX(1,((vCurrentHeight/150)*vTWR)).
	}.

	
	IF ORBIT:BODY:NAME = "Mun" {
		IF vCurrentHeight < 3000 {
			RETURN 0-MAX(1,MIN(50,((vCurrentHeight/100)*vTWR))).
		}.
		RETURN 0-MAX(1,((vCurrentHeight/100)*vTWR)).
	}.

	IF ORBIT:BODY:NAME = "Kerbin" {
		IF vCurrentHeight < 3000 {
			RETURN 0-MAX(1,MIN(50,((vCurrentHeight/100)*vTWR))).
		}.
		RETURN 0-MAX(1,((vCurrentHeight/100)*vTWR)).
	}.
	
	RETURN 0-MAX(1,((vCurrentHeight/100)*vTWR)).
}.

DECLARE FUNCTION fGetTargetHoverHeight {

	IF ORBIT:BODY:NAME = "Minmus" {	
		RETURN (1/vTWR)*16000.		
	}.

	IF ORBIT:BODY:NAME = "Ike" {	
		RETURN (1/vTWR)*16000.		
	}.

	IF ORBIT:BODY:NAME = "Mun" {	
		RETURN (1/vTWR)*16000.		
	}.
	
	RETURN (1/vTWR)*16000.		
}.

DECLARE FUNCTION fGetTargetMoveAngle {

	IF ORBIT:BODY:NAME = "Minmus" {	
		RETURN MIN(85,MAX(45,(90-vTWR))).
	}.

	IF ORBIT:BODY:NAME = "Ike" {	
		RETURN MIN(85,MAX(45,(90-vTWR))).
	}.

	IF ORBIT:BODY:NAME = "Mun" {	
		RETURN MIN(85,MAX(45,(90-vTWR))).
	}.
	
	RETURN MIN(85,MAX(45,(90-vTWR))).
}.

DECLARE FUNCTION fGetPIDSettings {
	DECLARE PARAMETER vPID.

	IF ORBIT:BODY:NAME = "Minmus" {
	
		IF vPID = "PHOVER" { RETURN 0.02. }.
		IF vPID = "IHOVER" { RETURN 0.05. }.
		IF vPID = "DHOVER" { RETURN 0.05. }.
		
		IF vPID = "PSPEED" { RETURN 1.00. }.
		IF vPID = "ISPEED" { RETURN 0.05. }.
		IF vPID = "DSPEED" { RETURN 0.05. }.
		
		IF vPID = "PDEORBIT" { RETURN 1.00. }.
		IF vPID = "IDEORBIT" { RETURN 0.05. }.
		IF vPID = "DDEORBIT" { RETURN 0.05. }.
		
		RETURN 0.05.
	}.

	IF ORBIT:BODY:NAME = "Ike" {
	
		IF vPID = "PHOVER" { RETURN 0.02. }.
		IF vPID = "IHOVER" { RETURN 0.05. }.
		IF vPID = "DHOVER" { RETURN 0.05. }.
		
		IF vPID = "PSPEED" { RETURN 1.00. }.
		IF vPID = "ISPEED" { RETURN 0.05. }.
		IF vPID = "DSPEED" { RETURN 0.05. }.
		
		IF vPID = "PDEORBIT" { RETURN 1.00. }.
		IF vPID = "IDEORBIT" { RETURN 0.05. }.
		IF vPID = "DDEORBIT" { RETURN 0.05. }.
		
		RETURN 0.05.
	}.
	
	IF ORBIT:BODY:NAME = "Mun" {
		
		IF vPID = "PHOVER" { RETURN 0.02. }.
		IF vPID = "IHOVER" { RETURN 0.05. }.
		IF vPID = "DHOVER" { RETURN 0.05. }.
		
		IF vPID = "PSPEED" { RETURN 1.00. }.
		IF vPID = "ISPEED" { RETURN 0.05. }.
		IF vPID = "DSPEED" { RETURN 0.05. }.
		
		IF vPID = "PDEORBIT" { RETURN 1.00. }.
		IF vPID = "IDEORBIT" { RETURN 0.05. }.
		IF vPID = "DDEORBIT" { RETURN 0.05. }.
				
		RETURN 0.05.
	}.
	
	IF ORBIT:BODY:NAME = "Kerbin" {
		
		IF vPID = "PHOVER" { RETURN 0.02. }.
		IF vPID = "IHOVER" { RETURN 0.05. }.
		IF vPID = "DHOVER" { RETURN 0.05. }.
		
		IF vPID = "PSPEED" { RETURN 0.02. }.
		IF vPID = "ISPEED" { RETURN 0.05. }.
		IF vPID = "DSPEED" { RETURN 0.05. }.
		
		IF vPID = "PDEORBIT" { RETURN 1.00. }.
		IF vPID = "IDEORBIT" { RETURN 0.05. }.
		IF vPID = "DDEORBIT" { RETURN 0.05. }.
				
		RETURN 0.05.
	}.
	
		IF vPID = "PHOVER" { RETURN 0.02. }.
		IF vPID = "IHOVER" { RETURN 0.05. }.
		IF vPID = "DHOVER" { RETURN 0.05. }.
		
		IF vPID = "PSPEED" { RETURN 1.00. }.
		IF vPID = "ISPEED" { RETURN 0.05. }.
		IF vPID = "DSPEED" { RETURN 0.05. }.
		
		IF vPID = "PDEORBIT" { RETURN 1.00. }.
		IF vPID = "IDEORBIT" { RETURN 0.05. }.
		IF vPID = "DDEORBIT" { RETURN 0.05. }.
				
		RETURN 0.05.

	
}.
		
		
		
		