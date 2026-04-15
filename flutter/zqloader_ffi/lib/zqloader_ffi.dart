/// ZQLoader FFI Flutter Package
///
/// High-level Dart/Flutter FFI wrapper for the zqloader C++ library.
/// Provides access to Spectrum emulator loader functionality from Dart code.
///
/// Quick Start:
/// ```dart
/// import 'package:zqloader_ffi/zqloader.dart';
///
/// // Initialize the FFI
/// import 'package:zqloader_ffi/zqloader_bindings.dart';
/// ZQLoaderBindings.init();
///
/// // Create a loader instance
/// final loader = ZQLoader.create();
///
/// // Configure it
/// loader.setNormalFilename('game.tap');
/// loader.setTurboFilename('turbo.wav');
/// loader.setVolume(100, 100);
/// loader.setAction(LoaderAction.writeWav);
///
/// // Run it
/// loader.run();
///
/// // Clean up
/// loader.dispose();
/// ```
///
/// For more advanced usage, see the example app.

export 'zqloader.dart';
export 'zqloader_bindings.dart';
