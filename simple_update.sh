#!/bin/bash

# Maccy Simple Update Script
# This script updates specific resource files in the existing Maccy app

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_APP="$PROJECT_DIR/Maccy.app"
RESOURCES_DIR="$PROJECT_DIR/Maccy"

echo "=== Maccy Simple Update Script ==="
echo "Project directory: $PROJECT_DIR"
echo

# Check if target app exists
if [ ! -d "$TARGET_APP" ]; then
    echo "❌ Target app not found: $TARGET_APP"
    exit 1
fi

echo "✅ Target app found"

# Update resource files by copying them directly
echo "Updating resource files..."

# Update English AppearanceSettings.strings
if [ -f "$RESOURCES_DIR/Settings/en.lproj/AppearanceSettings.strings" ]; then
    # Make a backup first
    cp "$TARGET_APP/Contents/Resources/en.lproj/AppearanceSettings.strings" "$TARGET_APP/Contents/Resources/en.lproj/AppearanceSettings.strings.backup"
    cp "$RESOURCES_DIR/Settings/en.lproj/AppearanceSettings.strings" "$TARGET_APP/Contents/Resources/en.lproj/"
    echo "✅ Updated AppearanceSettings.strings"
fi

echo "✅ Resource files updated"

# Try to run the app
echo
echo "=== Running Maccy ==="
echo "Stopping any existing instances..."
pkill -f "Maccy" &> /dev/null

# Wait a moment
sleep 2

echo "Starting Maccy..."
open "$TARGET_APP"

if [ $? -eq 0 ]; then
    echo "✅ Maccy is now running!"
    echo
    echo "You can access the new settings in Maccy preferences:"
    echo "1. Open Maccy (Shift + Command + C)"
    echo "2. Click the menu icon and select Preferences"
    echo "3. Go to the Appearance tab"
    echo "4. Look for 'Max display length' setting"
else
    echo "❌ Failed to start Maccy"
    echo "You may need to temporarily allow the app in System Preferences > Security & Privacy"
fi