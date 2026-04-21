$installDir = Join-Path $env:LOCALAPPDATA "GraphicsFlipper"
$exeSrc     = Join-Path $PSScriptRoot "NativeHost.exe"
$exeDst     = Join-Path $installDir  "NativeHost.exe"
$manifest   = Join-Path $installDir  "gpu_toggle.json"

# Build if needed
if (-not (Test-Path $exeSrc)) {
    Write-Host "Building NativeHost.exe..."
    & "$PSScriptRoot\build.bat"
    if (-not (Test-Path $exeSrc)) {
        Write-Error "Build failed. Aborting."
        exit 1
    }
}

# Install to %LOCALAPPDATA%\GraphicsFlipper\
New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Copy-Item $exeSrc $exeDst -Force

# Generate gpu_toggle.json with the correct absolute path baked in
$json = [ordered]@{
    name            = "com.gpuflip.toggle"
    description     = "GPU Acceleration Toggle - Native Messaging Host"
    path            = $exeDst
    type            = "stdio"
    allowed_origins = @(
        "chrome-extension://nfloihcfmeeelbfgocljfndbngbjngie/",
        "chrome-extension://ghmnblflimkddhmfgjohhjkfiflfedmk/"
    )
}
$json | ConvertTo-Json | Set-Content $manifest -Encoding UTF8

# Register for both Edge and Chrome
$edgeKey  = "HKCU:\Software\Microsoft\Edge\NativeMessagingHosts\com.gpuflip.toggle"
$chromeKey = "HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.gpuflip.toggle"

foreach ($key in @($edgeKey, $chromeKey)) {
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name "(default)" -Value $manifest
}

Write-Host ""
Write-Host "[OK] Installed to: $installDir"
Write-Host "[OK] Registered for Edge and Chrome"
Write-Host ""
Write-Host "Next: load the extension/  folder as an unpacked extension in Edge or Chrome."
