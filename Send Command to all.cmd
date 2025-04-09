@echo off
chcp 65001>nul
cd %~dp0
setlocal enabledelayedexpansion
title "MOE Tool

set "clusterpath=C:\moe_cluster"
set "mcrcon_dir=%clusterpath%\rcon"

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
call :read_param rcon_host
call :read_param rcon_pass

:: ===== FUNCTIONS read config END ======================================

:input
cls
echo example SaveWorld
echo SetServerMultiplier ?NormalReduceDurableMultiplier=0.7
echo ======================================================
set /p input=Input Command: 
echo Command is
echo "%input%"
set "mcrcon_dir=C:\moe_cluster\rcon"
timeout /t 5

echo BattleServer
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 7012 -p %rcon_pass% "%input%"
timeout /t 3 >nul

echo Lobby
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 6003 -p %rcon_pass% "%input%"
echo Pub
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 6014 -p %rcon_pass% "%input%"

echo Scene 100
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8012 -p %rcon_pass% "%input%"
echo Scene 200
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8022 -p %rcon_pass% "%input%"
echo Scene 300
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8032 -p %rcon_pass% "%input%"
echo Scene 400
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8042 -p %rcon_pass% "%input%"
goto input