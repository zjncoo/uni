#!/bin/bash
set -e

PROJECT_DIR="/Volumes/Install macOS Sequoia/progetti/uni"
cd "$PROJECT_DIR"

echo "=== 1. Building uni.app with Release Configuration ==="
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

# Use local APFS SSD /tmp for fast, reliable SQLite derivedData without external drive I/O errors
BUILD_DIR="/tmp/uni_build_artifacts"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

xcodebuild -project uni.xcodeproj \
  -scheme uni \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR/derivedData" \
  -destination 'generic/platform=macOS' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  DEBUG_INFORMATION_FORMAT=dwarf \
  build

APP_BUNDLE="$BUILD_DIR/derivedData/Build/Products/Release/uni.app"

if [ ! -d "$APP_BUNDLE" ]; then
  echo "Error: uni.app not found at $APP_BUNDLE"
  exit 1
fi

echo "=== uni.app successfully built at $APP_BUNDLE ==="

# Ensure AppIcon.icns and uni_updater.sh are in the app bundle resources
cp "$PROJECT_DIR/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns" || true
cp "$PROJECT_DIR/docs/assets/icon.png" "$APP_BUNDLE/Contents/Resources/AppIcon.png" || true
cp "$PROJECT_DIR/uni_updater.sh" "$APP_BUNDLE/Contents/Resources/uni_updater.sh" || true
chmod +x "$APP_BUNDLE/Contents/Resources/uni_updater.sh" || true

echo "=== 2. Preparing Staging Directory for DMG ==="
STAGING_DIR="/tmp/uni_dmg_staging"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

# Copy App
cp -R "$APP_BUNDLE" "$STAGING_DIR/uni.app"

# Create Applications symlink
ln -s /Applications "$STAGING_DIR/Applications"

# Add .background directory and copy background image
python3 "$PROJECT_DIR/generate_dmg_bg.py"
cp "$PROJECT_DIR/dmg_background.png" "$PROJECT_DIR/docs/assets/dmg_background.png"
cp "$PROJECT_DIR/dmg_background.png" "$PROJECT_DIR/docs/assets/uni-macos/docs/assets/dmg_background.png" 2>/dev/null || true

mkdir -p "$STAGING_DIR/.background"
cp "$PROJECT_DIR/dmg_background.png" "$STAGING_DIR/.background/background.png"
cp "$PROJECT_DIR/dmg_background@2x.png" "$STAGING_DIR/.background/background@2x.png"

# Add Volume Icon
cp "$PROJECT_DIR/AppIcon.icns" "$STAGING_DIR/.VolumeIcon.icns"

echo "=== 3. Creating Temporary RW Disk Image ==="
TEMP_DMG="/tmp/temp_uni.dmg"
RELEASE_DIR="$PROJECT_DIR/release"
mkdir -p "$RELEASE_DIR"
FINAL_DMG="$RELEASE_DIR/uni.dmg"
rm -f "$TEMP_DMG" "$FINAL_DMG"

# Create temporary image with enough space
hdiutil create -srcfolder "$STAGING_DIR" -volname "uni" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size 45m "$TEMP_DMG"

echo "=== 4. Attaching RW Image to configure Finder layout ==="
# Detach any existing /Volumes/uni if present
hdiutil detach /Volumes/uni -force 2>/dev/null || true

# Mount RW DMG
DEV_ATTACH=$(hdiutil attach "$TEMP_DMG" -readwrite -noverify -noautoopen)
echo "$DEV_ATTACH"
sleep 2

# Enable custom volume icon
SetFile -a C /Volumes/uni 2>/dev/null || true

# Apply Finder view settings via AppleScript
osascript << 'APPLESCRIPT' || true
tell application "Finder"
    tell disk "uni"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {200, 160, 860, 600}
        
        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 104
        set text size of theViewOptions to 12
        
        -- Set custom background image
        set background picture of theViewOptions to file ".background:background.png"
        
        -- Position items directly on top of the refined pedestal cards
        set position of item "uni.app" of container window to {185, 205}
        set position of item "Applications" of container window to {475, 205}
        
        update without registering applications
        delay 3
        close
    end tell
end tell
APPLESCRIPT

# Sync changes and unmount
sync
sleep 2
hdiutil detach /Volumes/uni -force 2>/dev/null || true

echo "=== 5. Converting to Final Compressed Read-Only DMG ==="
hdiutil convert "$TEMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$FINAL_DMG" -ov
rm -f "$TEMP_DMG"
rm -rf "$STAGING_DIR"
rm -rf "$BUILD_DIR"

echo "=== SUCCESS: Release artifacts updated in $RELEASE_DIR ==="
ls -lh "$RELEASE_DIR"
