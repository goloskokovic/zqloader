# Flutter FFI Wrapper - Directory Structure

## Project Layout

```
zqloader/
├── zqloader_ffi.cpp                    # C FFI wrapper implementation
├── CMakeLists.txt                      # Updated for Android support
│
├── BUILD_ANDROID.md                    # Android build guide
├── FLUTTER_FFI_WRAPPER.md              # This wrapper's documentation
├── build_android.sh                    # Bash build script
├── build_android.ps1                   # PowerShell build script
│
└── flutter/
    └── zqloader_ffi/                   # Flutter package
        ├── pubspec.yaml                # Package configuration
        ├── README.md                   # Flutter wrapper documentation
        │
        ├── lib/
        │   ├── zqloader_ffi.dart       # Package exports
        │   ├── zqloader_bindings.dart  # Low-level FFI bindings
        │   └── zqloader.dart           # High-level Dart API
        │
        ├── example/
        │   ├── pubspec.yaml            # Example app config
        │   └── main.dart               # Example Flutter application
        │
        └── android/
            └── app/src/main/jniLibs/   # Native libraries (after build)
                ├── arm64-v8a/
                │   └── libzqloaderlib.so
                ├── armeabi-v7a/
                │   └── libzqloaderlib.so
                ├── x86_64/
                │   └── libzqloaderlib.so
                └── x86/
                    └── libzqloaderlib.so
```

## File Descriptions

### Root Level

| File | Purpose |
|------|---------|
| `zqloader_ffi.cpp` | C-compatible FFI wrapper for C++ library |
| `CMakeLists.txt` | Updated with Android build support |
| `BUILD_ANDROID.md` | Detailed Android build instructions |
| `FLUTTER_FFI_WRAPPER.md` | Complete wrapper documentation |
| `build_android.sh` | Automated build script (Linux/macOS) |
| `build_android.ps1` | Automated build script (Windows) |

### Flutter Package (`flutter/zqloader_ffi/`)

| Path | Purpose |
|------|---------|
| `pubspec.yaml` | Package dependencies and metadata |
| `README.md` | Flutter wrapper usage guide |
| `lib/zqloader_ffi.dart` | Package entry point and exports |
| `lib/zqloader_bindings.dart` | Low-level FFI function bindings |
| `lib/zqloader.dart` | High-level Dart OOP interface |
| `example/main.dart` | Complete Flutter example application |
| `example/pubspec.yaml` | Example app dependencies |

### Generated Libraries (After Build)

After running build scripts, Android native libraries are placed in:
```
flutter/zqloader_ffi/android/app/src/main/jniLibs/
├── arm64-v8a/libzqloaderlib.so       # 64-bit ARM
├── armeabi-v7a/libzqloaderlib.so     # 32-bit ARM
├── x86_64/libzqloaderlib.so          # 64-bit Intel
└── x86/libzqloaderlib.so             # 32-bit Intel
```

## Build Output

After building C++ code, the following artifacts are created:

```
build/                                  # CMake build (desktop/iOS)
├── CMakeFiles/
├── zqloaderlib.so/.dll/.dylib         # Compiled library

build_android_arm64/                    # Android ARM64 build
├── libzqloaderlib.so

build_android_arm32/                    # Android ARMv7 build
├── libzqloaderlib.so

build_android_x86_64/                   # Android x86_64 build
├── libzqloaderlib.so

build_android_x86/                      # Android x86 build
├── libzqloaderlib.so
```

## Setting Up the Project

### 1. Generate FFI Wrapper
```bash
# Compile zqloader_ffi.cpp
cmake -B build
cmake --build build
```

### 2. Build for Android
```bash
# Option A: Using provided scripts
./build_android.sh /path/to/ndk          # Linux/macOS
.\build_android.ps1 -NdkPath "C:\ndk"    # Windows

# Option B: Manual build (see BUILD_ANDROID.md)
cmake -B build_android_arm64 \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_PLATFORM=android-21 \
  -DANDROID_ABI=arm64-v8a
cmake --build build_android_arm64
```

### 3. Test Flutter Wrapper
```bash
cd flutter/zqloader_ffi
flutter pub get

# Run example app
cd example
flutter run
```

## Dependencies

### C++ Level
- C++17 standard library
- CMake 3.21+ (for Android support)
- Android NDK (for Android builds)
- Optional: miniaudio.h (already included in project)

### Flutter/Dart Level
- Flutter SDK 3.10+
- Dart 3.0+
- ffi: ^2.1.0
- path: ^1.8.3

## Integration Steps

### For Existing Flutter Project

1. **Copy Flutter package:**
   ```bash
   cp -r flutter/zqloader_ffi /path/to/your/app/packages/
   ```

2. **Add to pubspec.yaml:**
   ```yaml
   dependencies:
     zqloader_ffi:
       path: packages/zqloader_ffi
   ```

3. **Initialize in main.dart:**
   ```dart
   import 'package:zqloader_ffi/zqloader_bindings.dart';
   
   void main() {
     ZQLoaderBindings.init();
     runApp(MyApp());
   }
   ```

4. **Copy Android libraries:**
   ```bash
   cp -r flutter/zqloader_ffi/android/app/src/main/jniLibs/* \
         your_app/android/app/src/main/jniLibs/
   ```

5. **Use the API:**
   ```dart
   import 'package:zqloader_ffi/zqloader.dart';
   
   final loader = ZQLoader.create();
   loader.setNormalFilename('game.tap');
   loader.setTurboFilename('turbo.wav');
   loader.setAction(LoaderAction.writeWav);
   loader.setVolume(100, 100);
   loader.run();
   loader.dispose();
   ```

## Platform-Specific Notes

### Windows
- Use Visual Studio toolchain
- Library: `zqloaderlib.dll`
- Include in app distribution or system PATH

### Linux
- Use GCC/Clang toolchain
- Library: `libzqloaderlib.so`
- May need to set `LD_LIBRARY_PATH`

### macOS
- Use Clang toolchain
- Library: `libzqloaderlib.dylib`
- Framework integration recommended

### Android
- Use Android NDK toolchain
- Libraries: `libzqloaderlib.so` (multiple ABIs)
- See BUILD_ANDROID.md for detailed process
- Requires API level 21+ 
- Multiple ABI support for broader device coverage

### iOS
- Link against static library
- Configure in Xcode project
- See flutter/zqloader_ffi/README.md

## Troubleshooting

### Library Not Found
- Check that native library is in correct location
- Verify library name matches platform convention
- For Android: check `jniLibs` directory structure

### CMake Configuration Error
- Install required version (3.21+)
- Set `ANDROID_NDK` environment variable
- Verify toolchain file exists

### Dart Compilation Error
- Run `flutter pub get`
- Clear pub cache: `flutter pub cache clean`
- Ensure Dart 3.0+ is installed

### Runtime Error: "dlopen failed"
- Library not packaged with app
- Wrong architecture for device
- Missing permissions in AndroidManifest.xml

## Next Steps

1. Build the C++ wrapper: `cmake --build build`
2. Build for Android: `./build_android.sh`
3. Test with example: `flutter run` in example directory
4. Integrate into your project: Follow Integration Steps
5. Deploy: `flutter build apk --release` or `flutter build appbundle --release`

## References

- [Flutter FFI Documentation](https://dart.dev/guides/libraries/c-interop)
- [Android NDK Documentation](https://developer.android.com/ndk)
- [CMake Android Support](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-for-android)
- [zqloader Main Project](https://github.com/oxidaan/zqloader)
