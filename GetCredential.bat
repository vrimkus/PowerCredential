@ECHO OFF


IF [%1]==[] GOTO :INVALID
GOTO :MAIN


:INVALID
ECHO.
ECHO Invalid argument specified
ECHO --------------------------------
ECHO Usage:
ECHO.
ECHO 	CALL GetCredential.bat username passwordvar
ECHO.
ECHO 	ECHO %%passwordvar%%	(Will display received password value)
ECHO.
ECHO Key:
ECHO 	username	A valid UserName for a cached PowerCredential 
ECHO 	passwordvar	Name of variable for storing received password value
GOTO:EOF


:MAIN
SET "psCommand=powershell -NoProfile -ExecutionPolicy Bypass -Command "(Get-PowerCredential '%1').GetNetworkCredential().Password""
FOR /F "delims=" %%G IN ('%psCommand%') DO SET "PowerCredential=%%G"
SET "%~2=%PowerCredential%"
GOTO:EOF

