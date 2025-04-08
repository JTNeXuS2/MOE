@echo off
chcp 65001>nul
mode con:cols=70 lines=8

setlocal enabledelayedexpansion

:: ===== FUNCTIONS read config ======================================
set "config_file=%~dp0demon.cfg"
goto SKIP_FUNCTIONS
:read_param
set "getparam=%~1"
for /f "delims=" %%a in ('powershell -Command "(Get-Content -Encoding UTF8 '%config_file%' | Where-Object {$_ -match '^\s*%getparam%='}) -replace '.*=', ''"') do (
    set "%getparam%=%%a"
)
exit /b
:SKIP_FUNCTIONS
call :read_param WEBHOOK_URL
call :read_param rcon_host
call :read_param rcon_pass
call :read_param MESSAGE1
call :read_param MESSAGE2
call :read_param MESSAGE3
call :read_param rconmessage1
call :read_param rconmessage2
call :read_param rconmessage3
:: ===== FUNCTIONS read config END ======================================

:: TIMERS in minutes for cycles
set "updater=10"
set "backaper=30"
set "offline=1"

set steamAppID=1794810
set clearCache=1
set root=C:\moe_cluster
set serverPath=%root%\moe
set steamCMDPath=%root%\steamcmd
set rconPath=%root%\rcon
set scriptPath=%root%\scripts
set "backupDir=%serverPath%\ServerBackups"
set "pack=%serverPath%\moe\Saved\SaveGames"
set "sql=%root%\mysql"

set dataPath=%serverPath%\updatedata
set steamcmdExec="%steamCMDPath%\steamcmd.exe"
set steamcmdCache="%steamCMDPath%\appcache"
set latestAppInfo=%dataPath%\latestappinfo.json
set updateinprogress="%serverPath%\updateinprogress.dat"
set latestAvailableUpdate="%dataPath%\latestavailableupdate.txt"
set latestInstalledUpdate="%dataPath%\latestinstalledupdate.txt"

cd "%root%\"
if not exist "%backupDir%" (mkdir "%backupDir%")

set "counterone=%updater%"
set "countertwo=0"
set "counter3=0"

rem Set Title
set Title=MOE Cluster Backaper Updater on %~dp0
rem ________________
rem BEGIN BATCH CODE
rem ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
cls

title %Title%
color 0A
:Backup
title %Title%
cls
echo backing up...
if exist "%pack%\SQL_backup" (rd /s /q "%pack%\SQL_backup")
if not exist "%pack%\SQL_backup" (mkdir "%pack%\SQL_backup")
xcopy "%sql%\data\*" "%pack%\SQL_backup\data\" /s /e /i /y
for /f "tokens=1-5 delims=/:. " %%d in ("%date% %time%") do set "datetime=%%d.%%e.%%f__%%g;%%h"
PowerShell.exe -command "Set-Location '%root%'; Compress-Archive -Path '%pack%' -DestinationPath '%backupDir%\%datetime%.zip' -CompressionLevel Optimal -Force"
echo complete!
:Cleanup
echo cleaning up old backups...
PowerShell.exe -command "Set-Location '%backupDir%'; Get-ChildItem -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | Remove-Item"
echo cleanup complete!
timeout /t 3

:unbanips
netsh advfirewall firewall delete rule name="Block Specific IP"
goto Delay

:Update
title %Title%
color 0E
echo.
echo %DATE% %TIME% Checking For Update
setlocal enabledelayedexpansion

:: Check update
if exist %updateinprogress% (
    echo Update is already in progress and could be interrupted.
) else (
    echo %date% %time% > %updateinprogress%
    echo Creating data directory...
    if not exist %dataPath% mkdir %dataPath%
    if %clearCache% equ 1 (
        echo Removing Cache %steamcmdCache%
        rmdir %steamcmdCache% /s /q
    )
    echo Checking for an update for %serverPath%

	%steamcmdExec% +login anonymous +app_info_update 1 +app_info_print %steamAppID% +app_info_print %steamAppID% +logoff +quit>%latestAppInfo%
	
	:: Get Build Version
	set installedVersion=0
	for /f "usebackq tokens=* delims=" %%a in ("%latestAppInfo%") do (
	    echo %%a | find "buildid" > nul && set availableVersion=%%a
	)
	for /f "tokens=2 delims=	" %%a in ("!availableVersion!") do (
	    set availableVersion=%%a
	    set "availableVersion=!availableVersion:"=!"
	    echo !availableVersion!>%latestAvailableUpdate%
	)
	if exist %latestInstalledUpdate%.DISABLED (
	    for /f "usebackq tokens=*" %%i in (%latestInstalledUpdate%) do (
	        set installedVersion=%%i
	    )
	) else (
		::::::: 2way
		echo Alternative way get build in %serverPath%\steamapps\appmanifest_1794810.acf
		for /f "usebackq tokens=* delims=" %%a in ("%serverPath%\steamapps\appmanifest_1794810.acf") do (
		    echo %%a | find "buildid" > nul && set installedVersion=%%a
		)
		for /f "tokens=2 delims=	" %%a in ("!installedVersion!") do (
		    set installedVersion=%%a
		    set "installedVersion=!installedVersion:"=!"
		    echo !installedVersion!>%latestInstalledUpdate%
		    echo Installed: in %serverPath%\steamapps\appmanifest_1794810.acf
		    echo version: !installedVersion! - available: !availableVersion!
		)
	)
	:2way
	if "!availableVersion!" == "" (
	    echo Update NOT AVAILEBLE. check steam connection
	    echo try secondway check
	    timeout /t 3
	    del /F %updateinprogress%
	    ::goto Delay
	    goto recheck
	) else (
	    if "!installedVersion!" neq "!availableVersion!" (
	        goto Kill
	    ) else (
	        echo =================================
	        echo Installed: !installedVersion!        ^|^|
	        echo Available: !availableVersion!        ^|^|
	        echo =================================
	        echo.
	    )
)
	del /F %updateinprogress%
)
echo Update Completed
timeout /t 10
::::::::::::::::::::::::::::::::::::::::::::::::::::::

:offline
color 0F
::check daily restart
set "WindowTitle=MOE ShedulerRestart" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found
    echo ==== Check offline Server ====
    call "%scriptPath%\^!START_CLUSTER.cmd"
	timeout /t 3
)
goto Delay

:: LOOP TIMER
:Delay
title %Title%
cls
color 0A
echo %DATE% %TIME% Running
set /a result1=%updater% - %counterone%
echo check update after %result1% minutes

set /a result2=%backaper% - %countertwo%
echo Backup after %result2% minutes

set /a result3=%offline% - %counter3%
echo Offliners check after %result3% minutes
echo waiting...
timeout /t 60

if %result1% lss 1 (
    set "counterone=0"
    set /a "countertwo+=1"
    set /a "counter3+=1"
	goto Update
)
if %result2% lss 1 (
    set "countertwo=0"
    set /a "counterone+=1"
    set /a "counter3+=1"
	goto Backup
)
if %result3% lss 1 (
    set "counter3=0"
    set /a "counterone+=1"
    set /a "countertwo+=1"
	goto offline
)
set /a "counterone+=1"
set /a "countertwo+=1"
set /a "counter3+=1"
del /F %updateinprogress%>nul
goto Delay

EXIT

:recheck
::setlocal EnableDelayedExpansion
set tmp_json="%dataPath%\temp.json"
for /f %%x in ('powershell -command "Get-Date -format 'dd.MM.yyyy HH:mm:ss'"') do set datetime=%%x
set "date_time=%datetime% %TIME%"
if exist "%latestinstalledupdate%" (set /p oldsteamdate=<"%latestinstalledupdate%")
cls
echo Versions

curl -s https://api.steamcmd.net/v1/info/%steamAppID% > %tmp_json%.tmp
powershell -command "Get-Content -Path '%tmp_json%.tmp' | ConvertFrom-Json | ConvertTo-Json -Depth 100 | Out-File -FilePath '%tmp_json%' -Encoding utf8"
del %tmp_json%.tmp
echo.
set "availableVersion="
for /f "usebackq tokens=*" %%a in (%tmp_json%) do (
    if "%%a" neq "" (
        echo %%a | findstr /C:"buildid" > nul && (
            for /f "tokens=2 delims=: " %%b in ("%%a") do (
                set "availableVersion=%%b"
                set "availableVersion=!availableVersion:"=!"
                set "availableVersion=!availableVersion:,=!"
            )
        )
    )
)
::for /F "tokens=*" %%F in ('curl -s https://api.steamcmd.net/v1/info/%steamAppID%') do set string=%%F
::set status=%string:~-9,7%
::set availableVersion=%string:~-38,10%
echo OLD:%oldsteamdate%
echo NEW:%availableVersion%
::title OLD:%oldsteamdate% NEW:%availableVersion%
if "%availableVersion%" == "Internal S" echo "%availableVersion%" Error get version, check again & timeout /t 60 & goto Delay
if not "%oldsteamdate%"=="" if not "%availableVersion%"=="" if not "%availableVersion%"=="%oldsteamdate%" echo GO UPDATE availableVersion:%availableVersion% - oldsteamdate:%oldsteamdate% & timeout /t 3 & goto Kill
set oldsteamdate=%availableVersion%
echo write to file %availableVersion%
echo %availableVersion%>%latestAvailableUpdate%
timeout /t 3
goto Delay

:Kill

color 0C
echo ====== Update Available ======
echo Installed: !installedVersion! - available: !availableVersion!
echo.
echo %DATE% %TIME% UPDATE FOUND, PREPARING FOR RESTART!
timeout /t 60
:: ANNONCE
echo Discord annonce 1
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"!MESSAGE1!\"}" !WEBHOOK_URL!
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8012 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage1!\" 1 0
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8022 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage1!\" 1 0
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8032 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage1!\" 1 0
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8042 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage1!\" 1 0
timeout /t 300

echo Discord annonce 2
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"!MESSAGE2!\"}" !WEBHOOK_URL!
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8012 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage2!\" 1 0
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8022 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage2!\" 1 0
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8032 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage2!\" 1 0
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8042 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage2!\" 1 0
timeout /t 240

echo Discord annonce 3
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"!MESSAGE3!\"}" !WEBHOOK_URL!
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8012 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage3!\" 1 0
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8022 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage3!\" 1 0
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8032 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage3!\" 1 0
%rconPath%\PyRcon.exe -ip %rcon_host% -p 8042 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"!rconmessage3!\" 1 0
timeout /t 60

echo Saving Worlds....
echo Lobby
%rconPath%\mcrcon.exe -H %rcon_host% -P 6003 -p %rcon_pass% SaveWorld
echo Pub
%rconPath%\mcrcon.exe -H %rcon_host% -P 6014 -p %rcon_pass% SaveWorld
echo Scene 100
%rconPath%\mcrcon.exe -H %rcon_host% -P 8012 -p %rcon_pass% SaveWorld
echo Scene 200
%rconPath%\mcrcon.exe -H %rcon_host% -P 8022 -p %rcon_pass% SaveWorld
echo Scene 300
%rconPath%\mcrcon.exe -H %rcon_host% -P 8032 -p %rcon_pass% SaveWorld
echo Scene 400
%rconPath%\mcrcon.exe -H %rcon_host% -P 8042 -p %rcon_pass% SaveWorld
echo Exiting Worlds...
%rconPath%\mcrcon.exe -H %rcon_host% -P 8012 -p %rcon_pass% ShutdownServer
%rconPath%\mcrcon.exe -H %rcon_host% -P 8022 -p %rcon_pass% ShutdownServer
%rconPath%\mcrcon.exe -H %rcon_host% -P 8032 -p %rcon_pass% ShutdownServer
%rconPath%\mcrcon.exe -H %rcon_host% -P 8042 -p %rcon_pass% ShutdownServer
%rconPath%\mcrcon.exe -H %rcon_host% -P 6003 -p %rcon_pass% ShutdownServer
%rconPath%\mcrcon.exe -H %rcon_host% -P 6014 -p %rcon_pass% ShutdownServer
%rconPath%\mcrcon.exe -H %rcon_host% -P 7012 -p %rcon_pass% ShutdownServer
%rconPath%\mcrcon.exe -H %rcon_host% -P 7022 -p %rcon_pass% ShutdownServer
TIMEOUT /t 20
:: second way HARD kill if rcon not response
taskkill /f /im MOEServer.exe
taskkill /f /im game-opt-sys.exe
taskkill /f /im game-chat-service.exe
taskkill /f /im MatrixServerTool.exe

:START_UPDATE
echo Starting Update....This could take a long time...
%steamcmdExec% +force_install_dir %serverPath% +login anonymous +app_update %steamAppID% validate +quit>%latestAppInfo%
echo !availableVersion!>%latestInstalledUpdate%
echo Update Done!
del /F %updateinprogress%
timeout /t 10
goto offline
