# Building ZQLoader for Android

This guide explains how to build the zqloader library for Android and integrate it with Flutter.

## Prerequisites

1. **Android NDK** - Download from [Android Developer website](https://developer.android.com/ndk/downloads)
   - Recommended: NDK r25 or later
   - Set `ANDROID_NDK` environment variable

2. **CMake** - Version 3.21 or later

3. **Ninja** build system (optional but recommended)

## Step 1: Prepare CMakeLists.txt

The main CMakeLists.txt has already been configured for Android support. Key changes:
- Minimum CMake version increased to 3.21
- Android detection and ABI configuration
- Conditional compilation for Android platform
- Specific linking for Android (log, pthread)

## Step 2: Build for Android

### Build for ARM64 (recommended)

```bash
cd /path/to/zqloader

cmake -B build_android_arm64 \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DANDROID_PLATFORM=android-21 \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_STL=c++_static \
  -DCMAKE_MAKE_PROGRAM=ninja

cmake --build build_android_arm64 --config Release
```

### Build for ARMv7

```bash
cmake -B build_android_arm32 \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DANDROID_PLATFORM=android-21 \
  -DANDROID_ABI=armeabi-v7a \
  -DANDROID_STL=c++_static \
  -DCMAKE_MAKE_PROGRAM=ninja

cmake --build build_android_arm32 --config Release
```

### Build for x86_64

```bash
cmake -B build_android_x86_64 \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DANDROID_PLATFORM=android-21 \
  -DANDROID_ABI=x86_64 \
  -DANDROID_STL=c++_static \
  -DCMAKE_MAKE_PROGRAM=ninja

cmake --build build_android_x86_64 --config Release
```

### Build for x86

```bash
cmake -B build_android_x86 \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DANDROID_PLATFORM=android-21 \
  -DANDROID_ABI=x86 \
  -DANDROID_STL=c++_static \
  -DCMAKE_MAKE_PROGRAM=ninja

cmake --build build_android_x86 --config Release
```

## Step 3: Copy Libraries to Flutter Project

After building, copy the generated `.so` files to the Flutter project:

```bash
# Copy ARM64
cp build_android_arm64/libzqloaderlib.so \
   flutter/zqloader_ffi/android/app/src/main/jniLibs/arm64-v8a/

# Copy ARMv7
cp build_android_arm32/libzqloaderlib.so \
   flutter/zqloader_ffi/android/app/src/main/jniLibs/armeabi-v7a/

# Copy x86_64
cp build_android_x86_64/libzqloaderlib.so \
   flutter/zqloader_ffi/android/app/src/main/jniLibs/x86_64/

# Copy x86
cp build_android_x86/libzqloaderlib.so \
   flutter/zqloader_ffi/android/app/src/main/jniLibs/x86/
```

## Step 4: Configure Flutter/Gradle

Update `android/build.gradle`:

```gradle
buildscript {
    ext.kotlin_version = '1.8.0'

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

Update `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    ndkVersion "25.2.9519653"

    defaultConfig {
        applicationId "com.example.zqloader"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"

        ndk {
            abiFilters 'arm64-v8a', 'armeabi-v7a', 'x86_64', 'x86'
        }
    }

    packagingOptions {
        pickFirst 'lib/arm64-v8a/libc++_shared.so'
        pickFirst 'lib/armeabi-v7a/libc++_shared.so'
        pickFirst 'lib/x86_64/libc++_shared.so'
        pickFirst 'lib/x86/libc++_shared.so'
    }
}
```

## Step 5: Build Flutter App

```bash
cd flutter/zqloader_ffi/example
flutter pub get
flutter build apk --release
# or
flutter build appbundle --release
```

## Troubleshooting

### CMake Configuration Error

```
error: Android NDK not found in CMAKE_ANDROID_NDK
```

**Solution**: Set `ANDROID_NDK` environment variable:
```bash
export ANDROID_NDK=/path/to/ndk/android-ndk-r25
```

### Build Errors with C++ Standard

```
error: use of undeclared identifier 'std::filesystem'
```

**Solution**: The CMakeLists.txt already sets C++17, but ensure `-DANDROID_STL=c++_static` is used.

### Library Not Found at Runtime

```
java.lang.UnsatisfiedLinkError: dlopen failed: library "libzqloaderlib.so" not found
```

**Solution**: 
1. Verify files are in correct `jniLibs` directory
2. Check `build.gradle` ndk.abiFilters matches compiled ABIs
3. Ensure library name matches: `libzqloaderlib.so`

### miniaudio Issues on Android

The miniaudio library requires:
- API level 21 (Android 5.0) or higher
- `android.permission.RECORD_AUDIO` if recording
- `android.permission.MODIFY_AUDIO_SETTINGS` for volume control

Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

## Build Script

Create a convenient build script `build_android.sh`:

```bash
#!/bin/bash
set -e

NDK=${ANDROID_NDK:-"/path/to/ndk"}
ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")
ABI_NAMES=("arm64" "arm32" "x86_64" "x86")

for i in "${!ABIS[@]}"; do
    ABI="${ABIS[$i]}"
    ABI_NAME="${ABI_NAMES[$i]}"
    
    echo "Building for $ABI..."
    
    cmake -B "build_android_$ABI_NAME" \
        -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
        -DCMAKE_BUILD_TYPE=Release \
        -DANDROID_PLATFORM=android-21 \
        -DANDROID_ABI="$ABI" \
        -DANDROID_STL=c++_static \
        -DCMAKE_MAKE_PROGRAM=ninja
    
    cmake --build "build_android_$ABI_NAME" --config Release
    
    echo "Copying libzqloaderlib.so to Flutter project..."
    mkdir -p "flutter/zqloader_ffi/android/app/src/main/jniLibs/$ABI"
    cp "build_android_$ABI_NAME/libzqloaderlib.so" \
       "flutter/zqloader_ffi/android/app/src/main/jniLibs/$ABI/"
done

echo "All builds complete!"
```

Make executable and run:
```bash
chmod +x build_android.sh
./build_android.sh
```

## Next Steps

After successfully building for Android:

1. **Test on Device**: 
   ```bash
   flutter run
   ```

2. **Release Build**:
   ```bash
   flutter build appbundle --release
   ```

3. **Deploy to Play Store**: Use Flutter app release guide

For more information on Flutter and native libraries, see:
- [Flutter Building native plugins](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#using-native-code)
- [Android NDK Documentation](https://developer.android.com/ndk)
