#!/bin/bash
# Build + install स्मृति menu bar app
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY="$DIR/smriti-bar"
PLIST="$DIR/smriti-bar.plist"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
AGENT_DEST="$LAUNCH_AGENTS/com.rjavgal.smriti-bar.plist"

echo "▸ Compiling स्मृति menu bar…"
swiftc "$DIR/smriti-bar.swift" -o "$BINARY" 2>&1
echo "  ✓ Binary: $BINARY"

echo "▸ Stopping old instance…"
pkill -f smriti-bar 2>/dev/null && sleep 0.4 || true

echo "▸ Installing LaunchAgent…"
mkdir -p "$LAUNCH_AGENTS"
cp "$PLIST" "$AGENT_DEST"
launchctl unload "$AGENT_DEST" 2>/dev/null || true
launchctl load "$AGENT_DEST"
echo "  ✓ LaunchAgent installed — will start at login automatically"

echo ""
echo "✓ Done. Look for ☀ स्मृति in your menu bar."
echo "  • Click 'Open स्मृति' to launch the sticky panel"
echo "  • Click 'Hide' to minimize for 65s"
echo "  • The app restarts automatically on login"
