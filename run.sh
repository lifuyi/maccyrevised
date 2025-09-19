#!/bin/bash

# Maccy Run Script
# This script runs the existing Maccy application

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="$PROJECT_DIR/Maccy.app"

echo "=== Maccy Run Script ==="
echo "Project directory: $PROJECT_DIR"
echo "App path: $APP_PATH"
echo

# Check if the app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ App bundle not found: $APP_PATH"
    echo "Please build the project first using build.sh or build_and_run.sh"
    exit 1
fi

echo "✅ App bundle found"

# Kill any existing instances
echo "Stopping any existing instances..."
pkill -f "Maccy" &> /dev/null

# Wait a moment for the app to fully quit
sleep 2

# Run the app
echo "Starting Maccy..."
open "$APP_PATH"

if [ $? -eq 0 ]; then
    echo "✅ Maccy is now running!"
else
    echo "❌ Failed to start Maccy"
    exit 1
fi

echo
echo "Maccy should now be running in your menu bar."
echo "To access it:"
echo "  - Click the Maccy icon in the menu bar"
echo "  - Or use the keyboard shortcut: Shift + Command + C"