// 0	1x
// 1	5x
// 2	10x
// 3	50x
// 4	100x
// 5	1000x
// 6	10000x
// 7	100000x


DECLARE PARAMETER vDateTime.

SET vDateTime TO ROUND(vDateTime).
SET vTime0 TO ROUND(TIME:SECONDS).
SET vTime1 TO vTime0 + vDateTime.

UNTIL TIME:SECONDS > vTime1 {

	IF TIME:SECONDS > vTime1 - 1000000 {
		SET WARP TO 7.
	}.

	IF TIME:SECONDS > vTime1 - 100000 {
		SET WARP TO 6.
	}.

	IF TIME:SECONDS > vTime1 - 10000 {
		SET WARP TO 5.
	}.

	IF TIME:SECONDS > vTime1 - 1000 {
		SET WARP TO 4.
	}.

	IF TIME:SECONDS > vTime1 - 500 {
		SET WARP TO 3.
	}.

	IF TIME:SECONDS > vTime1 - 100 {
		SET WARP TO 2.
	}.

	IF TIME:SECONDS > vTime1 - 50 {
		SET WARP TO 1.
	}.

	IF TIME:SECONDS > vTime1 - 10 {
		SET WARP TO 0.
	}.

	fPrint().
	WAIT 0.001.
}.

