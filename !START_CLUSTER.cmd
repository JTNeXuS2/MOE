@echo off
cd %~dp0
chcp 65001>nul
set "clusterpath=C:\moe_cluster"
set "setup=0"
setlocal enabledelayedexpansion

color 0F
::check daily restart & any start srcipts
set "WindowTitle=MOE Check OFFLINE" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid% SKIPED
	timeout /t 2
	exit /b
) else (
    echo Process %WindowTitle% not found
)

title "MOE Check OFFLINE"

set "WindowTitle=MOE ShedulerRestart" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid% SKIPED
	timeout /t 2
	exit /b
) else (
    echo Process %WindowTitle% not found
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
:ANNONCE
:: ANNONCE function
if defined webhook_url (
	set "dis_msg=%STARTMESSAGE%**%serverid%**"
	curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"!dis_msg!\"}" %WEBHOOK_URL%
)
exit /b
:SKIP_FUNCTIONS
call :read_param WEBHOOK_URL
call :read_param STARTMESSAGE
:: ===== FUNCTIONS read config END ======================================

:::REDIS
set "WindowTitle=MOE Redis Chat DB" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
    cd "%clusterpath%\Redis" && start "%WindowTitle%" "^!Start.cmd"
	timeout /t 3
)
:::SQL
set "WindowTitle=MOE SQL Server" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
    cd "%clusterpath%\mysql" && start "%WindowTitle%" "^!Start.cmd"
	timeout /t 3
)
:::OPT Service
set "WindowTitle=game-opt-sys.exe" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
    cd "%clusterpath%\MatrixServerTool" && call "StartGameOptSys.bat"
	timeout /t 3
)
:::Chat Service
set "WindowTitle=game-chat-service.exe" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
    cd "%clusterpath%\MatrixServerTool" && call "StartGameChatService.bat"
	timeout /t 3
)
:::ServerStatus
set "WindowTitle=MOE ServerStatus" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
	::cd "%clusterpath%\scripts\Status" && start "%WindowTitle%" "MOE.ServerStatus.exe"
	cd "%clusterpath%\scripts\Status" && start "%WindowTitle%" "^!Start.cmd"
	timeout /t 1
)
:::LogParser
set "WindowTitle=MOE Logon LogParser" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
	cd "%clusterpath%\scripts\Logon" && start "%WindowTitle%" "^!Start.cmd"
	timeout /t 1
)

:::MOE ToolKits
set "WindowTitle=MOE ToolKits" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
	cd "%clusterpath%\scripts\ToolKits" && start "%WindowTitle%" "^!Start.cmd"
	timeout /t 1
)
::: END PERIPHERAL SERVERS

cd %clusterpath%\MatrixServerTool

::: LOBBY
set "readbatch=StartLobbyServer.bat"
set "serverid=6000"
set "WindowTitle=ServerId-%serverid%"
set "processpid=" && set "runparam="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
for /f "usebackq skip=1 delims=" %%a in ("%readbatch%") do (
    set "line=%%a"
    if defined line (
        set "line=!line:*start "MOEServer.exe - PrivateServer" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" =!"
        set "runparam=!runparam!!line!"
    )
)
call :ANNONCE
start /LOW /affinity 0x0000000000FC0000 "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" !runparam! -EnableParallelTickFunction -DisablePhysXSimulation -corelimit=6
set "setup=1"
timeout /t 10 >nul
)
::: PUB
set "readbatch=StartPubDataServer.bat"
set "serverid=6010"
set "WindowTitle=ServerId-%serverid%"
set "processpid=" && set "runparam="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
for /f "usebackq skip=1 delims=" %%a in ("%readbatch%") do (
    set "line=%%a"
    if defined line (
        set "line=!line:*start "MOEServer.exe - PrivateServer" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" =!"
        set "runparam=!runparam!!line!"
    )
)
call :ANNONCE
start /LOW /affinity 0x0000000000FC0000 "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" !runparam!
set "setup=1"
timeout /t 5 >nul
)
:: Wait... Loading Cluster core - Lobby and PUB
if "%setup%" == "1" (
    echo Loading Cluster core. Wait...
    timeout /t 20
)

::: SCENES
set "serverid=100"
set "readbatch=StartSceneServer_%serverid%.bat"
set "WindowTitle=ServerId-%serverid%"
set "processpid=" && set "runparam="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
for /f "usebackq skip=1 delims=" %%a in ("%readbatch%") do (
    set "line=%%a"
    if defined line (
        set "line=!line:*start "MOEServer.exe - PrivateServer" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" =!"
        set "runparam=!runparam!!line!"
    )
)
call :ANNONCE
start /affinity 0x00000000000001F0 "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" !runparam!
set "setup=1"
timeout /t 3
)
:::
set "serverid=200"
set "readbatch=StartSceneServer_%serverid%.bat"
set "WindowTitle=ServerId-%serverid%"
set "processpid=" && set "runparam="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
for /f "usebackq skip=1 delims=" %%a in ("%readbatch%") do (
    set "line=%%a"
    if defined line (
        set "line=!line:*start "MOEServer.exe - PrivateServer" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" =!"
        set "runparam=!runparam!!line!"
    )
)
call :ANNONCE
start /affinity 0x0000000000001F80 "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" !runparam!
set "setup=1"
timeout /t 3
)
:::
set "serverid=300"
set "readbatch=StartSceneServer_%serverid%.bat"
set "WindowTitle=ServerId-%serverid%"
set "processpid=" && set "runparam="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
for /f "usebackq skip=1 delims=" %%a in ("%readbatch%") do (
    set "line=%%a"
    if defined line (
        set "line=!line:*start "MOEServer.exe - PrivateServer" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" =!"
        set "runparam=!runparam!!line!"
    )
)
call :ANNONCE
start /affinity 0x000000000003F000 "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" !runparam! -corelimit=6
set "setup=1"
timeout /t 3
)

:::
set "serverid=400"
set "readbatch=StartSceneServer_%serverid%.bat"
set "WindowTitle=ServerId-%serverid%"
set "processpid=" && set "runparam="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
for /f "usebackq skip=1 delims=" %%a in ("%readbatch%") do (
    set "line=%%a"
    if defined line (
        set "line=!line:*start "MOEServer.exe - PrivateServer" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" =!"
        set "runparam=!runparam!!line!"
    )
)
:: 0x000000000003F000
call :ANNONCE
start /affinity 0x000000000000FC00 "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" !runparam!
set "setup=1"
timeout /t 3
)

:::BATTLE BG
set "serverid=7010"
set "readbatch=StartBattleServer_%serverid%.bat"
set "WindowTitle=ServerId-%serverid%"
set "processpid=" && set "runparam="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
    ::get day map
    for /f "delims=" %%# in ('powershell.exe -command "(Get-Date).DayOfWeek.value__"') do set "day=%%#"
    if !day! equ 1 (set "battlemap=Battlefield_Main_New")
    if !day! equ 2 (set "battlemap=Battlefield_Gorge_Main")
    if !day! equ 3 (set "battlemap=Battlefield_Main_New")
    if !day! equ 4 (set "battlemap=Battlefield_Gorge_Main")
    if !day! equ 5 (set "battlemap=Battlefield_Main_New")
    if !day! equ 6 (set "battlemap=Battlefield_Gorge_Main")
    ::if !day! equ 6 (set "battlemap=Mas_Battlefield_Main")
    if !day! equ 7 (set "battlemap=Battlefield_Main_New")
    echo Day of the week: !day! Battle map for today: !battlemap!
    ::set sturt params
    for /f "usebackq skip=1 delims=" %%a in ("%readbatch%") do (
    set "line=%%a"
    if defined line (
        set "line=!line:*start "MOEServer.exe - PrivateServer" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" =!"
        set "runparam=!runparam!!line!"
    )
)
call :ANNONCE
start "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" Battlefield_Main_New -game -server -CheatActivityMap=!battlemap! !runparam!
set "setup=1"
timeout /t 5
)
:::BATTLE GvG
set "serverid=7020"
set "readbatch=StartBattleServer_%serverid%.bat"
set "WindowTitle=ServerId-%serverid%"
set "processpid=" && set "runparam="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
	call :ANNONCE
    call "StartBattleServer_%serverid%.bat"
    set "setup=1"
    timeout /t 5
)

if "%setup%" == "1" (
    echo RCON Settings
    timeout /t 5
    call "%clusterpath%\scripts\SetSeceneNames.cmd"
)
echo CheckOffline EXIT
TIMEOUT /t 3
