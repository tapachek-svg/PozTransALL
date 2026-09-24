# ZTM API server (port 8000) with auto-restart supervisor.
$ErrorActionPreference = 'Continue'
$dir = Join-Path (Split-Path $PSScriptRoot -Parent) 'ZTM parser to API server'
Set-Location $dir
$Host.UI.RawUI.WindowTitle = 'PozTrans: ZTM API :8000'
while ($true) {
    Write-Host "[$(Get-Date -Format s)] [ztm] starting on :8000"
    python main.py
    Write-Host "[$(Get-Date -Format s)] [ztm] exited (code $LASTEXITCODE), restart in 5s (Ctrl+C to stop)"
    Start-Sleep -Seconds 5
}
