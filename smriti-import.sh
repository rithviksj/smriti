#!/bin/bash
# Import smriti localStorage from ~/dotfiles/smriti-sync.json → open Chrome tab
# Run after: cd ~/dotfiles && git pull

SYNC_FILE="$HOME/dotfiles/smriti-sync.json"

if [ ! -f "$SYNC_FILE" ]; then
  echo "❌ No sync file at $SYNC_FILE — run smriti-export.sh on the source machine first"
  exit 1
fi

# Extract the actual localStorage value from the wrapper JSON
SMRITI_DATA=$(python3 -c "
import json, sys
with open('$SYNC_FILE') as f:
    wrapper = json.load(f)
inner = wrapper.get('data', '')
if not inner:
    sys.exit(1)
print(inner)
" 2>/dev/null)

if [ -z "$SMRITI_DATA" ]; then
  echo "❌ Sync file is empty or malformed"
  exit 1
fi

# Escape for safe JS string injection
ESCAPED=$(python3 -c "
import json, sys
data = sys.stdin.read()
print(json.dumps(data))
" <<< "$SMRITI_DATA")

RESULT=$(osascript << APPLESCRIPT
tell application "Google Chrome"
  repeat with w in every window
    repeat with t in every tab of w
      if URL of t contains "smriti" then
        execute javascript "localStorage.setItem('smriti_v2', ${ESCAPED}); localStorage.setItem('stickies_v2', ${ESCAPED}); location.reload();" in t
        return "imported"
      end if
    end repeat
  end repeat
end tell
return "no_tab"
APPLESCRIPT
)

if [ "$RESULT" = "imported" ]; then
  echo "✅ Imported smriti data — tab reloaded"
else
  echo "❌ No smriti tab found in Chrome — open smriti first (bash open-smriti.sh)"
  exit 1
fi
