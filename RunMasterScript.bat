@echo off
REM Run the master PowerShell script with execution policy bypass
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0MasterScript.ps1"
pause
