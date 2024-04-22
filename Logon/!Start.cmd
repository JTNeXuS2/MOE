@echo off
title "MOE Logon LogParser"
mode con:cols=70 lines=7

:start
python LogParser.py
timeout /t 5
goto start
