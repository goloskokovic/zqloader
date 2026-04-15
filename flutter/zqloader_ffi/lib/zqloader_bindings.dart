import 'dart:ffi' as ffi;
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

/// Low-level FFI bindings for zqloader C library
class ZQLoaderBindings {
  static late ffi.DynamicLibrary _dylib;

  /// Initialize FFI library
  static void init() {
    if (Platform.isWindows) {
      _dylib = ffi.DynamicLibrary.open('zqloaderlib.dll');
    } else if (Platform.isLinux) {
      _dylib = ffi.DynamicLibrary.open('libzqloaderlib.so');
    } else if (Platform.isMacOS) {
      _dylib = ffi.DynamicLibrary.open('libzqloaderlib.dylib');
    } else if (Platform.isAndroid) {
      _dylib = ffi.DynamicLibrary.open('libzqloaderlib.so');
    } else if (Platform.isIOS) {
      _dylib = ffi.DynamicLibrary.process();
    } else {
      throw UnsupportedError('Platform ${Platform.operatingSystem} is not supported');
    }
  }

  // ============================================================================
  // Instance Management
  // ============================================================================

  /// Create a new ZQLoader instance
  /// Returns: handle to the loader instance
  static late final zqloader_create = _dylib.lookupFunction<
      ffi.Int64 Function(),
      int Function()>('zqloader_create');

  /// Destroy a ZQLoader instance
  static late final zqloader_destroy = _dylib.lookupFunction<
      ffi.Void Function(ffi.Int64),
      void Function(int)>('zqloader_destroy');

  // ============================================================================
  // Version & Info
  // ============================================================================

  /// Get version string
  static late final zqloader_get_version = _dylib.lookupFunction<
      ffi.Pointer<ffi.Char> Function(),
      ffi.Pointer<ffi.Char> Function()>('zqloader_get_version');

  /// Check if file is zqloader.tap
  static late final zqloader_file_is_zqloader = _dylib.lookupFunction<
      ffi.Int Function(ffi.Pointer<ffi.Char>),
      int Function(ffi.Pointer<ffi.Char>)>('zqloader_file_is_zqloader');

  // ============================================================================
  // Configuration - Filenames
  // ============================================================================

  /// Set normal filename for loading
  static late final zqloader_set_normal_filename = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>),
      int Function(int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>('zqloader_set_normal_filename');

  /// Set turbo filename for loading
  static late final zqloader_set_turbo_filename = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>),
      int Function(int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>('zqloader_set_turbo_filename');

  /// Set output filename
  static late final zqloader_set_output_filename = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Pointer<ffi.Char>, ffi.Int),
      int Function(int, ffi.Pointer<ffi.Char>, int)>('zqloader_set_output_filename');

  /// Set exe filename
  static late final zqloader_set_exe_filename = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Pointer<ffi.Char>),
      int Function(int, ffi.Pointer<ffi.Char>)>('zqloader_set_exe_filename');

  // ============================================================================
  // Configuration - Audio
  // ============================================================================

  /// Set volume for left and right channels (-100 to 100)
  static late final zqloader_set_volume = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Int, ffi.Int),
      int Function(int, int, int)>('zqloader_set_volume');

  /// Set sample rate (0 = device default)
  static late final zqloader_set_sample_rate = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Uint32),
      int Function(int, int)>('zqloader_set_sample_rate');

  /// Get device sample rate
  static late final zqloader_get_device_sample_rate = _dylib.lookupFunction<
      ffi.Uint32 Function(ffi.Int64),
      int Function(int)>('zqloader_get_device_sample_rate');

  // ============================================================================
  // Configuration - Timing
  // ============================================================================

  /// Set bit loop max
  static late final zqloader_set_bit_loop_max = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Int),
      int Function(int, int)>('zqloader_set_bit_loop_max');

  /// Set zero max
  static late final zqloader_set_zero_max = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Int),
      int Function(int, int)>('zqloader_set_zero_max');

  /// Set durations
  static late final zqloader_set_durations = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Int, ffi.Int, ffi.Int),
      int Function(int, int, int, int)>('zqloader_set_durations');

  /// Set spectrum clock frequency in Hz
  static late final zqloader_set_spectrum_clock = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Int),
      int Function(int, int)>('zqloader_set_spectrum_clock');

  /// Set initial wait in milliseconds
  static late final zqloader_set_initial_wait = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Uint32),
      int Function(int, int)>('zqloader_set_initial_wait');

  /// Set use standard speed for ROM
  static late final zqloader_set_use_standard_speed_for_rom = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Int),
      int Function(int, int)>('zqloader_set_use_standard_speed_for_rom');

  // ============================================================================
  // Configuration - IO & Compression
  // ============================================================================

  /// Set IO values
  static late final zqloader_set_io_values = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Int, ffi.Int),
      int Function(int, int, int)>('zqloader_set_io_values');

  /// Set compression type
  static late final zqloader_set_compression_type = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Int),
      int Function(int, int)>('zqloader_set_compression_type');

  /// Set decompression speed
  static late final zqloader_set_decompression_speed = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Int),
      int Function(int, int)>('zqloader_set_decompression_speed');

  // ============================================================================
  // Configuration - Behavior
  // ============================================================================

  /// Set action
  static late final zqloader_set_action = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Int),
      int Function(int, int)>('zqloader_set_action');

  /// Set loader copy target
  static late final zqloader_set_loader_copy_target = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Uint16),
      int Function(int, int)>('zqloader_set_loader_copy_target');

  /// Set fun attribs
  static late final zqloader_set_fun_attribs = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Int),
      int Function(int, int)>('zqloader_set_fun_attribs');

  /// Set when done behavior
  static late final zqloader_set_when_done_do = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64, ffi.Uint16, ffi.Int),
      int Function(int, int, int)>('zqloader_set_when_done_do');

  // ============================================================================
  // Control
  // ============================================================================

  /// Reset loader
  static late final zqloader_reset = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64),
      int Function(int)>('zqloader_reset');

  /// Run synchronously
  static late final zqloader_run = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64),
      int Function(int)>('zqloader_run');

  /// Start asynchronously
  static late final zqloader_start = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64),
      int Function(int)>('zqloader_start');

  /// Stop loading
  static late final zqloader_stop = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64),
      int Function(int)>('zqloader_stop');

  /// Wait until done
  static late final zqloader_wait_until_done = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64),
      int Function(int)>('zqloader_wait_until_done');

  /// Check if busy
  static late final zqloader_is_busy = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64),
      int Function(int)>('zqloader_is_busy');

  /// Set preload
  static late final zqloader_set_preload = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64),
      int Function(int)>('zqloader_set_preload');

  /// Is preloaded
  static late final zqloader_is_preloaded = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64),
      int Function(int)>('zqloader_is_preloaded');

  /// Play leader tone
  static late final zqloader_play_leader_tone = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64),
      int Function(int)>('zqloader_play_leader_tone');

  // ============================================================================
  // Status
  // ============================================================================

  /// Get time needed in milliseconds
  static late final zqloader_get_time_needed = _dylib.lookupFunction<
      ffi.Uint64 Function(ffi.Int64),
      int Function(int)>('zqloader_get_time_needed');

  /// Get current time in milliseconds
  static late final zqloader_get_current_time = _dylib.lookupFunction<
      ffi.Uint64 Function(ffi.Int64),
      int Function(int)>('zqloader_get_current_time');

  /// Get estimated duration in milliseconds
  static late final zqloader_get_estimated_duration = _dylib.lookupFunction<
      ffi.Uint64 Function(ffi.Int64),
      int Function(int)>('zqloader_get_estimated_duration');

  /// Get duration in TStates
  static late final zqloader_get_duration_in_tstates = _dylib.lookupFunction<
      ffi.Int Function(ffi.Int64),
      int Function(int)>('zqloader_get_duration_in_tstates');
}
