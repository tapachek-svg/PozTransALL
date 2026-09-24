# Handoff: PozTrans project state (2026-09-21)

Owner: tapachek. Language with the owner: Russian. OS: Windows 10, PowerShell + Git Bash. `python` works, `python3` is a Store stub (does not work).

## Rules the owner set
- Do NOT touch `.git` inside the three project folders (they are separate repos with their own remotes). The outer `CODING` repo (remote `tapachek-svg/PozTransALL`) holds only gitlinks. Nothing from this work has been committed or pushed; do not commit/push unless asked.
- Keep the client IP in AppServer's access log (owner declined removing it).
- Keep the `/vm/method.vm` request format (owner declined switching to custom REST paths, for now).
- All PEKA branding was removed (trademark). Names are PozTrans / PoznanTransit. The app no longer calls the real peka.poznan.pl.
- Postponed by the owner: raising `RATE_LIMIT_MAX_REQUESTS` on the ZTM server (30 req / 10 s per IP), and CORS for a web build (`ALLOWED_ORIGINS` in ZTM `.env`, `CORS_ORIGINS` in AppServer `.env` still point to the old domain).

## Layout (`C:\Users\admin\Desktop\CODING`)
| Folder | What | Port |
|---|---|---|
| `PoznanTransit/` | Expo/React Native app (Android package `com.app.poznantransittracker`). pnpm, not npm. | Metro 8081 |
| `ZTM parser to API server/` | FastAPI: departures/stops from ZTM Poznan GTFS. Endpoints `/vm/method.vm`, `/stops`, `/health`, `/ready`, `/docs`, `/`. | 8000 |
| `AppServer/` | Express+MySQL "health/platform" server: `/health`, `/apps/:appId/status`, `/apps/:appId/report-error`, admin panel `/admin/`. Runs only on the primary PC. | 8001 |
| `scripts/`, `start-all.bat`, `stop-all.bat` | Launchers with auto-restart loops, `check-health.ps1` | - |

Database: portable MariaDB 11.4 at `C:\Users\admin\mariadb-dev` (127.0.0.1:3306, DB `app_platform`). Credentials are in `AppServer/.env` (do not print or commit them).

## Public URLs (Cloudflare tunnel `f44dd1c2-...`, config `C:\Users\admin\.cloudflared\config.yml`)
Single host `poztrans.tikgamer.win` with path routing:
- `/api/*` -> ZTM API :8000. The prefix is stripped in `ZTM parser to API server/main.py` (ASGI wrapper), so `/api/health`, `/api/stops`, `/api/vm/method.vm`.
- `/health`, `/apps/*`, `/admin/*` -> AppServer :8001.
- Old `apipoztrans` / `apppoztrans` hosts were removed.
- Twin-PC config draft: `scripts/tunnel-config.twin.yml` (has a `PRIMARY_APPSERVER_URL` placeholder; untested; needs a private route to the primary's AppServer, e.g. Tailscale).

## How to run
- Start everything (DB, ZTM, AppServer, tunnel + health check): `start-all.bat` (or `powershell -ExecutionPolicy Bypass -File scripts/start-all.ps1`).
- Stop: `stop-all.bat`. Metro must be stopped separately (kill whatever listens on 8081).
- Health check: `scripts/check-health.ps1`.
- AppServer: `npm run build` in `AppServer/` after changing `src/`; admin UI: `npm --prefix admin-ui run build`. Tests: `npm test`. Typecheck: `npm run lint`.
- App: in `PoznanTransit/`: `pnpm exec tsc --noEmit`, `pnpm exec vitest run`. JS-only changes need no APK rebuild (debug build from 2026-09-15 is on the phone).
- Phone: Realme RMX3085, adb serial `4D65V4MJSSCEZLCU`, adb at `C:\Users\admin\AppData\Local\Android\Sdk\platform-tools\adb.exe`. Run the app: `adb reverse tcp:8081 tcp:8081`, start Metro (`EXPO_USE_METRO_WORKSPACE_ROOT=1 pnpm exec expo start --dev-client --port 8081`), then `adb shell monkey -p com.app.poznantransittracker -c android.intent.category.LAUNCHER 1`. Screen mirroring: scrcpy 4.1 installed via winget (`scrcpy --serial=4D65V4MJSSCEZLCU`; do not pass window titles with spaces).

## Current state right now
Everything is UP: MariaDB, ZTM API, AppServer, tunnel, Metro, and the app is open on the phone. All health checks were green at the last check.

## What was done in this session
1. Analysed the three projects and linked them; created launcher scripts; tested fault tolerance (killed ZTM, AppServer and the tunnel: all self-recovered in 3-13 s; the app fails open when AppServer is down).
2. Removed tRPC from the app entirely. `PoznanTransit/lib/api.ts` is a plain REST client (timeouts, fail-open status, queued error reports); `lib/api-hooks.ts` has react-query hooks. Deleted `server/`, `drizzle/`, tRPC/express/etc. dependencies. Env overrides: `EXPO_PUBLIC_ZTM_API_URL`, `EXPO_PUBLIC_APP_PLATFORM_URL`, `EXPO_PUBLIC_APP_PLATFORM_APP_ID`.
3. Removed all PEKA references (code, UI strings in 11 languages, docs; `Peka-Virtual-Monitor.html` -> `Transit-Monitor.html`, logs -> `poztrans.log`).
4. Path-based routing on one host (see above). AppServer `.env`: `TRUST_PROXY=true`.
5. Admin panel "Activity" block (Stats tab): distinct clients active in the last 30 s / 2 min / 5 min plus a chart for 1/3/6/12/24 h. It is computed only from `request_log` (status requests on app launch and error reports); there is deliberately NO heartbeat/ping. Code: `AppServer/src/services/activityService.ts`, route `GET /admin/api/apps/:appId/activity?hours=`, UI in `admin-ui/src/components/StatsTab.tsx`.
6. Verified on the phone: departures, map, stop search, and AppServer receives status requests.

Tests at last run: AppServer 34/34, app 25/25, both typechecks clean.

## Open items / ideas
- Before publishing: remove any remaining dependence on PEKA-like naming if the owner wants (`/vm/method.vm`), add ZTM open-data attribution in the app (source, update date, fact of processing).
- Twin server on a second PC/VPS (owner was comparing VPS: Netcup VPS 500 about 5.91 EUR/month incl. VAT, about 309 PLN/year; Hetzner CAX11 5.99 EUR net). AppServer stays on the primary only.
- Delete leftover `PoznanTransit/android` generated files? Not needed; ignore.
- The unclean-shutdown error report #3 in AppServer's `error_reports` came from a `force-stop` of the app during testing; it can be marked "ignored" in the admin panel.
- Shell quirk: multi-line heredocs containing certain control characters get rejected by the Bash tool; write files with the Write tool instead.
