@echo off
REM Cruise Logs User Installer Launcher
REM Double-click this file to start installation
REM No administrator privileges required

echo.
echo ========================================
echo   Cruise Logs User Installer
echo ========================================
echo.
echo This will install Cruise Logs in:
echo   %USERPROFILE%\Cruise_Logs
echo.
echo No admin privileges required!
echo.
pause

powershell -ExecutionPolicy Bypass -File "%~dp0install_user.ps1"

REM Note: %~dp0 automatically points to the directory where this .bat file is located

pause
