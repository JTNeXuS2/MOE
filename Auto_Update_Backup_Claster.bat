@echo off
chcp 65001>nul
setlocal enabledelayedexpansion

set rcon_pass=SUPERRCONPASSWORD


set steamAppID=1794810
set clearCache=1
set root=C:\moe_cluster
set serverPath=%root%\moe
set steamCMDPath=%root%\steamcmd
set rconPath=%root%\rcon
set scriptPath=%root%\scripts
set "backupDir=%serverPath%\ServerBackups"
set "pack=%serverPath%\moe\Saved\SaveGames"

set dataPath=%serverPath%\updatedata
set steamcmdExec="%steamCMDPath%\steamcmd.exe"
set steamcmdCache="%steamCMDPath%\appcache"
set latestAppInfo=%dataPath%\latestappinfo.json
set updateinprogress="%serverPath%\updateinprogress.dat"
set latestAvailableUpdate="%dataPath%\latestavailableupdate.txt"
set latestInstalledUpdate="%dataPath%\latestinstalledupdate.txt"


mode con:cols=70 lines=8
cd "%root%\"
if not exist "%backupDir%" (mkdir "%backupDir%")

:: TIMERS in minutes
set "updater=10"
set "backaper=30"
set "offline=4"

::test anonc
::set WEBHOOK_URL=https://discord.com/api/webhooks/1196595006593573024/78mSn0j_eoAb0xI7BGNzLAzww2JGYuj8pDYRC79eyuXgrr6REuyQbG3qeQ6GifQvQg92
set WEBHOOK_URL=https://discord.com/api/webhooks/1222834102860910603/_gC9JZOK9Q2TpGmNBwffffffffffffffffffffffffddddddddddd

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
cls
echo backing up...
for /f "tokens=1-5 delims=/:. " %%d in ("%date% %time%") do set "datetime=%%d.%%e.%%f__%%g;%%h"
PowerShell.exe -command "Set-Location '%root%'; Compress-Archive -Path '%pack%' -DestinationPath '%backupDir%\%datetime%.zip' -CompressionLevel Optimal -Force"
echo complete!
:Cleanup
echo cleaning up old backups...
PowerShell.exe -command "Set-Location '%backupDir%'; Get-ChildItem -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | Remove-Item"
echo cleanup complete!
timeout /t 3
goto Delay

:Update
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
	if exist %latestInstalledUpdate% (
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
	if "!availableVersion!" == "" (
	    echo Update NOT AVAILEBLE. check steam connection
	    timeout /t 3
	    del /F %updateinprogress%
	    goto Delay
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

:Kill
color 0C
echo ====== Update Available ======
echo Installed: !installedVersion! - available: !availableVersion!
echo.
echo %DATE% %TIME% UPDATE FOUND, PREPARING FOR RESTART!
timeout /t 60
echo Discord annonce 1
set "MESSAGE=@here\n Обнаружено обновление^!\n Кластер будет перезагружен через 10 минут^!"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"!MESSAGE!\"}" !WEBHOOK_URL!
set "rconmessage=Рестарт через 10 минут"
%rconPath%\PyRcon.exe -ip 65.109.113.61 -p 8012 -pass "%rcon_pass%" -c BroadcastNotifySysInfo ^\"!rconmessage!\" 1 0
%rconPath%\PyRcon.exe -ip 65.109.113.61 -p 8022 -pass "%rcon_pass%" -c BroadcastNotifySysInfo ^\"!rconmessage!\" 1 0
%rconPath%\PyRcon.exe -ip 65.109.113.61 -p 8032 -pass "%rcon_pass%" -c BroadcastNotifySysInfo ^\"!rconmessage!\" 1 0
timeout /t 300

echo Discord annonce 2
set "MESSAGE= Обнаружено обновление^!\n Кластер будет перезагружен через 5 минут^!"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"!MESSAGE!\"}" !WEBHOOK_URL!
set "rconmessage=Рестарт через 5 минут"
%rconPath%\PyRcon.exe -ip 65.109.113.61 -p 8012 -pass "%rcon_pass%" -c BroadcastNotifySysInfo ^\"!rconmessage!\" 1 0
%rconPath%\PyRcon.exe -ip 65.109.113.61 -p 8022 -pass "%rcon_pass%" -c BroadcastNotifySysInfo ^\"!rconmessage!\" 1 0
%rconPath%\PyRcon.exe -ip 65.109.113.61 -p 8032 -pass "%rcon_pass%" -c BroadcastNotifySysInfo ^\"!rconmessage!\" 1 0
timeout /t 240

echo Discord annonce 3
set "MESSAGE=@here\n Обнаружено обновление^!\n Кластер будет перезагружен через 1 минуту^!"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"!MESSAGE!\"}" !WEBHOOK_URL!
set "rconmessage=Рестарт через 1 минуту"
%rconPath%\PyRcon.exe -ip 65.109.113.61 -p 8012 -pass "%rcon_pass%" -c BroadcastNotifySysInfo ^\"!rconmessage!\" 1 0
%rconPath%\PyRcon.exe -ip 65.109.113.61 -p 8022 -pass "%rcon_pass%" -c BroadcastNotifySysInfo ^\"!rconmessage!\" 1 0
%rconPath%\PyRcon.exe -ip 65.109.113.61 -p 8032 -pass "%rcon_pass%" -c BroadcastNotifySysInfo ^\"!rconmessage!\" 1 0
timeout /t 60

echo Saving Worlds....
echo BattleServer
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 7012 -p "%rcon_pass%" SaveWorld
echo Lobby
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 6003 -p "%rcon_pass%" SaveWorld
echo Pub
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 6014 -p "%rcon_pass%" SaveWorld
echo Scene 100
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 8012 -p "%rcon_pass%" SaveWorld
echo Scene 200
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 8022 -p "%rcon_pass%" SaveWorld
echo Scene 300
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 8032 -p "%rcon_pass%" SaveWorld
echo Exiting Worlds...
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 7012 -p "%rcon_pass%" ShutdownServer
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 6003 -p "%rcon_pass%" ShutdownServer
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 6014 -p "%rcon_pass%" ShutdownServer
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 8012 -p "%rcon_pass%" ShutdownServer
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 8022 -p "%rcon_pass%" ShutdownServer
%rconPath%\mcrcon.exe -H 65.109.113.61 -P 8032 -p "%rcon_pass%" ShutdownServer
TIMEOUT /t 10
:: second HARD kill if rcon not response
taskkill /f /im MOEServer.exe

echo Starting Update....This could take a few minutes...
%steamcmdExec% +force_install_dir %serverPath% +login anonymous +app_update %steamAppID% validate +quit>%latestAppInfo%
echo !availableVersion!>%latestInstalledUpdate%
echo Update Done!
del /F %updateinprogress%
timeout /t 10
goto offline
