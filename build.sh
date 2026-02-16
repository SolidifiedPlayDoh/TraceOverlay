#!/bin/bash
# Build TraceOverlay.app from Swift (no Xcode). Run: ./build.sh && open TraceOverlay.app
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="TraceOverlay"
APP_DIR="$SCRIPT_DIR/${APP_NAME}.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"

command -v swiftc &>/dev/null || { echo "error: swiftc not found. Install Xcode Command Line Tools: xcode-select --install"; exit 1; }

rm -rf "$APP_DIR"
mkdir -p "$MACOS"

if xcrun --sdk macosx --show-sdk-path &>/dev/null; then
  swiftc -o "$MACOS/$APP_NAME" \
    -sdk "$(xcrun --sdk macosx --show-sdk-path)" \
    "$SCRIPT_DIR/TraceOverlay.swift"
else
  swiftc -o "$MACOS/$APP_NAME" "$SCRIPT_DIR/TraceOverlay.swift"
fi

cp "$SCRIPT_DIR/Info.plist" "$CONTENTS/"

echo "Built: $APP_DIR"
echo "Run: open '$APP_DIR'"
