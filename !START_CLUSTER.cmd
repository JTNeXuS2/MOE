@echo off
cd %~dp0
chcp 65001>nul
set "basedir=C:\moe_cluster"
set "setup=0"
setlocal enabledelayedexpansion

:::REDIS
set "WindowTitle=MOE Redis Chat DB" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
    cd "%basedir%\Redis" && start "%WindowTitle%" "^!Start.cmd"
	timeout /t 3
)
:::SQL
set "WindowTitle=MOE SQL Server" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
    cd "%basedir%\mysql" && start "%WindowTitle%" "^!Start.cmd"
	timeout /t 3
)
:::OPT Service
set "WindowTitle=game-opt-sys.exe" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
    cd "%basedir%\MatrixServerTool" && call "StartGameOptSys.bat"
	timeout /t 3
)
:::Chat Service
set "WindowTitle=game-chat-service.exe" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
    cd "%basedir%\MatrixServerTool" && call "StartGameChatService.bat"
	timeout /t 3
)
:::ServerStatus
set "WindowTitle=MOE ServerStatus" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
	::cd "%basedir%\scripts\Status" && start "%WindowTitle%" "MOE.ServerStatus.exe"
	cd "%basedir%\scripts\Status" && start "%WindowTitle%" "^!Start.cmd"
	timeout /t 1
)
:::LogParser
set "WindowTitle=MOE Logon LogParser" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
	cd "%basedir%\scripts\Logon" && start "%WindowTitle%" "^!Start.cmd"
	timeout /t 1
)

:::MOE ToolKits
set "WindowTitle=MOE ToolKits" && set "processpid="
for /f "tokens=*" %%a in ('powershell.exe -command "$Processes = Get-Process; $Processes | Where-Object {$_.MainWindowTitle -like '*%WindowTitle%*'} | ForEach-Object {Write-Output $_.Id}"') do set processpid=%%a
if not "%processpid%"=="" (
    echo Found %WindowTitle% PID: %processpid%
) else (
    echo Process %WindowTitle% not found && echo Started %WindowTitle%
	cd "%basedir%\scripts\ToolKits" && start "%WindowTitle%" "^!Start.cmd"
	timeout /t 1
)
::: END PERIPHERAL SERVERS

cd %basedir%\MatrixServerTool

:::LOBBY
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
start /affinity 0x0000000000FA0000 "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" !runparam!
set "setup=1"
timeout /t 5
)
:::PUB
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
start /affinity 0x00000000000F0000 "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" !runparam!
set "setup=1"
timeout /t 5
)
:::SCENES
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
start /affinity 0x00000000000000F0 "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" !runparam!
set "setup=1"
timeout /t 5
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
start /affinity 0x0000000000000F00 "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" !runparam!
set "setup=1"
timeout /t 5
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
start /affinity 0x000000000000F000 "MOEServer.exe - %readbatch%" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" !runparam!
set "setup=1"
timeout /t 5
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
    if !day! equ 1 (set "battlemap=WarofThePass_Main_Special")
    if !day! equ 2 (set "battlemap=CountyTown_Main_Special")
    if !day! equ 3 (set "battlemap=Battlefield_Main_New")
    if !day! equ 4 (set "battlemap=WarofThePass_Main_Special")
    if !day! equ 5 (set "battlemap=Battlefield_Gorge_Main")
    if !day! equ 6 (set "battlemap=Battlefield_Main_New")
    if !day! equ 7 (set "battlemap=PrefectureWar_Main_Special")
    echo Day of the week: !day! Battle map for today: !battlemap!
    ::set sturt params
    for /f "usebackq skip=1 delims=" %%a in ("%readbatch%") do (
    set "line=%%a"
    if defined line (
        set "line=!line:*start "MOEServer.exe - PrivateServer" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" =!"
        set "runparam=!runparam!!line!"
    )
)
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
    call "StartBattleServer_%serverid%.bat"
    set "setup=1"
    timeout /t 5
)

if "%setup%" == "1" (
    echo RCON Settings
    call "C:\moe_cluster\scripts\SetSeceneNames.cmd"
)
echo EXIT
TIMEOUT /t 10
