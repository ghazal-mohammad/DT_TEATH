// ════════════════════════════════════════════════════════════════════════════
// driver.mjs — headless Chrome driver for the DT.Teeth Flutter web app.
//
// Hosts a release web build and drives a headless Chrome over the Chrome
// DevTools Protocol. ZERO npm dependencies — uses Node 22's built-in global
// `WebSocket`, `fetch`, and `http`. Launches its own Chrome, navigates each
// route (hash routing), waits for Flutter's first frame, writes a PNG per route.
//
// Build first:  flutter build web --release --no-web-resources-cdn
//
// Usage (run from PowerShell — Git Bash mangles leading-'/' route args):
//   node driver.mjs --serve build/web                       # default route set
//   node driver.mjs --serve build/web /lab/orders /warehouse/materials
//   node driver.mjs --base http://127.0.0.1:9100 /splash    # drive a live server
//   node driver.mjs --serve build/web --outdir shots --width 1440 --height 900
//
// Env:
//   CHROME   path to chrome.exe (default: Windows Chrome install path)
//   BASE     base URL of the flutter web server (default http://127.0.0.1:8090)
//
// Output: PNGs land in <outdir> (default: the skill's ./shots) named after the
// route, e.g. shots/lab_dashboard.png. Exit code is non-zero if any route fails.
// ════════════════════════════════════════════════════════════════════════════

import { spawn } from 'node:child_process';
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, existsSync, statSync } from 'node:fs';
import { createServer } from 'node:http';
import { tmpdir } from 'node:os';
import { join, dirname, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// ── args ────────────────────────────────────────────────────────────────────
const argv = process.argv.slice(2);
let base = process.env.BASE || 'http://127.0.0.1:8090';
let outdir = join(__dirname, 'shots');
let serveDir = null;           // if set, the driver hosts this dir itself
let width = 1440, height = 900;
const routes = [];
for (let i = 0; i < argv.length; i++) {
  const a = argv[i];
  if (a === '--base') base = argv[++i];
  else if (a === '--serve') serveDir = argv[++i];
  else if (a === '--outdir') outdir = argv[++i];
  else if (a === '--width') width = Number(argv[++i]);
  else if (a === '--height') height = Number(argv[++i]);
  else routes.push(a);
}
if (routes.length === 0) {
  routes.push('/splash', '/auth/email', '/lab/dashboard', '/warehouse/dashboard');
}
const CHROME = process.env.CHROME ||
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

mkdirSync(outdir, { recursive: true });

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// ── optional static file server with SPA fallback ────────────────────────────
const MIME = { '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.json': 'application/json', '.wasm': 'application/wasm', '.css': 'text/css',
  '.png': 'image/png', '.jpg': 'image/jpeg', '.svg': 'image/svg+xml',
  '.ttf': 'font/ttf', '.otf': 'font/otf', '.ico': 'image/x-icon', '.bin': 'application/octet-stream' };
function startStatic(root, port) {
  return new Promise((resolve) => {
    const srv = createServer((req, res) => {
      let p = decodeURIComponent(req.url.split('?')[0]);
      let file = normalize(join(root, p));
      if (!file.startsWith(normalize(root))) { res.writeHead(403).end(); return; }
      if (!existsSync(file) || statSync(file).isDirectory()) {
        if (existsSync(join(file, 'index.html'))) file = join(file, 'index.html');
        else file = join(root, 'index.html');       // SPA fallback for client routes
      }
      try {
        const ext = file.slice(file.lastIndexOf('.'));
        res.writeHead(200, { 'Content-Type': MIME[ext] || 'application/octet-stream' });
        res.end(readFileSync(file));
      } catch { res.writeHead(404).end(); }
    });
    srv.listen(port, '127.0.0.1', () => resolve(srv));
  });
}

// ── minimal CDP client over a single WebSocket ───────────────────────────────
class CDP {
  constructor(ws) { this.ws = ws; this.id = 0; this.pending = new Map(); this.handlers = new Map();
    ws.addEventListener('message', (ev) => {
      const msg = JSON.parse(ev.data);
      if (msg.id && this.pending.has(msg.id)) {
        const { resolve, reject } = this.pending.get(msg.id);
        this.pending.delete(msg.id);
        msg.error ? reject(new Error(msg.error.message)) : resolve(msg.result);
      } else if (msg.method) {
        (this.handlers.get(msg.method) || []).forEach((h) => h(msg.params));
      }
    });
  }
  send(method, params = {}, sessionId) {
    const id = ++this.id;
    return new Promise((resolve, reject) => {
      this.pending.set(id, { resolve, reject });
      const msg = { id, method, params };
      if (sessionId) msg.sessionId = sessionId;
      this.ws.send(JSON.stringify(msg));
    });
  }
  on(method, h) { if (!this.handlers.has(method)) this.handlers.set(method, []); this.handlers.get(method).push(h); }
}

function connect(url) {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(url);
    ws.addEventListener('open', () => resolve(new CDP(ws)));
    ws.addEventListener('error', (e) => reject(new Error('ws error: ' + (e.message || url))));
  });
}

async function getJSON(url) {
  for (let i = 0; i < 50; i++) {
    try { const r = await fetch(url); if (r.ok) return await r.json(); } catch {}
    await sleep(200);
  }
  throw new Error('timed out waiting for ' + url);
}

// CanvasKit attaches <flutter-view><flt-glass-pane> once the engine has booted
// and painted its first frame (the actual canvas lives in the glass-pane's
// shadow root, so we key off the glass-pane host, not a 'canvas' query).
const FLUTTER_READY =
  `!!document.querySelector('flutter-view flt-glass-pane') && document.title === 'DT.Teeth'`;

async function main() {
  // If asked to serve, host the build dir ourselves and point base at it.
  let staticSrv = null;
  if (serveDir) {
    const root = normalize(serveDir);
    if (!existsSync(join(root, 'index.html')))
      throw new Error(`--serve ${serveDir}: no index.html there (run \`flutter build web\` first?)`);
    const sport = 8000 + Math.floor(Math.random() * 900);
    staticSrv = await startStatic(root, sport);
    base = `http://127.0.0.1:${sport}`;
    process.stdout.write(`serving ${root} at ${base}\n`);
  }

  const port = 9222 + Math.floor(Math.random() * 1000);
  const userDir = mkdtempSync(join(tmpdir(), 'dtteeth-chrome-'));
  const chrome = spawn(CHROME, [
    '--headless=new',
    `--remote-debugging-port=${port}`,
    `--user-data-dir=${userDir}`,
    `--window-size=${width},${height}`,
    '--no-first-run', '--no-default-browser-check',
    '--disable-gpu', '--hide-scrollbars',
  ], { stdio: 'ignore' });

  let failures = 0;
  try {
    const version = await getJSON(`http://127.0.0.1:${port}/json/version`);
    const browser = await connect(version.webSocketDebuggerUrl);
    const { targetId } = await browser.send('Target.createTarget', { url: 'about:blank' });
    const { sessionId } = await browser.send('Target.attachToTarget', { targetId, flatten: true });

    // page session: reuse the same socket/dispatcher, tag sends with sessionId
    const page = { send: (m, p = {}) => browser.send(m, p, sessionId), on: (m, h) => browser.on(m, h) };

    await page.send('Page.enable');
    await page.send('Runtime.enable');
    await page.send('Emulation.setDeviceMetricsOverride',
      { width, height, deviceScaleFactor: 1, mobile: false });

    for (const route of routes) {
      // Flutter web uses HASH routing (no usePathUrlStrategy in this app), so the
      // route lives after '#'. The cache-busting query forces a full document
      // reload between routes — otherwise a bare hash change wouldn't reload.
      const r = route.startsWith('/') ? route : '/' + route;
      const url = `${base.replace(/\/$/, '')}/?_r=${Date.now()}#${r}`;
      process.stdout.write(`→ ${url}\n`);
      try {
        await page.send('Page.navigate', { url });
        // wait for Flutter first frame
        let ready = false;
        for (let i = 0; i < 60; i++) {
          const { result } = await page.send('Runtime.evaluate',
            { expression: FLUTTER_READY, returnByValue: true });
          if (result.value === true) { ready = true; break; }
          await sleep(500);
        }
        await sleep(1500); // let animations/charts settle
        const { data } = await page.send('Page.captureScreenshot', { format: 'png' });
        const name = (route.replace(/^\//, '').replace(/\//g, '_') || 'root') + '.png';
        const file = join(outdir, name);
        writeFileSync(file, Buffer.from(data, 'base64'));
        process.stdout.write(`   ${ready ? '✓' : '⚠ (no ready signal)'} ${file}\n`);
      } catch (e) {
        failures++;
        process.stdout.write(`   ✗ ${e.message}\n`);
      }
    }
  } finally {
    chrome.kill();
    if (staticSrv) staticSrv.close();
  }
  process.exit(failures ? 1 : 0);
}

main().catch((e) => { console.error(e); process.exit(2); });
