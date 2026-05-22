@echo off
title Soul OS Uninstaller
color 0C

echo.
echo   Soul OS Uninstaller
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] This uninstaller requires Administrator privileges.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo [*] Removing Soul OS...
wsl --unregister SoulOS 2>nul
rmdir /s /q "%USERPROFILE%\SoulOS" 2>nul
del "%USERPROFILE%\Desktop\Soul OS.lnk" 2>nul
rmdir /s /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Soul OS" 2>nul

echo [+] Soul OS has been uninstalled.
echo.
pause
