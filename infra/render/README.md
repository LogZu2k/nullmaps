# Deploy NullMaps on Render (Phase 1 — basemap)

This gets the **map** online: a Martin tile server + the static map page.
Routing (Valhalla) and address search (geocoder) are heavier/paid and are left
for later — the basemap works without them.

Render can't run `docker-compose`, so the repo ships a Blueprint (`render.yaml`)
that declares the two services instead:

| Service | What it is | Render type |
|---|---|---|
| `nullmaps-tiles` | Martin — serves tiles/fonts/sprites under `/tiles/*` | Docker web service |
| `nullmaps-demo` | the static map page, pointed at the tiles service | Static site |

---

## Step 0 — Build the basemap file (on your PC, once)

The map data (`vietnam.pmtiles`, a few hundred MB) is **too big for Git**, so it
lives outside the repo. Build it once:

- Double-click **`start-nullmaps.bat`** in the project folder. It builds
  `data\vietnam.pmtiles`. (You can close it once the file exists.)

## Step 1 — Put the file somewhere downloadable

Render needs an HTTPS link to that file. Pick one:

- **Cloudflare R2** (recommended, free 10 GB): create a bucket, upload
  `vietnam.pmtiles`, enable public access, and turn on CORS (allow `GET` from
  your Render domain or `*`). Copy the public file URL.
- **GitHub Release**: on the repo → Releases → Draft a new release →
  drag-and-drop `vietnam.pmtiles` as an asset → Publish. Copy the asset URL.
  (Simplest, no terminal. If tiles fail to load cross-origin, it's a CORS limit
  of the host — switch to R2.)

Keep this **PMTILES_URL** handy.

## Step 2 — Create the Blueprint on Render

1. Render dashboard → **New** → **Blueprint**.
2. Connect and pick the **`LogZu2k/nullmaps`** repo. Render finds `render.yaml`.
3. It shows two services (`nullmaps-tiles`, `nullmaps-demo`). Click **Apply**.
4. When prompted for env vars, set **`PMTILES_URL`** = the link from Step 1.
   (Leave `NM_ORIGIN` blank for now — set it in Step 3.)

The `nullmaps-tiles` service builds the Docker image and, on first boot,
downloads the basemap. First deploy takes a few minutes.

## Step 3 — Wire the page to the tiles service

1. Once `nullmaps-tiles` is **Live**, copy its URL
   (e.g. `https://nullmaps-tiles.onrender.com`).
2. Open the **`nullmaps-demo`** service → **Environment** → set
   **`NM_ORIGIN`** = that URL → save. It redeploys.
3. Open the `nullmaps-demo` URL — the Hồ Tây basemap should render.

## Verify

- `https://nullmaps-tiles.onrender.com/tiles/catalog` → JSON listing a
  `vietnam` source.
- The demo page shows roads/water/labels and pans/zooms.

## Notes & gotchas

- **Free tier sleeps.** Free web services spin down after ~15 min idle and have
  ephemeral disk — so the basemap re-downloads on the next wake (slow first
  load). For an always-on, fast service, upgrade `nullmaps-tiles` to a paid
  plan and uncomment the `disk:` block in `render.yaml`.
- **Terrain overlays won't show.** Hillshade/contour layers are skipped in this
  Phase-1 setup; the basemap is unaffected.
- **Search/directions won't work yet.** They need the adapter + Valhalla +
  geocoder services, which aren't in this Blueprint. Basemap only for now.
- **CORS.** The tiles service must allow the demo domain to fetch tiles. Martin
  sends permissive CORS by default; if you host the pmtiles on a bucket, set its
  CORS too (Step 1).
