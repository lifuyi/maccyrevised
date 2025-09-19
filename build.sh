#!/bin/bash

# Maccy Build Script
# This script builds the Maccy application bundle

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_FILE="$PROJECT_DIR/Maccy.xcodeproj"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="Maccy"
SCHEME="Maccy"

echo "=== Maccy Build Script ==="
echo "Project directory: $PROJECT_DIR"
echo "Build directory: $BUILD_DIR"
echo

# Check if Xcode is properly installed
echo "Checking for Xcode installation..."
if ! xcode-select -p &> /dev/null; then
    echo "❌ Xcode command line tools not found."
    echo
    echo "To build Maccy, please install Xcode from the Mac App Store:"
    echo "1. Open the Mac App Store"
    echo "2. Search for 'Xcode'"
    echo "3. Install Xcode"
    echo "4. After installation, run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo "5. Then run this script again"
    echo
    exit 1
fi

# Test if xcodebuild works properly
echo "Testing xcodebuild..."
XCODEBUILD_TEST_OUTPUT=$(mktemp)
xcodebuild -version >"$XCODEBUILD_TEST_OUTPUT" 2>&1
XCODEBUILD_TEST_EXIT_CODE=$?

if grep -q "requires Xcode" "$XCODEBUILD_TEST_OUTPUT"; then
    echo "❌ Xcode is not properly installed."
    echo "The xcodebuild tool requires the full Xcode application, not just command line tools."
    echo
    echo "To build Maccy, please install Xcode from the Mac App Store:"
    echo "1. Open the Mac App Store"
    echo "2. Search for 'Xcode'"
    echo "3. Install Xcode"
    echo "4. After installation, run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo "5. Then run this script again"
    echo
    rm "$XCODEBUILD_TEST_OUTPUT"
    exit 1
fi

rm "$XCODEBUILD_TEST_OUTPUT"

echo "✅ Xcode properly configured"

# Check if the project file exists
if [ ! -d "$PROJECT_FILE" ]; then
    echo "❌ Project file not found: $PROJECT_FILE"
    exit 1
fi

echo "✅ Project file found"

# Clean previous builds
echo
echo "=== Cleaning previous builds ==="
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build the project
echo
echo "=== Building $APP_NAME ==="
echo "This may take a few minutes..."

BUILD_START_TIME=$(date +%s)

# Run xcodebuild and capture both output and exit code
BUILD_OUTPUT=$(mktemp)
xcodebuild \
    -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration Debug \
    -derivedDataPath "$BUILD_DIR" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_ENTITLEMENTS="" \
    clean build >"$BUILD_OUTPUT" 2>&1
BUILD_EXIT_CODE=$?

BUILD_END_TIME=$(date +%s)
BUILD_DURATION=$((BUILD_END_TIME - BUILD_START_TIME))

# Check if xcodebuild is properly installed
if grep -q "requires Xcode" "$BUILD_OUTPUT"; then
    echo "❌ Xcode is not properly installed."
    echo "The build failed because xcodebuild requires the full Xcode application."
    echo
    echo "To build Maccy, please install Xcode from the Mac App Store:"
    echo "1. Open the Mac App Store"
    echo "2. Search for 'Xcode'"
    echo "3. Install Xcode"
    echo "4. After installation, run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo "5. Then run this script again"
    echo
    echo "Build output:"
    cat "$BUILD_OUTPUT"
    rm "$BUILD_OUTPUT"
    exit 1
fi

rm "$BUILD_OUTPUT"

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "✅ Build successful! (Duration: ${BUILD_DURATION}s)"
    
    # Find the built app
    APP_PATH=$(find "$BUILD_DIR" -name "$APP_NAME.app" -type d | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "✅ App bundle created at: $APP_PATH"
        echo
        echo "To run the application:"
        echo "  open \"$APP_PATH\""
        echo
        echo "To create a distributable ZIP:"
        echo "  ditto -c -k --keepParent \"$APP_PATH\" \"${APP_NAME}.zip\""
    else
        echo "⚠️  App bundle not found in build directory"
        echo "Please check the build output above for any issues"
    fi
else
    echo "❌ Build failed!"
    echo "Please check the error messages above."
    echo
    echo "Common solutions:"
    echo "1. Make sure you have the latest Xcode installed"
    echo "2. Run: sudo xcodebuild -license accept"
    echo "3. Run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    exit 1
fi