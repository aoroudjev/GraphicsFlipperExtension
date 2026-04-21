@echo off
setlocal

set COMPANION_DIR=%~dp0
set HOST_MANIFEST=%COMPANION_DIR%gpu_toggle.json
set REG_KEY=HKCU\Software\Google\Chrome\NativeMessagingHosts\com.gpuflip.toggle

:: Build if NativeHost.exe doesn't exist
if not exist "%COMPANION_DIR%NativeHost.exe" (
  echo NativeHost.exe not found, building...
  call "%COMPANION_DIR%build.bat"
  if not exist "%COMPANION_DIR%NativeHost.exe" (
    echo Build failed. Aborting install.
    pause
    exit /b 1
  )
)

:: Update the path in gpu_toggle.json to this machine's actual path
powershell -ExecutionPolicy Bypass -Command ^
  "(Get-Content '%HOST_MANIFEST%') -replace 'C:\\\\edge_graphics_flipper\\\\companion\\\\NativeHost.exe', '%COMPANION_DIR%NativeHost.exe'.Replace('\','\\') | Set-Content '%HOST_MANIFEST%'"

:: Register native messaging host in registry for Chrome
reg add "%REG_KEY%" /ve /t REG_SZ /d "%HOST_MANIFEST%" /f

if %errorlevel% == 0 (
  echo.
  echo [OK] Native host registered for Chrome.
  echo.
  echo Next steps:
  echo  1. Open chrome://extensions
  echo  2. Enable Developer mode
  echo  3. Click "Load unpacked" and select: %COMPANION_DIR%..\extension
  echo  4. Copy the extension ID shown on the card
  echo  5. Open gpu_toggle.json and replace CHROME_EXTENSION_ID_PLACEHOLDER with that ID
  echo  6. Re-run this installer to re-register with the correct ID
  echo.
) else (
  echo ERROR: Failed to register registry key.
)

pause
