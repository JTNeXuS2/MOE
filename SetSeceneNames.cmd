@echo off
cd %~dp0
chcp 65001>nul

set "clusterpath=C:\moe_cluster"
set "mcrcon_dir=%clusterpath%\rcon"

echo =======================================================================
echo Set Additional parameters that are not specified through the MatrixTool
echo =======================================================================
TIMEOUT /t 3

:: ===== READ CONFIG =====
set "config_file=%~dp0demon.cfg"
goto SKIP_FUNCTIONS
:read_param
set "getparam=%~1"
for /f "delims=" %%a in ('powershell -Command "(Get-Content -Encoding UTF8 '%config_file%' | Where-Object {$_ -match '%getparam%'}) -replace '.*=', ''"') do (
    set "%getparam%=%%a"
)
exit /b
:SKIP_FUNCTIONS
call :read_param rcon_host
call :read_param rcon_pass
:: ===== READ CONFIG END =====

echo Lobby
set port=6003
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %pass% "SetServerMultiplier ?SessionName=[Illidan] My Test Cluster"
%mcrcon_dir%\PyRcon.exe -ip %rcon_host% -p %port% -pass %rcon_pass% -c "SetServerMultiplier ?Description=Discord:discord.gg/qYmBmDR"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?XCJinPaiMemberCountLimit=1.0"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?bOpenSeasonActivity=true"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetXianChengBattleParam 7 17 4320 1440 14 300"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetTaiShouBattleParam -1 6 18 -1 3 -1 -1"

echo Pub
set port=6014
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?SessionName=[Illidan] My Test Cluster"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?Description="
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?bOpenSeasonActivity=true"

echo Scenes
set port=8012
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?SessionName=[Illidan] My Test Cluster S100"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?Description="
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?bOpenSeasonActivity=true"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetXianChengBattleParam 7 17 4320 1440 7 300"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetTaiShouBattleParam -1 6 18 -1 3 -1 -1"
:: %mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?SaveGameIntervalMinute=9"

set port=8022
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?SessionName=[Illidan] My Test Cluster S200"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?Description="
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?bOpenSeasonActivity=true"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetXianChengBattleParam 7 17 4320 1440 7 300"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetTaiShouBattleParam -1 6 18 -1 3 -1 -1"
:: %mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?SaveGameIntervalMinute=8"

set port=8032
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?SessionName=[Illidan] My Test Cluster S300"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?Description="
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?bOpenSeasonActivity=true"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetXianChengBattleParam 7 18 4320 1440 7 300"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetTaiShouBattleParam -1 6 16 -1 3 -1 -1"
:: %mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?SaveGameIntervalMinute=7"

set port=8042
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?SessionName=[Illidan] My Test Cluster S400"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?Description="
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?bOpenSeasonActivity=true"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetXianChengBattleParam 7 16 4320 1440 7 300"
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetTaiShouBattleParam -1 6 15 -1 3 -1 -1"
:: %mcrcon_dir%\mcrcon.exe -H %rcon_host% -P %port% -p %rcon_pass% "SetServerMultiplier ?SaveGameIntervalMinute=9"

echo Rcon exit...
timeout /t 3
