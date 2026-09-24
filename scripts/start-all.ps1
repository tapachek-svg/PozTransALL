# Starts ZTM API, AppServer and the Cloudflare tunnel, each in its own window (skips ones already listening).
param([switch]$NoTunnel)
function Test-Port($p) { [bool](Get-NetTCPConnection -State Listen -LocalPort $p -ErrorAction SilentlyContinue) }
function Start-Win($name, $script) {
    Start-Process powershell -ArgumentList '-NoExit','-ExecutionPolicy','Bypass','-File',(Join-Path $PSScriptRoot $script) | Out-Null
    Write-Host "started $name"
}
if (Test-Port 3306) { Write-Host 'MariaDB already on :3306' } else { Start-Win 'MariaDB' 'run-db.ps1'; Start-Sleep -Seconds 6 }
if (Test-Port 8000) { Write-Host 'ZTM API already on :8000' } else { Start-Win 'ZTM API' 'run-ztm.ps1' }
if (Test-Port 8001) { Write-Host 'AppServer already on :8001' } else { Start-Win 'AppServer' 'run-appserver.ps1' }
if (-not $NoTunnel) {
    if (Get-Process cloudflared -ErrorAction SilentlyContinue) { Write-Host 'cloudflared already running' } else { Start-Win 'tunnel' 'run-tunnel.ps1' }
}
Write-Host 'Waiting for servers, then health check...'
Start-Sleep -Seconds 12
& (Join-Path $PSScriptRoot 'check-health.ps1') @(if ($NoTunnel) { '-LocalOnly' })
