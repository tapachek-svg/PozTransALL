# AppServer / Health server (port 8001). dist/watchdog.js already restarts the app with backoff;
# this outer loop additionally restarts the watchdog itself if it dies.
$ErrorActionPreference = 'Continue'
$dir = Join-Path (Split-Path $PSScriptRoot -Parent) 'AppServer'
Set-Location $dir
$Host.UI.RawUI.WindowTitle = 'PozTrans: AppServer :8001'
if (-not (Test-Path 'dist\watchdog.js') -or ((Get-ChildItem src -Recurse -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime -gt (Get-Item 'dist\watchdog.js').LastWriteTime)) {
    Write-Host "[appserver] building (dist is missing or older than src)..."
    npm run build
}
while ($true) {
    Write-Host "[$(Get-Date -Format s)] [appserver] starting on :8001"
    node dist/watchdog.js
    Write-Host "[$(Get-Date -Format s)] [appserver] exited (code $LASTEXITCODE), restart in 5s (Ctrl+C to stop)"
    Start-Sleep -Seconds 5
}
