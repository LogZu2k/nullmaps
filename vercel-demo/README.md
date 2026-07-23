# vercel-demo

Static mirror of the NullMaps web app (`services/tiles/style/`) for hosting on Vercel.
Vercel only serves static files — it can't run Martin/Valhalla/the adapter — so this
build step rewrites the page's same-origin calls (`/tiles/*` for the basemap, `/app/*`
for search/directions/isochrone) to point at a real, already-running NullMaps backend
(default: `https://maps.nullshift.sh`). The backend itself must be reachable and must
allow cross-origin requests from the Vercel domain (see the CORS block added to
`infra/gateway/Caddyfile`).

## Deploy

```bash
npm i -g vercel        # once
vercel login            # once, opens a browser to authenticate
cd vercel-demo
vercel --prod            # first run asks to link/create a project
```

Or connect the GitHub repo in the Vercel dashboard and set **Root Directory** to
`vercel-demo` — Vercel will run `build.mjs` (from `vercel.json`) on every push.

To point at a different backend (e.g. a staging box), set the `NM_ORIGIN` environment
variable in the Vercel project settings (Project → Settings → Environment Variables).

## Local check

```bash
NM_ORIGIN=https://maps.nullshift.sh node build.mjs
npx serve public   # or any static file server
```
