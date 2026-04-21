@echo off
reg delete "HKCU\Software\Microsoft\Edge\NativeMessagingHosts\com.gpuflip.toggle" /f 2>nul && echo [OK] Edge registration removed. || echo Edge key not found.
reg delete "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.gpuflip.toggle" /f 2>nul && echo [OK] Chrome registration removed. || echo Chrome key not found.
pause
