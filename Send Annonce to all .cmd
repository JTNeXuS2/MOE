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
set /p input=Annonce text: 
echo Annonce text is
echo "%input%"
set "mcrcon_dir=C:\moe_cluster\rcon"
timeout /t 5

echo Scene 100
%mcrcon_dir%\PyRcon.exe -ip %rcon_host% -p 8012 -pass %rcon_pass% -c "BroadcastNotifySysInfo \"%input%\" 1 0"
echo Scene 200
%mcrcon_dir%\PyRcon.exe -ip %rcon_host% -p 8022 -pass %rcon_pass% -c "BroadcastNotifySysInfo \"%input%\" 1 0"
echo Scene 300
%mcrcon_dir%\PyRcon.exe -ip %rcon_host% -p 8032 -pass %rcon_pass% -c "BroadcastNotifySysInfo \"%input%\" 1 0"
echo Scene 400
%mcrcon_dir%\PyRcon.exe -ip %rcon_host% -p 8042 -pass %rcon_pass% -c "BroadcastNotifySysInfo \"%input%\" 1 0"
