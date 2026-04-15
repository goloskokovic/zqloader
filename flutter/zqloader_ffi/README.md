# ZQLoader FFI - Flutter wrapper for zqloader

A comprehensive Flutter FFI (Foreign Function Interface) wrapper for the zqloader C++ library. This enables Dart/Flutter applications to access Spectrum emulator loader functionality directly.

## Features

- **Complete API Coverage**: All zqloader functionality exposed through Dart
- **Type-Safe**: Enums and typed methods instead of raw C calls
- **Resource Management**: Automatic cleanup with dispose pattern
- **Cross-Platform**: Works on Windows, Linux, macOS, Android, and iOS
- **Error Handling**: Proper exceptions for failed operations

## Installation

### 1. Add to pubspec.yaml

```yaml
dependencies:
  zqloader_ffi:
    path: ../path/to/zqloader_ffi
```

### 2. Initialize FFI in your main()

```dart
import 'package:zqloader_ffi/zqloader_bindings.dart';

void main() {
  ZQLoaderBindings.init();
  runApp(MyApp());
}
```

### 3. Platform-specific Setup

#### Windows

- Ensure `zqloaderlib.dll` is in your application directory or system PATH

#### Linux

- Ensure `libzqloaderlib.so` is installed or available at runtime

#### macOS

- Ensure `libzqloaderlib.dylib` is installed or available at runtime

#### Android

Add to your Android app's build.gradle:

```gradle
android {
    packagingOptions {
        pickFirst 'lib/arm64-v8a/libzqloaderlib.so'
        pickFirst 'lib/armeabi-v7a/libzqloaderlib.so'
        pickFirst 'lib/x86/libzqloaderlib.so'
        pickFirst 'lib/x86_64/libzqloaderlib.so'
    }
}
```

Place compiled `.so` files in:
```
android/app/src/main/jniLibs/arm64-v8a/
android/app/src/main/jniLibs/armeabi-v7a/
android/app/src/main/jniLibs/x86/
android/app/src/main/jniLibs/x86_64/
```

#### iOS

Add to your iOS Podfile or configure via Xcode to link against libzqloaderlib.

## Usage

### Basic Example

```dart
import 'package:zqloader_ffi/zqloader.dart';

// Create loader instance
final loader = ZQLoader.create();

try {
  // Configure files
  loader.setNormalFilename('game.tap');
  loader.setVolume(100, 100);
  
  // Set action
  loader.setAction(LoaderAction.playAudio);
  
  // Run synchronously
  loader.run();
  
} finally {
  // Always dispose
  loader.dispose();
}
```

### Async Loading

```dart
final loader = ZQLoader.create();

try {
  loader.setNormalFilename('game.tap');
  loader.setAction(LoaderAction.playAudio);
  
  // Start async
  loader.start();
  
  // Monitor progress
  while (loader.isBusy()) {
    final current = loader.getCurrentTime();
    final estimated = loader.getEstimatedDuration();
    print('Playing: ${current.inSeconds}s / ${estimated.inSeconds}s');
    await Future.delayed(Duration(milliseconds: 100));
  }
  
} finally {
  loader.dispose();
}
```

### Write to File

```dart
final loader = ZQLoader.create();

try {
  loader.setNormalFilename('game.tap');
  loader.setOutputFilename('output.wav', allowOverwrite: true);
  loader.setAction(LoaderAction.writeWav);
  
  loader.run();
  
} finally {
  loader.dispose();
}
```

### Check Version

```dart
final version = ZQLoader.getVersion();
print('ZQLoader version: $version');
```

### Check if File is ZQLoader

```dart
if (ZQLoader.fileIsZqLoader('suspected_loader.tap')) {
  print('This is a zqloader file');
}
```

## API Reference

### Enumerations

#### CompressionType
- `none` - No compression
- `rle` - Run-length encoding
- `automatic` - Automatic selection

#### LoaderAction
- `playAudio` - Play audio output
- `writeWav` - Write WAV file
- `writeTzx` - Write TZX file

#### LoaderLocation
- `automatic` - Automatic location selection
- `screen` - Load at screen location

### Main Methods

#### Configuration

- `setNormalFilename(filename, {zxFilename})` - Set normal speed loader file
- `setTurboFilename(filename, {zxFilename})` - Set turbo loader file
- `setOutputFilename(filename, {allowOverwrite})` - Set output file
- `setVolume(left, right)` - Set volume (-100 to 100)
- `setSampleRate(rate)` - Set audio sample rate
- `setCompressionType(type)` - Set compression type
- `setDecompressionSpeed(kbPerSec)` - Set decompression speed
- `setDurations(zero, one, endOfByte)` - Set duration parameters
- `setSpectrumClock(hz)` - Set CPU clock frequency
- `setInitialWait(duration)` - Set wait after loading
- `setAction(action)` - Set what to do (play, write WAV, write TZX)
- `setLoaderCopyTarget(address)` - Set loader address
- `setFunAttribs(value)` - Set fun attributes flag
- `setWhenDoneDo(usrAddress, {returnToBasic})` - Set post-load behavior

#### Control

- `run()` - Run synchronously (blocks)
- `start()` - Start asynchronously (non-blocking)
- `stop()` - Stop async operation
- `waitUntilDone()` - Wait for completion
- `reset()` - Reset/clear all settings
- `playLeaderTone()` - Play infinite leader tone for tuning

#### Status

- `isBusy()` - Check if currently loading/playing
- `isPreloaded()` - Check if preload is set
- `getCurrentTime()` - Get current playback time (Duration)
- `getTimeNeeded()` - Get total time needed (Duration)
- `getEstimatedDuration()` - Get estimated duration (Duration)
- `getDeviceSampleRate()` - Get device sample rate
- `getDurationInTStates()` - Get total duration in Z80 TStates

#### Utility

- `setPreload()` - Add zqloader.tap preload
- `setExeFilename(filename)` - Set exe path for finding zqloader.tap

## Building for Android

### From C++ Code

Compile the shared library using Android NDK:

```bash
cd zqloader
cmake -B build_android \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_PLATFORM=android-21 \
  -DANDROID_ABI=arm64-v8a

cmake --build build_android
```

Copy `libzqloaderlib.so` to:
```
../flutter/zqloader_ffi/android/jniLibs/arm64-v8a/
```

### Flutter Integration

The Flutter app will automatically use the native library at runtime.

## Example App

See `example/main.dart` for a complete Flutter application demonstrating all features.

## License

MIT License - See LICENSE.txt in the main zqloader project

## Support

For issues related to zqloader itself, see the main project.
For FFI wrapper issues, check this package's documentation.
