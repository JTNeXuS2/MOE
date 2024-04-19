@echo off
title "MOE ToolKits"
mode con:cols=70 lines=7

:start
echo Started
python ToolKits.py
timeout /t 5
goto start
