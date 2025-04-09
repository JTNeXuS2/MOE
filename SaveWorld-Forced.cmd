@echo off
chcp 65001>nul
cd %~dp0
setlocal enabledelayedexpansion
title "MOE Tool

set "clusterpath=C:\moe_cluster"
set "mcrcon_dir=%clusterpath%\rcon"

setlocal enabledelayedexpansion

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

echo Saving Worlds....
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8012 -p %rcon_pass% SaveWorld
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8022 -p %rcon_pass% SaveWorld
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8032 -p %rcon_pass% SaveWorld
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 8042 -p %rcon_pass% SaveWorld

%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 6003 -p %rcon_pass% SaveWorld
%mcrcon_dir%\mcrcon.exe -H %rcon_host% -P 6014 -p %rcon_pass% SaveWorld
TIMEOUT /t 20
