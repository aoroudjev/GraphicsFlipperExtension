@echo off
echo Building NativeHost.exe...

set CSC=
for %%f in (
  "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
  "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
) do if exist %%f if not defined CSC set CSC=%%f

if not defined CSC (
  echo ERROR: csc.exe not found. Install .NET Framework 4.x or the .NET SDK.
  pause
  exit /b 1
)

"%CSC%" /out:"%~dp0NativeHost.exe" /optimize+ "%~dp0NativeHost.cs"

if %errorlevel% == 0 (
  echo Build successful: NativeHost.exe
) else (
  echo Build failed.
  pause
)
