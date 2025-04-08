@echo off
::mklink "ShortcutFile" "TargetFile"
mklink /D /J "C:\moe_cluster\WindowsPrivateServer" "C:\moe_cluster\moe"
mklink /D /J "C:\moe_cluster\MatrixServerTool" "C:\moe_cluster\moe\MatrixServerTool"
mklink "C:\moe_cluster\moe\configs\ServerParamConfig_All.ini" "C:\moe_cluster\moe\MatrixServerTool\ServerParamConfig_All.ini"

set "shortcut=C:\moe_cluster\MatrixServerTool - Shortcut.lnk"
set "workingdir=C:\moe_cluster\moe\MatrixServerTool"

set "target=%workingdir%\MatrixServerTool.exe"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%shortcut%'); $Shortcut.TargetPath = '%target%'; $Shortcut.WorkingDirectory = '%workingdir%'; $Shortcut.Save()"

TIMEOUT 5
