@echo off
setlocal
echo ========================================================
echo Installing DevSecOps Maximum for Antigravity and Claude
echo ========================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-DevSecOps.ps1" -Platform Both %*
pause
