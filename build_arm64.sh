#!/bin/bash

# Exit on any error
set -e

echo "======================================"
echo " Starting Optimized arm64 Build"
echo " Project: Flare"
echo "======================================"

# Determine the directory of the script to run it from anywhere
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# Clean the build directory
echo "[1/3] Cleaning previous builds..."
xcodebuild clean \
    -project Flare.xcodeproj \
    -scheme Flare \
    -configuration Release \
    -quiet

# Build the project
echo "[2/3] Building for arm64 (Release)..."
xcodebuild build \
    -project Flare.xcodeproj \
    -scheme Flare \
    -configuration Release \
    -arch arm64 \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_DIR="$DIR/build" \
    -quiet

echo "[3/3] Build completed successfully!"
echo "You can find your optimized app at:"
echo "  $DIR/build/Release/Flare.app"
