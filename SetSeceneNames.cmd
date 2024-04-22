@echo off
cd %~dp0
chcp 65001

set "clusterpath=C:\moe_cluster"
set "mcrcon_dir=%clusterpath%\rcon"

TIMEOUT /t 3
echo Set Names
::-Description="Discord discord.gg/qYmBmDR Shop https://pycbmythofempires.survivalshop.org"

set host=65.109.113.61
set "pass=RCONSUPERPASSWORD"

echo Lobby
set port=6003
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?SessionName={RU}{Mirnaya Pycb} [PVE/PVP] BATTLEFIELDS 24/7"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?Description=Discord discord.gg/qYmBmDR Shop https://pycbmythofempires.survivalshop.org"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?XCJinPaiMemberCountLimit=1.0"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?bOpenSeasonActivity=true"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetXianChengBattleParam 7 17 4320 1440 14 300"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetTaiShouBattleParam -1 6 18 -1 3 -1 -1"

echo Pub
set port=6014
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?SessionName={RU}{Mirnaya Pycb} [PVE/PVP] BATTLEFIELDS 24/7"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?Description="
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?bOpenSeasonActivity=true"

echo Scenes
set port=8012
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?SessionName=[RU]Mirnaya Pycb[PVE/PVP]BG S100"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?Description="
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?XCJinPaiMemberCountLimit=1.0"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?bOpenSeasonActivity=true"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetXianChengBattleParam 7 17 4320 1440 14 300"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetTaiShouBattleParam -1 6 18 -1 3 -1 -1"

set port=8022
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?SessionName=[RU]Mirnaya Pycb[PVE/PVP]BG S200"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?Description="
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?XCJinPaiMemberCountLimit=1.0"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?bOpenSeasonActivity=true"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetXianChengBattleParam 7 17 4320 1440 14 300"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetTaiShouBattleParam -1 6 18 -1 3 -1 -1"

set port=8032
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?SessionName=[RU]Mirnaya Pycb[PVE/PVP]BG S300"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?Description="
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?XCJinPaiMemberCountLimit=1.0"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetServerMultiplier ?bOpenSeasonActivity=true"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetXianChengBattleParam 7 17 4320 1440 14 300"
%mcrcon_dir%\mcrcon.exe -H %host% -P %port% -p %pass% "SetTaiShouBattleParam -1 6 18 -1 3 -1 -1"

echo Rcon exit...
timeout /t 3
