#!/bin/bash
# Build + install स्मृति menu bar app
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="SmritiBar"
APP_BUNDLE="$DIR/$APP_NAME.app"
BINARY="$APP_BUNDLE/Contents/MacOS/$APP_NAME"
BUNDLE_ID="com.rithvik.smriti"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
AGENT_LABEL="com.smriti.bar"
AGENT_DEST="$LAUNCH_AGENTS/$AGENT_LABEL.plist"

echo "▸ Stopping old instance…"
pkill -f "$APP_NAME" 2>/dev/null && sleep 0.4 || true
pkill -x smriti-bar 2>/dev/null && sleep 0.4 || true  # legacy bare-binary name, pre-bundle

echo "▸ Building $APP_NAME.app bundle…"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"

echo "▸ Compiling स्मृति menu bar…"
swiftc "$DIR/smriti-bar.swift" -o "$BINARY" 2>&1
echo "  ✓ Binary: $BINARY"

echo "▸ Writing Info.plist (CFBundleIdentifier: $BUNDLE_ID)…"
cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleName</key>
    <string>smriti</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>2.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST_EOF

# A stable bundle identifier is what lets macOS persistently remember "always
# show this app's menu bar icon" across relaunches, instead of treating every
# restart as a brand-new unrecognized status item and silently collapsing it
# into the overflow area. It also gives WKWebView a stable, persistent
# localStorage location instead of an ambiguous default.

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
    <key>EnvironmentVariables</key>
    <dict>
        <key>SMRITI_PROJECT_DIR</key>
        <string>$DIR</string>
    </dict>
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
