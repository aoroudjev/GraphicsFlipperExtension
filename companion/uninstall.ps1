$installDir = Join-Path $env:LOCALAPPDATA "GraphicsFlipper"
$edgeKey    = "HKCU:\Software\Microsoft\Edge\NativeMessagingHosts\com.gpuflip.toggle"
$chromeKey  = "HKCU:\Software\Google\Chrome\NativeMessagingHosts\com.gpuflip.toggle"

foreach ($key in @($edgeKey, $chromeKey)) {
    if (Test-Path $key) {
        Remove-Item $key -Force
        Write-Host "[OK] Registry key removed: $key"
    }
}

if (Test-Path $installDir) {
    Remove-Item $installDir -Recurse -Force
    Write-Host "[OK] Removed: $installDir"
}

Write-Host ""
Write-Host "Graphics Flipper companion uninstalled."
