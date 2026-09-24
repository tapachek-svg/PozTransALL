# Cloudflare tunnel f44dd1c2-... (apipoztrans -> :8000, apppoztrans -> :8001), auto-restart.
$Host.UI.RawUI.WindowTitle = 'PozTrans: cloudflared tunnel'
while ($true) {
    Write-Host "[$(Get-Date -Format s)] [tunnel] starting"
    cloudflared tunnel --config "$env:USERPROFILE\.cloudflared\config.yml" run f44dd1c2-e68c-4820-89b8-5b647241bb73
    Write-Host "[$(Get-Date -Format s)] [tunnel] exited (code $LASTEXITCODE), restart in 5s (Ctrl+C to stop)"
    Start-Sleep -Seconds 5
}
