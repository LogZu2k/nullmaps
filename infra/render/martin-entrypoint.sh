#!/usr/bin/env bash
# Download the basemap once (if not already present), then start Martin.
set -euo pipefail

PMTILES_PATH="${PMTILES_PATH:-/data/vietnam.pmtiles}"
PORT="${PORT:-3000}"

mkdir -p "$(dirname "$PMTILES_PATH")"

if [ ! -s "$PMTILES_PATH" ]; then
  if [ -z "${PMTILES_URL:-}" ]; then
    echo "ERROR: no basemap at $PMTILES_PATH and PMTILES_URL is not set." >&2
    echo "       Set PMTILES_URL (Render dashboard) to a downloadable vietnam.pmtiles link." >&2
    exit 1
  fi
  echo ">> Downloading basemap from \$PMTILES_URL ..."
  curl -fSL --retry 5 --retry-delay 3 -o "${PMTILES_PATH}.tmp" "$PMTILES_URL"
  mv "${PMTILES_PATH}.tmp" "$PMTILES_PATH"
  echo ">> Basemap ready ($(du -h "$PMTILES_PATH" | cut -f1))."
else
  echo ">> Basemap already present at $PMTILES_PATH — skipping download."
fi

echo ">> Starting Martin on 0.0.0.0:${PORT} (route-prefix /tiles)"
exec martin \
  --listen-addresses "0.0.0.0:${PORT}" \
  --route-prefix /tiles \
  --font /fonts \
  --sprite /sprites \
  "$PMTILES_PATH"
