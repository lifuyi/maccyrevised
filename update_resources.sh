#!/bin/bash

# Maccy Resource Update Script
# This script updates the Maccy app with our modified resources without requiring Xcode

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_APP="$PROJECT_DIR/Maccy.app"
MODIFIED_APP="$PROJECT_DIR/Maccy-modified.app"
RESOURCES_DIR="$PROJECT_DIR/Maccy"

echo "=== Maccy Resource Update Script ==="
echo "Project directory: $PROJECT_DIR"
echo

# Check if source app exists
if [ ! -d "$SOURCE_APP" ]; then
    echo "❌ Source app not found: $SOURCE_APP"
    exit 1
fi

echo "✅ Source app found"

# Create/overwrite modified app
echo "Creating modified app..."
rm -rf "$MODIFIED_APP"
cp -R "$SOURCE_APP" "$MODIFIED_APP"

if [ $? -ne 0 ]; then
    echo "❌ Failed to copy app"
    exit 1
fi

echo "✅ Modified app created"

# Update resource files
echo "Updating resource files..."

# Update English AppearanceSettings.strings
if [ -f "$RESOURCES_DIR/Settings/en.lproj/AppearanceSettings.strings" ]; then
    cp "$RESOURCES_DIR/Settings/en.lproj/AppearanceSettings.strings" "$MODIFIED_APP/Contents/Resources/en.lproj/"
    echo "✅ Updated AppearanceSettings.strings"
fi

# Update other language AppearanceSettings.strings files if they exist in our source
for lang_dir in "$RESOURCES_DIR/Settings/"*; do
    if [ -d "$lang_dir" ] && [ -f "$lang_dir/AppearanceSettings.strings" ]; then
        lang=$(basename "$lang_dir")
        if [ -d "$MODIFIED_APP/Contents/Resources/$lang.lproj/" ]; then
            cp "$lang_dir/AppearanceSettings.strings" "$MODIFIED_APP/Contents/Resources/$lang.lproj/"
            echo "✅ Updated $lang AppearanceSettings.strings"
        fi
    fi
done

# Remove code signature (this may be needed for modifications to work)
echo "Removing code signature..."
rm -rf "$MODIFIED_APP/Contents/_CodeSignature"

# Update the bundle identifier to avoid conflicts
echo "Updating bundle identifier..."
plutil -replace CFBundleIdentifier -string "org.p0deje.Maccy.modified" "$MODIFIED_APP/Contents/Info.plist"

echo "✅ Code signature removed and bundle identifier updated"

# Try to run the app
echo
echo "=== Running Modified Maccy ==="
echo "Stopping any existing instances..."
pkill -f "Maccy-modified" &> /dev/null
pkill -f "Maccy" &> /dev/null

# Wait a moment
sleep 2

echo "Starting modified Maccy..."
open "$MODIFIED_APP"

if [ $? -eq 0 ]; then
    echo "✅ Modified Maccy is now running!"
    echo
    echo "Modified app location: $MODIFIED_APP"
    echo "You can run it again with: open \"$MODIFIED_APP\""
else
    echo "❌ Failed to start modified Maccy"
    exit 1
fi