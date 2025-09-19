# Maccy Build Scripts

This directory contains shell scripts to build and run the Maccy application from the command line.

## Prerequisites

Before using these scripts, you have two options:

### Option 1: Install Xcode (Full Development)
1. Open the Mac App Store
2. Search for "Xcode"
3. Install Xcode (this may take a while)
4. After installation, run:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -license accept
   ```

### Option 2: Work with Existing Build (No Xcode Required)
You can work with the existing built application without installing Xcode. This approach allows you to:
- Update resource files (strings, settings, etc.)
- Run the application
- Test your changes

## Scripts

### 1. build.sh
Builds the Maccy application bundle using xcodebuild (requires Xcode).

Usage:
```bash
./build.sh
```

### 2. build_and_run.sh
Builds the Maccy application bundle and then runs it (requires Xcode).

Usage:
```bash
./build_and_run.sh
```

### 3. run.sh
Runs the existing built Maccy application.

Usage:
```bash
./run.sh
```

### 4. simple_update.sh
Updates resource files in the existing Maccy app without requiring Xcode. This is useful for:
- Updating string resources
- Modifying settings UI
- Testing resource changes

Usage:
```bash
./simple_update.sh
```

### 5. update_resources.sh
Creates a modified copy of the app with updated resources (experimental).

Usage:
```bash
./update_resources.sh
```

## Build Output

When using Xcode build scripts, artifacts are placed in the `build/` directory. The built application bundle will be located at:
`build/Build/Products/Debug/Maccy.app`

## Troubleshooting

If you encounter build errors with Xcode:

1. Make sure Xcode is properly installed and configured
2. Check that command line tools are set up correctly:
   ```bash
   sudo xcode-select --install
   ```
3. Clean the build directory and try again:
   ```bash
   rm -rf build/
   ./build_and_run.sh
   ```

If the app fails to launch after resource updates:
1. Check System Preferences > Security & Privacy to allow the app
2. Try restarting the app
3. As a last resort, restore from the backup file created by simple_update.sh

## Features Added

The version of Maccy in this repository includes several new features:

1. **Disable Automatic Popup**: Option to prevent the popup from appearing automatically when copying
2. **Disable Notifications**: Option to disable notifications when copying items
3. **Configurable Content Length**: Set maximum display length for clipboard items in the history
4. **Fixed String Truncation**: Corrected the string truncation logic to properly limit content length

These features can be configured in the Maccy preferences after running the application.

## Working Without Xcode

You can edit, test, and run Maccy without installing Xcode by:

1. Modifying source files in the `Maccy/` directory
2. Using `simple_update.sh` to copy resource changes to the existing app
3. Running the app with `run.sh` or `simple_update.sh`

This approach works well for:
- UI changes (text, layouts, settings)
- Resource modifications (strings, images)
- Behavior changes that don't require recompilation

For code changes that require compilation, you'll need to install Xcode.