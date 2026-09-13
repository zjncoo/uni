#!/bin/bash
# uni_updater.sh — Auto-updater script for uni.app
# Called by the app to download and install the latest release.
# Arguments: $1 = DMG download URL, $2 = old app PID to quit after install
# Runs OUTSIDE the app sandbox so it can write to /Applications.

set -euo pipefail

DMG_URL="${1:-https://github.com/zjncoo/uni/releases/latest/download/uni.dmg}"
OLD_PID="${2:-}"
APP_DEST="/Applications/uni.app"
TMP_DMG="/tmp/uni_update_$(date +%s).dmg"
MOUNT_POINT="/Volumes/uni_update"

log() { echo "[uni-updater] $*"; }

log "Downloading uni.dmg..."
curl -L --progress-bar -o "$TMP_DMG" "$DMG_URL"
log "Download complete."

hdiutil detach "$MOUNT_POINT" -force 2>/dev/null || true

log "Mounting DMG..."
hdiutil attach "$TMP_DMG" -nobrowse -readonly -mountpoint "$MOUNT_POINT" -quiet
sleep 1

if [ ! -d "$MOUNT_POINT/uni.app" ]; then
    log "ERROR: uni.app not found in DMG"
    hdiutil detach "$MOUNT_POINT" -force 2>/dev/null || true
    rm -f "$TMP_DMG"
    exit 1
fi

if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
    log "Quitting old uni (PID $OLD_PID)..."
    kill -TERM "$OLD_PID" 2>/dev/null || true
    sleep 2
    kill -KILL "$OLD_PID" 2>/dev/null || true
fi
pkill -x "uni" 2>/dev/null || true
sleep 1

log "Installing new uni.app..."
rm -rf "$APP_DEST"
cp -R "$MOUNT_POINT/uni.app" "$APP_DEST"
log "Installed."

xattr -rc "$APP_DEST" 2>/dev/null || true

hdiutil detach "$MOUNT_POINT" -force -quiet 2>/dev/null || true
rm -f "$TMP_DMG"
log "Cleanup done."

log "Launching new uni..."
sleep 0.5
open -n "$APP_DEST"
log "Update complete!"
