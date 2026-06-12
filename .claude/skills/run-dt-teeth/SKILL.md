---
name: run-dt-teeth
description: Build, run, and screenshot the DT.Teeth Flutter web app (dental-clinic lab + warehouse management). Use when asked to run, start, launch, serve, build, or screenshot DT.Teeth / dt_teeth, or to verify a UI change renders in the real app.
---

# Run DT.Teeth (Flutter web)

DT.Teeth (`dt_teeth`) is a Flutter app — an Arabic-first (RTL) dental-clinic
management system with **Lab** and **Warehouse** sub-systems. It targets web,
desktop, and mobile; the **web** target is the only one that's headless-driveable,
so that's what this skill uses.

The agent path is a committed, dependency-free Node driver,
[`.claude/skills/run-dt-teeth/driver.mjs`](driver.mjs), that hosts a release web
build, drives a headless Chrome over the DevTools Protocol, navigates each route,
waits for Flutter's first paint, and writes one PNG per route. It uses only
Node 22 built-ins (`WebSocket`, `fetch`, `http`) — **no `npm install`**.

> Paths below are relative to the project root
> (`…/dt_teeth_clean`). All commands were run from there.

## Prerequisites

- **Flutter 3.35.7** (stable) — `flutter --version`. Web enabled by default.
- **Node 22+** — the driver needs the global `WebSocket` (Node 22 has it).
- **Google Chrome** — driver defaults to
  `C:\Program Files\Google\Chrome\Application\chrome.exe`; override with the
  `CHROME` env var.

No `apt-get`/extra packages: this app builds and runs on a normal Windows dev box.

## Build

```powershell
flutter pub get
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run
```

`--no-web-resources-cdn` is **load-bearing**: without it Flutter fetches
CanvasKit from `www.gstatic.com` at runtime, which is flaky/blank in headless
Chrome. The flag bundles `canvaskit/` into `build/web` so everything is local.
First build takes ~80–100s. Output lands in `build/web`.

## Run (agent path) — screenshots

The driver serves `build/web` itself (ephemeral port, SPA-aware) and screenshots
a default route set: `/splash`, `/auth/email`, `/lab/dashboard`,
`/warehouse/dashboard`.

```powershell
node .claude\skills\run-dt-teeth\driver.mjs --serve build\web
```

Pass your own routes (note: hash routing is handled for you — pass the plain
path):

```powershell
node .claude\skills\run-dt-teeth\driver.mjs --serve build\web /lab/orders /warehouse/materials
```

PNGs land in `.claude/skills/run-dt-teeth/shots/` (one per route, e.g.
`lab_dashboard.png`). A `✓` per route means Flutter's first frame was detected
before the shot. **Open the PNG and look at it** — committed examples are already
in `shots/`.

Useful flags: `--outdir <dir>`, `--width 1440 --height 900`,
`--base http://127.0.0.1:PORT` (drive an already-running server instead of
`--serve`). Env: `CHROME`, `BASE`.

Routes that render rich mock data (no login needed — see Gotchas):
`/lab/dashboard`, `/lab/orders`, `/lab/technicians`, `/lab/material-requests`,
`/warehouse/dashboard`, `/warehouse/materials`, `/warehouse/orders`,
`/warehouse/suppliers`. Full list: `lib/core/router/route_names.dart`.

## Run (human path)

```powershell
flutter run -d chrome --web-port 8090
```

Opens a real Chrome window with hot reload. Useless headless, and the dev build
uses the DDC module loader (≈744 separate `.js` requests) — slow to first paint
and unreliable to screenshot. Use the release build + driver above for any
automated/headless interaction.

## Test

```powershell
flutter test
```

## Gotchas

- **Hash routing.** The app never calls `usePathUrlStrategy`, so Flutter web uses
  `/#/route` URLs. Hitting `http://host/lab/dashboard` (no `#`) just loads the
  app at its initial route. The driver builds `…/?_r=<ts>#/route` for you — the
  query forces a full reload between routes (a bare hash change wouldn't reload).
- **CanvasKit from CDN = blank screen.** A plain `flutter build web` pulls
  CanvasKit from gstatic; headless Chrome then renders blank/white intermittently.
  Always build with `--no-web-resources-cdn`.
- **Arabic may render as tofu (□□□) on heavy pages.** The UI font (Cairo/Tajawal
  via `google_fonts`) is fetched from gstatic at runtime. Light pages (splash,
  `/auth/email`) finish loading it and show Arabic correctly; data-heavy pages
  (`/lab/dashboard`, `/warehouse/dashboard`) often get screenshotted before the
  font lands, so their Arabic shows as boxes. **This is not a render failure** —
  layout, colors, Latin text and numbers (`LAB-045`, `PFM`, `2.8M`) are all
  correct. To get Arabic on the heavy pages, raise the post-paint settle delay in
  `driver.mjs` (the `await sleep(1500)` after readiness) or ensure gstatic is
  reachable.
- **No auth gate yet.** `RouteGuards.guard` currently does *not* enforce login
  (`lib/core/router/route_guards.dart` — re-enabled in "Phase 6"), so internal
  routes like `/lab/dashboard` render directly with mock data. No backend or
  token needed for screenshots. (The Laravel backend at `localhost:8000` is only
  needed for live auth/data flows, not for UI rendering.)
- **CanvasKit paints into shadow DOM.** There is no queryable `<canvas>` in the
  light DOM; the driver's readiness probe keys off
  `flutter-view flt-glass-pane` + `document.title === 'DT.Teeth'`.
- **Git Bash mangles `/route` args.** MSYS path conversion rewrites a leading-`/`
  argument into a Windows path (`/splash` → `C:/Program Files/Git/splash`). Run
  the driver from **PowerShell** (the project default), or prefix
  `MSYS_NO_PATHCONV=1`, or just use the built-in default routes (hard-coded in the
  `.mjs`, immune to this).
- **A service worker is registered** by the release bundle; the driver uses a
  fresh Chrome `--user-data-dir` per run, so stale SW caching isn't an issue.

## Troubleshooting

- **Blank white PNG** → either you built *with* the CDN (rebuild with
  `--no-web-resources-cdn`), or you pointed `--base` at the `flutter run` DDC dev
  server instead of the release build. Confirm `build/web/canvaskit/` exists.
- **`--serve …: no index.html there`** → run `flutter build web` first.
- **`spawn … chrome.exe ENOENT`** → set `CHROME` to your Chrome path.
- **Port 8090 already in use** (human path) → a leftover dev server; kill it with
  `taskkill /F /IM dart.exe`.
- **Driver hangs ~30s then `⚠ (no ready signal)` but PNG looks fine** → first
  paint was slower than the readiness probe; the shot is still taken. If the PNG
  is blank, it's the CDN-CanvasKit issue above.
