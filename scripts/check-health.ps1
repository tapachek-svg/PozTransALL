# Checks both servers locally and (unless -LocalOnly) through the Cloudflare tunnel on the single public host.
param([switch]$LocalOnly)
$fail = 0
function Check($label, $url) {
    try {
        $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        Write-Host ("OK   {0,-26} {1} {2}" -f $label, $r.StatusCode, ($r.Content.Substring(0, [Math]::Min(100, $r.Content.Length)) -replace '\s+', ' '))
    } catch { Write-Host ("FAIL {0,-26} {1}" -f $label, $_.Exception.Message); $script:fail++ }
}
Check 'ZTM  local /health'   'http://127.0.0.1:8000/health'
Check 'App  local /health'   'http://127.0.0.1:8001/health'
if (-not $LocalOnly) {
    Check 'ZTM  public /api/health' 'https://poztrans.tikgamer.win/api/health'
    Check 'App  public /health'     'https://poztrans.tikgamer.win/health'
}
exit $fail
