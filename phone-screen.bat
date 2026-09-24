@echo off
rem Shows the connected Android phone's screen on this PC (scrcpy) and lets you control it.
rem Extra scrcpy options can be passed on the command line, e.g.: phone-screen.bat --turn-screen-off

set "ADB=C:\Users\admin\AppData\Local\Android\Sdk\platform-tools\adb.exe"
set "SCRCPY="

where scrcpy >nul 2>nul && set "SCRCPY=scrcpy"
if not defined SCRCPY (
    for /f "delims=" %%F in ('dir /s /b "%LOCALAPPDATA%\Microsoft\WinGet\Packages\scrcpy.exe" 2^>nul') do set "SCRCPY=%%F"
)
if not defined SCRCPY (
    echo scrcpy not found. Install it with: winget install Genymobile.scrcpy --source winget
    pause
    exit /b 1
)

"%ADB%" start-server >nul 2>nul
"%ADB%" get-state 2>nul | findstr /c:"device" >nul
if errorlevel 1 (
    echo No phone detected. Connect it via USB, enable USB debugging and confirm the prompt on the phone.
    "%ADB%" devices
    pause
    exit /b 1
)

"%SCRCPY%" %*
if errorlevel 1 pause
