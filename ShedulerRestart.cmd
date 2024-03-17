@echo off
cd %~dp0
chcp 65001

:: Run once to setup script in to windows task sheduler (taskschd.msc) 12:00 Autorun
schtasks /query /tn "MOE.Restart"
echo %errorlevel%
if %errorlevel% == 1 (
    echo Task not found. Adding task to the scheduler...
    schtasks /create /F /tn "MOE.Restart" /tr "%~dp0ShedulerRestart.cmd" /sc daily /st 11:50
	echo exit
	timeout /t 5
	exit
)

set "clusterpath=C:\moe_cluster"
set "mcrcon_dir=%clusterpath%\rcon"
set "ConfigFile=%clusterpath%\MatrixServerTool\ServerParamConfig_All.ini"
set "WEBHOOK_URL=https://discord.com/api/webhooks/1210772484509671464/CwEwsl6GTV6ze16joW0sIyK62nYrPSd4OM2BjAtkgbXIUgOSJ1TGp0l0grBJc5FRXi2s"

:: ANNONCE
echo Discord annonce 1
set "MESSAGE=@here\n Плановый рестар!\n Кластер будет перезагружен через 10 минут!"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%MESSAGE%\"}" %WEBHOOK_URL%
timeout /t 300

echo Discord annonce 2
set "MESSAGE= Плановый рестар!\n Кластер будет перезагружен через 5 минут!"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%MESSAGE%\"}" %WEBHOOK_URL%
timeout /t 240

echo Discord annonce 3
set "MESSAGE=@here\n Плановый рестар!\n Кластер будет перезагружен через 1 минуту!"
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%MESSAGE%\"}" %WEBHOOK_URL%
timeout /t 60

setlocal enabledelayedexpansion

echo Saving Worlds....
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 1234 -p RCON_PASS SaveWorld
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 1235 -p RCON_PASS SaveWorld
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 1236 -p RCON_PASS SaveWorld
TIMEOUT /t 15

echo Exiting Worlds...
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 1234 -p RCON_PASS ShutdownServer
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 1235 -p RCON_PASS ShutdownServer
%mcrcon_dir%\mcrcon.exe -H 127.0.0.1 -P 1236 -p RCON_PASS ShutdownServer
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
    )
	goto Next
)
:Next


echo start servers
::echo Battle
::call "C:\moe_cluster\MatrixServerTool\StartBattleServer_7010.bat"
::timeout /t 10

echo Scene 100
call "C:\moe_cluster\MatrixServerTool\StartSceneServer_100.bat"
timeout /t 10

echo Scene 200
call "C:\moe_cluster\MatrixServerTool\StartSceneServer_200.bat"
timeout /t 10

echo Scene 300
call "C:\moe_cluster\MatrixServerTool\StartSceneServer_300.bat"

echo exit...
timeout /t 10
