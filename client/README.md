# NullMaps JS client

One-import, Google/Goong-compatible client for NullMaps. Browser or Node (needs `fetch`).

```js
import { NullMaps } from "./nullmaps.js";

const nm = new NullMaps({ key: "YOUR_API_KEY" });   // baseUrl defaults to https://maps.nullshift.sh

// Directions (motorbike by default) — includes turn-by-turn steps
const route = await nm.directions("21.0587,105.8194", "21.0287,105.8524");
console.log(route.routes[0].legs[0].distance.text);          // "5.4 km"
route.routes[0].legs[0].steps.forEach(s => console.log(s.html_instructions));

// Distance matrix
await nm.distanceMatrix(["21.05,105.82"], ["21.03,105.85", "21.07,105.80"]);

// Geocode + viewport bias, reverse, autocomplete
await nm.geocode("thanh nien", { location: "21.058,105.818" });
await nm.reverse(21.0587, 105.8194);
await nm.autocomplete("ho tay", { location: "21.058,105.818" });

// AI address cleanup (opt-in)
await nm.geocode("Q.Tay Ho P.Quang An", { normalize: 1 });

// Fleet
await nm.optimizedRoute(["21.05,105.82", "21.08,105.79", "21.03,105.85", "21.06,105.84"]); // TSP
await nm.isochrone("21.0587,105.8194", [10, 20]);            // reachability polygons
await nm.snap(["21.0587,105.8194", "21.0560,105.8210"]);     // snap-to-roads
```

## Map features (MapLibre helpers)

```js
const map = nm.map(maplibregl, "map", { theme: "dark", controls: true });

// draw a route on the map
const route = await nm.directions("21.0587,105.8194", "21.0287,105.8524");
map.on("load", () => nm.renderRoute(map, route));            // polyline + fitBounds

// cluster many points (fleet / stations)
nm.addClusters(map, [{ lat: 21.05, lng: 105.82, id: "A" }, /* ... */]);

// overlay your own GeoJSON (showrooms/stations)
nm.addOverlay(map, myStationsGeoJSON, { color: "#163300" });
```

`map()` adds navigation / scale / geolocate / fullscreen controls by default (`controls: false` to skip).

### Static map image (client-side)

```js
// renders offscreen, returns a PNG data URL — no server renderer needed
const png = await nm.staticImage(maplibregl, {
  center: [105.818, 21.058], zoom: 13, size: [600, 400],
  markers: [{ lng: 105.818, lat: 21.058, color: "#00B260" }],
});
img.src = png;  // or upload the data URL
```

For backend/email-side rendering (no browser), a server GL renderer (maplibre-gl-native /
tileserver-gl) would be a separate service — deliberately not added to the shared box.

## Embed the map (MapLibre)

```html
<link href="https://unpkg.com/maplibre-gl@4/dist/maplibre-gl.css" rel="stylesheet" />
<script type="module">
  import maplibregl from "https://unpkg.com/maplibre-gl@4/dist/maplibre-gl.js";
  import { NullMaps } from "./nullmaps.js";
  const nm = new NullMaps({ key: "YOUR_API_KEY" });
  nm.map(maplibregl, "map");        // self-hosted VN basemap, centered on Hồ Tây (Hà Nội)
</script>
<div id="map" style="height:100vh"></div>
```

## API docs

Interactive OpenAPI / Swagger UI: **https://maps.nullshift.sh/docs** (schema at `/openapi.json`).

## Notes

- Auth: the client sends `?key=`. You can also use header `X-API-Key`.
- `mode`/`vehicle`: unspecified → motorbike (`motor_scooter`); `driving`→car, `walking`, `bicycling`.
- Tiles/style/demo are read-only (no key); the API endpoints require the key.
