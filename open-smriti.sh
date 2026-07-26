#!/bin/bash
# Open स्मृति as a floating sticky panel via localhost
# Serving from localhost (not file://) lets Chrome persist mic permission across sessions.

PORT=7842
PANEL_W=782
PANEL_H=612
POS_X=367
POS_Y=45

DIR="$(cd "$(dirname "$0")" && pwd)"

# Kill any stale smriti server on this port
pkill -f "http.server $PORT" 2>/dev/null || true
sleep 0.2

# Start local-only HTTP server (127.0.0.1 — not reachable from LAN)
python3 -m http.server $PORT --directory "$DIR" --bind 127.0.0.1 &>/dev/null &
sleep 0.3

open -na "Google Chrome" --args \
  --app="http://localhost:$PORT/smriti.html" \
  --window-size=${PANEL_W},${PANEL_H} \
  --window-position=${POS_X},${POS_Y}
