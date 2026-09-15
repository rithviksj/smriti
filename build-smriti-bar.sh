#!/bin/bash
# Build + install स्मृति menu bar app
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY="$DIR/smriti-bar"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
AGENT_LABEL="com.smriti.bar"
AGENT_DEST="$LAUNCH_AGENTS/$AGENT_LABEL.plist"

echo "▸ Compiling स्मृति menu bar…"
swiftc "$DIR/smriti-bar.swift" -o "$BINARY" 2>&1
echo "  ✓ Binary: $BINARY"

echo "▸ Stopping old instance…"
pkill -f smriti-bar 2>/dev/null && sleep 0.4 || true

echo "▸ Installing LaunchAgent…"
mkdir -p "$LAUNCH_AGENTS"
cat > "$AGENT_DEST" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$AGENT_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BINARY</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/smriti-bar.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/smriti-bar.log</string>
</dict>
</plist>
PLIST_EOF
launchctl unload "$AGENT_DEST" 2>/dev/null || true
launchctl load "$AGENT_DEST"
echo "  ✓ LaunchAgent installed — will start at login automatically"

echo ""
echo "✓ Done. Look for ☀ स्मृति in your menu bar."
echo "  • Click 'Open स्मृति' to launch the sticky panel"
echo "  • Click 'Hide' to minimize for 65s"
echo "  • The app restarts automatically on login"
