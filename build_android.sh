#!/bin/bash
# Build script for zqloader Android libraries
# Usage: ./build_android.sh [ndk_path]
# Example: ./build_android.sh /home/user/android-ndk-r25

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NDK="${1:-$ANDROID_NDK}"
MIN_API_LEVEL=21
BUILD_TYPE=Release

if [ -z "$NDK" ]; then
    echo -e "${RED}Error: Android NDK path not provided${NC}"
    echo "Usage: $0 [ndk_path]"
    echo "Or set ANDROID_NDK environment variable"
    exit 1
fi

if [ ! -d "$NDK" ]; then
    echo -e "${RED}Error: NDK path does not exist: $NDK${NC}"
    exit 1
fi

TOOLCHAIN="$NDK/build/cmake/android.toolchain.cmake"
if [ ! -f "$TOOLCHAIN" ]; then
    echo -e "${RED}Error: Android toolchain not found at: $TOOLCHAIN${NC}"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Building zqloader for Android${NC}"
echo -e "${GREEN}========================================${NC}"
echo "NDK: $NDK"
echo "Toolchain: $TOOLCHAIN"
echo "Min API Level: $MIN_API_LEVEL"
echo "Build Type: $BUILD_TYPE"
echo ""

# Define ABIs to build
declare -a ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")
declare -a ABI_NAMES=("arm64" "arm32" "x86_64" "x86")

# Build for each ABI
for i in "${!ABIS[@]}"; do
    ABI="${ABIS[$i]}"
    ABI_NAME="${ABI_NAMES[$i]}"
    BUILD_DIR="build_android_$ABI_NAME"
    
    echo -e "${YELLOW}Building for $ABI...${NC}"
    
    # Configure
    cmake -B "$BUILD_DIR" \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -DANDROID_PLATFORM="android-$MIN_API_LEVEL" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_STL=c++_static \
        -GNinja
    
    # Build
    cmake --build "$BUILD_DIR" --config "$BUILD_TYPE"
    
    echo -e "${GREEN}✓ Build complete for $ABI${NC}"
done

echo ""
echo -e "${YELLOW}Copying libraries to Flutter project...${NC}"

FLUTTER_PROJECT="flutter/zqloader_ffi"
if [ ! -d "$FLUTTER_PROJECT" ]; then
    echo -e "${RED}Error: Flutter project not found at: $FLUTTER_PROJECT${NC}"
    exit 1
fi

# Copy built libraries
for i in "${!ABIS[@]}"; do
    ABI="${ABIS[$i]}"
    ABI_NAME="${ABI_NAMES[$i]}"
    BUILD_DIR="build_android_$ABI_NAME"
    LIB_PATH="build_android_$ABI_NAME/libzqloaderlib.so"
    
    if [ ! -f "$LIB_PATH" ]; then
        echo -e "${RED}Error: Library not found: $LIB_PATH${NC}"
        exit 1
    fi
    
    # Create target directory
    TARGET_DIR="$FLUTTER_PROJECT/android/app/src/main/jniLibs/$ABI"
    mkdir -p "$TARGET_DIR"
    
    # Copy library
    cp "$LIB_PATH" "$TARGET_DIR/"
    echo -e "${GREEN}✓ Copied to $TARGET_DIR${NC}"
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Libraries are ready in:"
echo "  $FLUTTER_PROJECT/android/app/src/main/jniLibs/"
echo ""
echo "Next steps:"
echo "  cd $FLUTTER_PROJECT/example"
echo "  flutter pub get"
echo "  flutter build apk --release"
echo ""
