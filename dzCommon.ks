DECLARE FUNCTION fWarp {
	DECLARE PARAMETER vDateTime.
	DECLARE PARAMETER vBuffer IS 10.

	SET vDateTime TO ROUND(vDateTime).
	SET vTime0 TO ROUND(TIME:SECONDS).
	SET vTime1 TO vTime0 + vDateTime.
	
	IF vDateTime > vBuffer {
		WARPTO(vTime1).
	}.
}.

DECLARE FUNCTION fAutoStage_old {
	DECLARE PARAMETER vAutoStage IS 0.
	
	IF vAutoStage = 1 {
		LIST ENGINES IN engines.
		FOR eng IN engines {
			IF eng:FLAMEOUT {
				STAGE.
				WAIT 1.
				BREAK.
			}.
		}.
		UNTIL SHIP:AVAILABLETHRUST > 0 {
			STAGE.
			WAIT 1.	
		}.
	}.
}.

DECLARE FUNCTION fAutoStage {
	DECLARE PARAMETER vAutoStage IS 1.

	IF vAutoStage = 1 {

		SET bStaged TO FALSE.
		
		LIST ENGINES IN lEngines.
		FOR vEngine IN lEngines {
			IF vEngine:FLAMEOUT AND bStaged = FALSE {
				STAGE.
				WAIT 1.
				SET bStaged TO TRUE.
				BREAK.
			}.
		}.
	
//	
// NEEDS FIXING BY ENSURING THAT ALL PARTS OF THE STAGE ARE EMPTY
//

//		SET lParts TO SHIP:PARTS.		
//		FOR vPart IN lParts {
//			IF vPart:STAGE >= STAGE:NUMBER AND vPart:NAME:STARTSWITH("fuelTank") {					
//				SET lResource TO vPart:RESOURCES.				
//				FOR vResource IN lResource {
//					IF vResource:AMOUNT = 0 AND bStaged = FALSE {				
//						STAGE.
//						WAIT 1.
//						SET bStaged TO TRUE.
//						BREAK.
//					}.
//				}.
//			}.
//		}.
		
		IF SHIP:AVAILABLETHRUST = 0 AND bStaged = FALSE {
			STAGE.
			WAIT 1.	
			SET bStaged TO TRUE.
			
		}.

	}.
}.

DECLARE FUNCTION fNotify {
	DECLARE PARAMETER vMessage.
	HUDTEXT(vMessage, 10, 2, 32, YELLOW, false).
}.
