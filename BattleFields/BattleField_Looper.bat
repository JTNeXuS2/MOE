@echo off
cd %~dp0
mode con:cols=70 lines=8
setlocal enabledelayedexpansion

:start
:: ID sesion name and read log 
set "serverid=7010"
TITLE BATTLEFIELD Looper SessionName-%serverid% ServerId-%serverid%

:: looking for the official launch time of the event (https://discord.com/channels/911228503154917387/911228503721119828/1216847557804687451)
set time=04:00:00
set startday=MON
:: Monday [MON] – понедельник
:: Tuesday [TUE] – вторник
:: Wednesday [WED] – среда
:: Thursday [THU] – четверг
:: Friday [FRI] – пятница
:: Saturday [SAT] – суббота
:: Sunday [SUN] – воскресенье
if "%startday%"=="MON" set "dayOfWeek=1"
if "%startday%"=="TUE" set "dayOfWeek=2"
if "%startday%"=="WED" set "dayOfWeek=3"
if "%startday%"=="THU" set "dayOfWeek=4"
if "%startday%"=="FRI" set "dayOfWeek=5"
if "%startday%"=="SAT" set "dayOfWeek=6"
if "%startday%"=="SUN" set "dayOfWeek=0"
:: looking for the nearest official launch day of the event (https://discord.com/channels/786062570095116293/1171345133141237780/1216977618021388328)
:: check the day is equal to '%startday% if not equal, look for the closest one
for /f "tokens=1-3 delims=/-. " %%a in ('powershell -Command "$currentDate = Get-Date; if ($currentDate.DayOfWeek -ne '%startday%') { $daysUntil = (%dayOfWeek% - $currentDate.DayOfWeek.value__); $newDate = $currentDate.AddDays($daysUntil); $newDate.ToString('dd/MM/yyyy HH:mm:ss') } else { $currentDate.ToString('dd/MM/yyyy HH:mm:ss') }"') do (
    set "day=%%a"
    set "month=%%b"
    set "year=%%c"
)
echo.

:: read batch StartBattleServer_YYYY.bat
set "readbatch=StartBattleServer_%serverid%.bat"
set "runparam="
for /f "usebackq skip=1 delims=" %%a in ("%readbatch%") do (
    set "line=%%a"
    if defined line (
        set "line=!line:*start "MOEServer.exe - PrivateServer" "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" =!"
        set "runparam=!runparam!!line!"
    )
)

echo find Window: SessionName-%serverid% ServerId-%serverid% PID-
powershell -command "$foundWindow = Get-Process | Where-Object {$_.MainWindowTitle -like '*SessionName-%serverid% ServerId-%serverid% PID-*'}; if ($foundWindow) { exit 0 } else { exit 1 }"
if %errorlevel% equ 0 (
    goto check_log
) else (
    goto run
)

:run
echo Run date %day%\%month%\%year% %time%
RunAsDate.exe /immediate /movetime %day%\%month%\%year% %time% "..\WindowsPrivateServer\MOE\Binaries\Win64\MOEServer.exe" %runparam%

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
    goto start
)
endlocal
