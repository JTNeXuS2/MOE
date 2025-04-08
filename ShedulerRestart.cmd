@echo off
cd %~dp0
chcp 65001
setlocal enabledelayedexpansion
title "MOE ShedulerRestart"

:: Run once to setup script in to windows task sheduler (taskschd.msc) 11:50 Autorun
schtasks /query /tn "MOE.Restart"
echo %errorlevel%
if %errorlevel% == 1 (
    echo Task not found. Adding task to the scheduler...
    schtasks /create /F /tn "MOE.Restart" /tr "%~dp0ShedulerRestart.cmd" /sc daily /st 11:50
	echo exit
	timeout /t 5
	exit
)

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

set "clusterpath=C:\moe_cluster"
set "mcrcon_dir=%clusterpath%\rcon"
set "ConfigFile=%clusterpath%\MatrixServerTool\ServerParamConfig_All.ini"

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

echo Saving Worlds....
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8012 -p %rcon_pass% SaveWorld
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8022 -p %rcon_pass% SaveWorld
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8032 -p %rcon_pass% SaveWorld
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8042 -p %rcon_pass% SaveWorld

%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 6003 -p %rcon_pass% SaveWorld
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 6014 -p %rcon_pass% SaveWorld
timeout /t 60

echo Exiting Worlds...
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8012 -p %rcon_pass% ShutdownServer
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8022 -p %rcon_pass% ShutdownServer
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8032 -p %rcon_pass% ShutdownServer
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8042 -p %rcon_pass% ShutdownServer

goto SKIP_LOBBY
echo Stop Lobby and Pub
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 6003 -p %rcon_pass% ShutdownServer
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 6014 -p %rcon_pass% ShutdownServer
:SKIP_LOBBY

echo Stop BG
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 7012 -p %rcon_pass% ShutdownServer
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 7022 -p %rcon_pass% ShutdownServer
TIMEOUT /t 20

:Secondkill
:: second HARD kill if rcon not response
set "WindowTitle=SessionName-SceneServer"
for /f "tokens=1 delims==" %%i in (%ConfigFile%) do (
    if "%%i" neq "[SceneServerList]" (
        set "serverid=%%i"
        set "WindowTitle=SessionName-SceneServer_%serverid% ServerId-%serverid%"
		::powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Host $_.Id}"
        powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Stop-Process -Id $_.Id}"
		timeout /t 1 >nul
    )
	goto Next
)

:Next
echo Start Claster
call "%clusterpath%\scripts\^!START_CLUSTER.cmd"
timeout /t 3
EXIT
