@echo off
title Soul OS Installer
color 0D

echo.
echo   ███████╗ ██████╗ ██╗   ██╗██╗          ██████╗ ███████╗
echo   ██╔════╝██╔═══██╗██║   ██║██║         ██╔═══██╗██╔════╝
echo   ███████╗██║   ██║██║   ██║██║         ██║   ██║███████╗
echo   ╚════██║██║   ██║██║   ██║██║         ██║   ██║╚════██║
echo   ███████║╚██████╔╝╚██████╔╝███████╗    ╚██████╔╝███████║
echo   ╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝     ╚═════╝ ╚══════╝
echo.
echo         Soul OS Windows Installer
echo.

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] This installer requires Administrator privileges.
    echo [*] Requesting elevation...
    echo.
    
    :: Self-elevate
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo [*] Running with Administrator privileges...
echo.

:: Run the PowerShell installer
powershell -ExecutionPolicy Bypass -File "%~dp0Install-SoulOS.ps1"

pause
