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
    schtasks /create /F /tn "MOE.Restart" /tr "\"%~dp0ShedulerRestart.cmd\"" /sc daily /st 11:50
	echo exit
	timeout /t 5
	exit
)

set "clusterpath=C:\moe_cluster"
set "mcrcon_dir=%clusterpath%\rcon"
set "ConfigFile=%clusterpath%\MatrixServerTool\ServerParamConfig_All.ini"
set "WEBHOOK_URL=https://discord.com/api/webhooks/1222834102860910603/fgdfgdfgdfgdfgdfgdfgdfgdfgdg"
set "rcon_pass=SUPERPASSWORD"

:: ANNONCE
echo Discord annonce 1
set "MESSAGE=@here\n Плановый рестарт\n Кластер будет перезагружен через 10 минут"
set "rconmessage=Рестарт через 10 минут"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%MESSAGE%\"}" %WEBHOOK_URL%
%mcrcon_dir%\PyRcon.exe -ip 65.109.113.61 -p 8012 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"%rconmessage%\" 1 0
%mcrcon_dir%\PyRcon.exe -ip 65.109.113.61 -p 8022 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"%rconmessage%\" 1 0
%mcrcon_dir%\PyRcon.exe -ip 65.109.113.61 -p 8032 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"%rconmessage%\" 1 0
timeout /t 300

echo Discord annonce 2
set "MESSAGE= Плановый рестарт\n Кластер будет перезагружен через 5 минут"
set "rconmessage=Рестарт через 5 минут"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%MESSAGE%\"}" %WEBHOOK_URL%
%mcrcon_dir%\PyRcon.exe -ip 65.109.113.61 -p 8012 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"%rconmessage%\" 1 0
%mcrcon_dir%\PyRcon.exe -ip 65.109.113.61 -p 8022 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"%rconmessage%\" 1 0
%mcrcon_dir%\PyRcon.exe -ip 65.109.113.61 -p 8032 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"%rconmessage%\" 1 0
timeout /t 240

echo Discord annonce 3
set "MESSAGE=@here\n Плановый рестарт\n Кластер будет перезагружен через 1 минуту"
set "rconmessage=Рестарт через 1 минуту"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%MESSAGE%\"}" %WEBHOOK_URL%
%mcrcon_dir%\PyRcon.exe -ip 65.109.113.61 -p 8012 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"%rconmessage%\" 1 0
%mcrcon_dir%\PyRcon.exe -ip 65.109.113.61 -p 8022 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"%rconmessage%\" 1 0
%mcrcon_dir%\PyRcon.exe -ip 65.109.113.61 -p 8032 -pass %rcon_pass% -c BroadcastNotifySysInfo ^\"%rconmessage%\" 1 0
timeout /t 60

echo Saving Worlds....
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 8012 -p %rcon_pass% SaveWorld
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 8022 -p %rcon_pass% SaveWorld
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 8032 -p %rcon_pass% SaveWorld
TIMEOUT /t 20

echo Exiting Worlds...
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 8012 -p %rcon_pass% ShutdownServer
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 8022 -p %rcon_pass% ShutdownServer
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 8032 -p %rcon_pass% ShutdownServer
echo Stop BG
%mcrcon_dir%\mcrcon.exe -H 65.109.113.61 -P 7012 -p %rcon_pass% ShutdownServer
TIMEOUT /t 10

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
call "C:\moe_cluster\scripts\^!START_CLUSTER.cmd"
timeout /t 3
EXIT
