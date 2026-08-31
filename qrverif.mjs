// Il QR va letto com'è sullo schermo, non come file: se a quella misura
// non si aggancia, sulla scrivania non lo inquadra nessuno.
import { chromium } from "playwright";
import http from "node:http"; import fs from "node:fs"; import path from "node:path";
const srv = http.createServer((req, res) => {
  const u = req.url.split("?")[0];
  const f = path.join(process.cwd(), u === "/" ? "senza.html" : u);
  if (!fs.existsSync(f)) { res.writeHead(404); res.end(); return; }
  res.writeHead(200, { "content-type": f.endsWith(".js") ? "text/javascript"
    : f.endsWith(".svg") ? "image/svg+xml" : "text/html" });
  res.end(fs.readFileSync(f));
});
await new Promise(r => srv.listen(8111, r));
const b = await chromium.launch({ executablePath: "/opt/pw-browsers/chromium" });
for (const dpr of [1, 3]) {
  const page = await b.newPage({ viewport: { width: 390, height: 700 }, deviceScaleFactor: dpr });
  await page.goto("http://localhost:8111/", { waitUntil: "networkidle" });
  await page.waitForTimeout(300);
  await page.fill("#reg-name", "Marco"); await page.fill("#reg-code", "111111");
  await page.fill("#reg-code2", "111111"); await page.click("#reg-btn");
  await page.waitForTimeout(600);
  await page.click("nav button[data-tab=profilo]");
  await page.waitForTimeout(500);
  await page.locator(".qr").screenshot({ path: `qr-schermo-${dpr}x.png` });
  console.log("catturato a " + dpr + "x");
  await page.close();
}
await b.close(); srv.close();
