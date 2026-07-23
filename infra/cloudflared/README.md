# Cloudflare Tunnel — free VPS alternative

Runs the whole NullMaps stack on any machine that stays on (this dev box, a spare PC, a
NAS) and publishes it through Cloudflare's network instead of a rented VPS. Free
forever, no port forwarding, TLS handled by Cloudflare, and it reuses the same
`docker-compose.yml` already in this repo — the gateway stays the single front door,
`cloudflared` just tunnels to it over the internal Docker network.

Trade-off vs. a real VPS: this machine (and Docker) must stay running for the backend
to be reachable. Fine for a personal, single-operator setup; not for something that
needs to survive a reboot unattended unless you also set this machine to auto-start
Docker Desktop / the compose stack on boot.

## One-time setup (in the Cloudflare dashboard — your account, can't be scripted)

1. Go to [one.dash.cloudflare.com](https://one.dash.cloudflare.com/) → **Networks → Tunnels**
   → **Create a tunnel** → connector type **Cloudflared** → name it (e.g. `nullmaps`).
2. On the "Install and run connector" step, copy the **token** out of the shown
   `docker run ... --token eyJ...` command (you don't need to run that command — the
   compose service below does the same thing). Put it in `.env`:
   ```
   CLOUDFLARE_TUNNEL_TOKEN=eyJ...
   ```
3. Go to the tunnel's **Public Hostname** tab → **Add a public hostname**:
   - Subdomain/domain: whatever you want reachable, e.g. `maps.nullshift.sh`
   - Service: **HTTP**, URL: `gateway:8088`
   - Save — Cloudflare manages the DNS record for you (remove any old A/CNAME record
     for that hostname if one still points at the retired VPS).

## Run it

```bash
docker compose up -d                                              # the full stack (gateway, adapter, etc.)
docker compose -f docker-compose.yml -f infra/cloudflared/docker-compose.yml up -d cloudflared
docker compose -f docker-compose.yml -f infra/cloudflared/docker-compose.yml logs -f cloudflared
```

Look for `Registered tunnel connection` in the logs, then hit your hostname from
anywhere — it should reach this machine's gateway.

## Notes

- The gateway is still the only thing `cloudflared` talks to (`gateway:8088`) — the
  API-key gate, CORS, and route rules in `infra/gateway/Caddyfile` all still apply.
  Nothing new is exposed; the tunnel just replaces "a VPS with a public IP" as the way
  traffic reaches the same gateway.
- To stop publishing without stopping the stack: `docker compose stop cloudflared`.
