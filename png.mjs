// Trasforma icon.svg nei PNG che iOS e i social sanno leggere: l'SVG,
// per apple-touch-icon e per le anteprime dei link, non lo guarda nessuno.
import { chromium } from "playwright";
import fs from "node:fs";
const svg = fs.readFileSync("icon.svg", "utf8");
const b = await chromium.launch({ executablePath: "/opt/pw-browsers/chromium" });
const page = await b.newPage();
for (const n of [32, 180, 192, 512]) {
  await page.setViewportSize({ width: n, height: n });
  await page.setContent(`<style>html,body{margin:0;padding:0}svg{display:block;width:${n}px;height:${n}px}</style>${svg}`);
  await page.screenshot({ path: `icon-${n}.png`, omitBackground: true });
  console.log("icon-" + n + ".png");
}

// L'anteprima quando si condivide il link: un'immagine larga, non l'icona
// stirata. Stessi colori e stesse tre righe della schermata d'ingresso.
await page.setViewportSize({ width: 1200, height: 630 });
await page.setContent(`
<style>
  @import url('');
  html,body { margin:0; padding:0; width:1200px; height:630px; }
  body {
    font-family: -apple-system, "Helvetica Neue", Arial, sans-serif;
    background: linear-gradient(135deg, #a78bfa 0%, #5b21b6 100%);
    color:#fff; display:flex; flex-direction:column;
    align-items:center; justify-content:center; gap:18px; text-align:center;
  }
  .ic { width:168px; height:168px; filter: drop-shadow(0 18px 40px rgba(20,10,60,.35)); }
  h1 { font-size:78px; margin:6px 0 0; letter-spacing:-.02em; font-weight:800; }
  .sub { font-size:30px; opacity:.86; margin:0; }
  .claim { font-size:33px; font-weight:600; line-height:1.5; margin:10px 0 0; }
</style>
<div class="ic">${svg}</div>
<h1>Demo interattive</h1>
<p class="sub">Una raccolta di demo brevi da fare durante le interazioni.</p>
<p class="claim">Prova l'approccio, guida la demo passo passo,<br>racconta i vantaggi!</p>`);
await page.waitForTimeout(300);
await page.screenshot({ path: "social.png" });
console.log("social.png");
await b.close();
