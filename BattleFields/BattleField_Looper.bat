@echo off
cd %~dp0
mode con:cols=70 lines=8

:start
:: ID sesion name and read log (-ServerId and -SessionName and -log=BattleServer_XXXX.log)
set "serverid=7020"
set time=04:00:00

TITLE BATTLEFIELD Looper SessionName-%serverid% ServerId-%serverid%
for /f "tokens=1-3 delims=/-. " %%a in ('date /t') do (
    set "day=%%a"
    set "month=%%b"
    set "year=%%c"
)

RunAsDate.exe /immediate /movetime %day%\%month%\%year% %time% "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" Battlefield_Main_New -game -server -ClusterId=8888 -log -StartBattleService -StartPubData -BigPrivateServer -DistrictId=1 -EnableParallelTickFunction -DisablePhysXSimulation -LOCALLOGTIMES -corelimit=5 -core -HangDuration=300 -NotCheckServerSteamAuth  -ActivityServer=true -MultiHome=65.109.113.61 -OutAddress=65.109.113.61 -Port=GAMEPORT -QueryPort=STEAMPORT -ShutDownServicePort=RCONPORT -ShutDownServiceIP=65.109.113.61 -ShutDownServiceKey=RCONPASS -MaxPlayers=100 -SessionName=7020 -ServerId=7020 log=BattleServer_7020.log -PubDataAddr=65.109.113.61 -PubDataPort=PUBPORT -DBAddr=65.109.113.61 -DBPort=DBPORT -BattleAddr=65.109.113.61 -BattlePort=BATLEPORT -ChatServerAddr=65.109.113.61 -ChatServerPort=CHATPORT -ChatClientAddress=65.109.113.61 -ChatClientPort=CLICHATPORT -OptEnable=1 -OptAddr=65.109.113.61 -OptPort=OPTPORT -Description="Discord" -MaxPlayers=100 -NoticeSelfEnable=true -NoticeSelfEnterServer="Discord" -MapDifficultyRate=1 -UseACE -EnableVACBan=1 -ServerAdminAccounts=111111;222222 -NoticeAllEnable=true -NoticeEnterServer=" Discord" -SaveGameIntervalMinute=7 -NormalReduceDurableMultiplier=0.8 -bEnableServerLevel=false -GeneralQualityMultiPVPBlue=0 -GeneralQualityMultiPVPPurse=0.2 -HorseMaxQualityCorrectionPVE=0.9 -TameAnimalLifeMultiplier=2 -MoveSeatLoadMultiplier=2 -NUM_AllGeneralMax=10 -NUM_WarGeneralMax=2 -NUM_AllHorseMax=20 -NUM_WarHorseMax=10 -TameAnimalMatingSpeedMultiplier=2 -TameAnimalMatingCDMultiplier=0.5 -BabyAnimalGrowthRateMultiplier=0.5 -ItemCraftRepairTimeMulti=0.3  -BattleServerReduceInventoryDurablePercent=0 -OccupyDecayHPMultiplier=3 

echo Wait Loading Server
timeout /t 30
:check_log
echo Run date %day%\%month%\%year% %time%
echo Look: SessionName-%serverid% ServerId-%serverid%
echo Read Log: %~dp0..\moe\MOE\Saved\Logs\BattleServer_%serverid%.log

powershell -command "$idleFound = $false; $serverTravelingFound = $false; Get-Content '..\moe\MOE\Saved\Logs\BattleServer_%serverid%.log' | ForEach-Object { if ($_ -match 'SERVER_STATE_IDLE') { $idleFound = $true } if ($idleFound -and $_ -match 'SERVER_STATE_SERVERTRAVELING') { $serverTravelingFound = $true } }; if ($idleFound -and -not $serverTravelingFound) { Write-Host 'SERVER_STATE_SERVERTRAVELING not found after SERVER_STATE_IDLE!'; exit 1 } elseif (-not $idleFound) { Write-Host 'SERVER_STATE_IDLE not found in the log file!'; exit 1 } else { exit 0 }"

if %errorlevel% equ 1 (
    echo KILL IDLE SERVER!
    taskkill /FI "WINDOWTITLE eq SessionName-%serverid% ServerId-%serverid% PID-*" /F
    timeout /t 2
    goto start
) else (
    timeout /t 30
    cls
    goto check_log
)
