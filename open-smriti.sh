#!/bin/bash
# Open स्मृति as a floating sticky panel via localhost
# Serving from localhost (not file://) lets Chrome persist mic permission across sessions.

PORT=1917
PANEL_W=782
PANEL_H=612
POS_X=367
POS_Y=45

DIR="$(cd "$(dirname "$0")" && pwd)"

# If smriti is already open in Chrome, just focus it — don't spawn a new window
ALREADY_OPEN=$(osascript 2>/dev/null << 'APPLESCRIPT'
tell application "Google Chrome"
  repeat with w in every window
    repeat with t in every tab of w
      if URL of t contains "localhost:1917" or URL of t contains "smriti" then
        set index of w to 1
        activate
        return "yes"
      end if
    end repeat
  end repeat
end tell
return "no"
APPLESCRIPT
)

if [ "$ALREADY_OPEN" = "yes" ]; then
  exit 0
fi

# Start HTTP server only if not already listening on the port
if ! lsof -i :$PORT -sTCP:LISTEN &>/dev/null 2>&1; then
  pkill -f "http.server $PORT" 2>/dev/null || true
  sleep 0.2
  python3 -m http.server $PORT --directory "$DIR" --bind 127.0.0.1 &>/dev/null &
  sleep 0.3
fi

# Open smriti in Chrome app mode (no -n so macOS won't force a new instance)
open -a "Google Chrome" --args \
  --app="http://localhost:$PORT/smriti.html" \
  --window-size=${PANEL_W},${PANEL_H} \
  --window-position=${POS_X},${POS_Y}
