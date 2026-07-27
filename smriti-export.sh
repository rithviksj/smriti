#!/bin/bash
# Export smriti localStorage from Chrome → ~/dotfiles/smriti-sync.json
# Run on whichever machine has the latest tasks; the other machine runs smriti-import.sh

SYNC_FILE="$HOME/dotfiles/smriti-sync.json"

DATA=$(osascript << 'APPLESCRIPT'
tell application "Google Chrome"
  repeat with w in every window
    repeat with t in every tab of w
      if URL of t contains "smriti" then
        set val to execute javascript "JSON.stringify({data: localStorage.getItem('smriti_v2') || localStorage.getItem('stickies_v2'), ts: Date.now(), src: location.hostname})" in t
        return val
      end if
    end repeat
  end repeat
end tell
return ""
APPLESCRIPT
)

if [ -z "$DATA" ] || [ "$DATA" = "null" ] || [ "$DATA" = "" ]; then
  echo "❌ No smriti tab open in Chrome — open smriti first (bash open-smriti.sh)"
  exit 1
fi

echo "$DATA" > "$SYNC_FILE"
BYTES=$(wc -c < "$SYNC_FILE" | tr -d ' ')
echo "✅ Exported smriti data → $SYNC_FILE ($BYTES bytes)"
echo "   Run: cd ~/dotfiles && git add smriti-sync.json && git commit -m 'smriti sync' && git push"
