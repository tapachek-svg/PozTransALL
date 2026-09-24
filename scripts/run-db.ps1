# Portable MariaDB (C:\Users\admin\mariadb-dev) on 127.0.0.1:3306, auto-restart.
$Host.UI.RawUI.WindowTitle = 'PozTrans: MariaDB :3306'
$root = 'C:\Users\admin\mariadb-dev'
while ($true) {
    Write-Host "[$(Get-Date -Format s)] [db] starting"
    & "$root\mariadb-11.4.4-winx64\bin\mariadbd.exe" "--defaults-file=$root\data\my.ini" --console
    Write-Host "[$(Get-Date -Format s)] [db] exited (code $LASTEXITCODE), restart in 5s (Ctrl+C to stop)"
    Start-Sleep -Seconds 5
}
