// Builds a static mirror of services/tiles/style/* for Vercel: rewrites the
// same-origin paths that only work behind the real gateway (/tiles/*, /app/*)
// to point at the live VPS deployment, since Vercel only hosts static files —
// tiles, geocoding, and routing still come from the self-hosted backend.
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const srcDir = join(here, "..", "services", "tiles", "style");
const outDir = join(here, "public");
const origin = (process.env.NM_ORIGIN || "https://maps.nullshift.sh").replace(/\/+$/, "");

mkdirSync(outDir, { recursive: true });

for (const file of ["style.json", "style-dark.json", "style-terrain.json"]) {
  const text = readFileSync(join(srcDir, file), "utf8").replaceAll('"/tiles/', `"${origin}/tiles/`);
  writeFileSync(join(outDir, file), text);
}

const html = readFileSync(join(srcDir, "index.html"), "utf8")
  .replaceAll('location.origin + "/app"', `${JSON.stringify(origin)} + "/app"`)
  .replaceAll('location.origin + "/tiles/terrain"', `${JSON.stringify(origin)} + "/tiles/terrain"`);
writeFileSync(join(outDir, "index.html"), html);

console.log(`>> vercel-demo built against ${origin} -> ${outDir}`);
