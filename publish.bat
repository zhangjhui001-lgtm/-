@echo off
setlocal
chcp 65001 >nul

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish.ps1" %*
if errorlevel 1 (
    echo.
    echo Publish failed. Please read the message above.
    pause
    exit /b %errorlevel%
)
