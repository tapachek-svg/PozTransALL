# Stops supervisors first (so they don't respawn children), then the servers and the tunnel.
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -match 'run-(ztm|appserver|tunnel|db)\.ps1' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
foreach ($p in 8000, 8001, 3306) {
    Get-NetTCPConnection -State Listen -LocalPort $p -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }
}
Get-CimInstance Win32_Process -Filter "Name='node.exe'" | Where-Object { $_.CommandLine -match 'watchdog' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
Get-Process cloudflared -ErrorAction SilentlyContinue | Stop-Process -Force
Write-Host 'stopped'
