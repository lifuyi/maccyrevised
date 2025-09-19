#!/bin/bash

# Maccy Build and Run Script
# This script builds and runs the Maccy application bundle

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_FILE="$PROJECT_DIR/Maccy.xcodeproj"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="Maccy"
SCHEME="Maccy"

echo "=== Maccy Build and Run Script ==="
echo "Project directory: $PROJECT_DIR"
echo

# Function to check if Xcode is properly installed
check_xcode() {
    echo "Checking for Xcode installation..."
    
    # Check if xcode-select points to a valid path
    if ! xcode-select -p &> /dev/null; then
        echo "❌ Xcode command line tools not found."
        return 1
    fi
    
    # Test if xcodebuild works properly
    XCODEBUILD_TEST_OUTPUT=$(mktemp)
    xcodebuild -version >"$XCODEBUILD_TEST_OUTPUT" 2>&1
    XCODEBUILD_TEST_EXIT_CODE=$?
    
    if grep -q "requires Xcode" "$XCODEBUILD_TEST_OUTPUT"; then
        echo "❌ Xcode is not properly installed."
        echo "The xcodebuild tool requires the full Xcode application, not just command line tools."
        rm "$XCODEBUILD_TEST_OUTPUT"
        return 1
    fi
    
    rm "$XCODEBUILD_TEST_OUTPUT"
    
    echo "✅ Xcode properly configured"
    return 0
}

# Function to build the project
build_project() {
    echo
    echo "=== Building $APP_NAME ==="
    
    # Clean previous builds
    echo "Cleaning previous builds..."
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    
    BUILD_START_TIME=$(date +%s)
    
    echo "Building project (this may take a few minutes)..."
    
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
    local build_result=$?
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
        return 1
    fi
    
    rm "$BUILD_OUTPUT"
    
    if [ $build_result -eq 0 ]; then
        echo "✅ Build successful! (Duration: ${BUILD_DURATION}s)"
        return 0
    else
        echo "❌ Build failed!"
        return 1
    fi
}

# Function to find and run the app
run_app() {
    echo
    echo "=== Locating and Running $APP_NAME ==="
    
    # Find the built app
    APP_PATH=$(find "$BUILD_DIR" -name "$APP_NAME.app" -type d | head -1)
    
    if [ -z "$APP_PATH" ]; then
        echo "❌ App bundle not found in build directory"
        return 1
    fi
    
    echo "✅ Found app at: $APP_PATH"
    
    # Kill any existing instances
    echo "Stopping any existing instances..."
    pkill -f "$APP_NAME" &> /dev/null
    
    # Wait a moment for the app to fully quit
    sleep 2
    
    # Run the app
    echo "Starting $APP_NAME..."
    open "$APP_PATH"
    
    if [ $? -eq 0 ]; then
        echo "✅ $APP_NAME is now running!"
        return 0
    else
        echo "❌ Failed to start $APP_NAME"
        return 1
    fi
}

# Main execution
main() {
    # Check Xcode installation
    if ! check_xcode; then
        echo
        echo "To build Maccy, please install Xcode from the Mac App Store:"
        echo "1. Open the Mac App Store"
        echo "2. Search for 'Xcode'"
        echo "3. Install Xcode (this may take a while)"
        echo "4. After installation, run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
        echo "5. Accept the license: sudo xcodebuild -license accept"
        echo "6. Then run this script again"
        exit 1
    fi
    
    # Check if the project file exists
    if [ ! -d "$PROJECT_FILE" ]; then
        echo "❌ Project file not found: $PROJECT_FILE"
        exit 1
    fi
    
    echo "✅ Project file found"
    
    # Build the project
    if ! build_project; then
        echo
        echo "Build failed. Please check the error messages above."
        exit 1
    fi
    
    # Run the app
    if ! run_app; then
        echo
        echo "Failed to run the application."
        exit 1
    fi
    
    echo
    echo "=== Success! ==="
    echo "$APP_NAME has been built and is now running."
    echo
    echo "Build artifacts are located in: $BUILD_DIR"
    echo "To run again later: open \"$APP_PATH\""
}

# Run main function
main