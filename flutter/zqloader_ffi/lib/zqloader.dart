import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'zqloader_bindings.dart';

/// Compression type enumeration
enum CompressionType {
  /// No compression
  none(0),

  /// Run-length encoding
  rle(1),

  /// Automatic compression selection
  automatic(2);

  final int value;
  const CompressionType(this.value);
}

/// Action enumeration - what to do when loading
enum LoaderAction {
  /// Play audio
  playAudio(0),

  /// Write WAV file
  writeWav(1),

  /// Write TZX file
  writeTzx(2);

  final int value;
  const LoaderAction(this.value);
}

/// Loader location enumeration
enum LoaderLocation {
  /// Automatic location
  automatic(0),

  /// At screen
  screen(1);

  final int value;
  const LoaderLocation(this.value);
}

/// High-level Dart wrapper for ZQLoader
class ZQLoader {
  final int _handle;

  ZQLoader._(this._handle);

  /// Create a new ZQLoader instance
  factory ZQLoader.create() {
    final handle = ZQLoaderBindings.zqloader_create();
    if (handle == 0) {
      throw Exception('Failed to create ZQLoader instance');
    }
    return ZQLoader._(handle);
  }

  /// Dispose of this loader instance
  void dispose() {
    ZQLoaderBindings.zqloader_destroy(_handle);
  }

  /// Get version string
  static String getVersion() {
    final versionPtr = ZQLoaderBindings.zqloader_get_version();
    return versionPtr.cast<Utf8>().toDartString();
  }

  /// Check if file is zqloader.tap
  static bool fileIsZqLoader(String filename) {
    final filenamePtr = filename.toNativeUtf8();
    try {
      return ZQLoaderBindings.zqloader_file_is_zqloader(filenamePtr.cast()) != 0;
    } finally {
      malloc.free(filenamePtr);
    }
  }

  // ============================================================================
  // Configuration - Filenames
  // ============================================================================

  /// Set normal filename for loading
  void setNormalFilename(String filename, {String zxFilename = ''}) {
    final filePtr = filename.toNativeUtf8();
    final zxPtr = zxFilename.toNativeUtf8();
    try {
      final result = ZQLoaderBindings.zqloader_set_normal_filename(
          _handle, filePtr.cast(), zxPtr.cast());
      if (result == 0) throw Exception('setNormalFilename failed');
    } finally {
      malloc.free(filePtr);
      malloc.free(zxPtr);
    }
  }

  /// Set turbo filename for loading
  void setTurboFilename(String filename, {String zxFilename = ''}) {
    final filePtr = filename.toNativeUtf8();
    final zxPtr = zxFilename.toNativeUtf8();
    try {
      final result = ZQLoaderBindings.zqloader_set_turbo_filename(
          _handle, filePtr.cast(), zxPtr.cast());
      if (result == 0) throw Exception('setTurboFilename failed');
    } finally {
      malloc.free(filePtr);
      malloc.free(zxPtr);
    }
  }

  /// Set output filename
  void setOutputFilename(String filename, {bool allowOverwrite = false}) {
    final filePtr = filename.toNativeUtf8();
    try {
      final result = ZQLoaderBindings.zqloader_set_output_filename(
          _handle, filePtr.cast(), allowOverwrite ? 1 : 0);
      if (result == 0) throw Exception('setOutputFilename failed');
    } finally {
      malloc.free(filePtr);
    }
  }

  /// Set exe filename
  void setExeFilename(String filename) {
    final filePtr = filename.toNativeUtf8();
    try {
      final result = ZQLoaderBindings.zqloader_set_exe_filename(_handle, filePtr.cast());
      if (result == 0) throw Exception('setExeFilename failed');
    } finally {
      malloc.free(filePtr);
    }
  }

  // ============================================================================
  // Configuration - Audio
  // ============================================================================

  /// Set volume for left and right channels (-100 to 100)
  void setVolume(int volumeLeft, int volumeRight) {
    final result =
        ZQLoaderBindings.zqloader_set_volume(_handle, volumeLeft, volumeRight);
    if (result == 0) throw Exception('setVolume failed');
  }

  /// Set sample rate (0 = device default)
  void setSampleRate(int sampleRate) {
    final result = ZQLoaderBindings.zqloader_set_sample_rate(_handle, sampleRate);
    if (result == 0) throw Exception('setSampleRate failed');
  }

  /// Get device sample rate
  int getDeviceSampleRate() {
    return ZQLoaderBindings.zqloader_get_device_sample_rate(_handle);
  }

  // ============================================================================
  // Configuration - Timing
  // ============================================================================

  /// Set bit loop max
  void setBitLoopMax(int value) {
    final result = ZQLoaderBindings.zqloader_set_bit_loop_max(_handle, value);
    if (result == 0) throw Exception('setBitLoopMax failed');
  }

  /// Set zero max
  void setZeroMax(int value) {
    final result = ZQLoaderBindings.zqloader_set_zero_max(_handle, value);
    if (result == 0) throw Exception('setZeroMax failed');
  }

  /// Set durations
  void setDurations(int zeroDuration, int oneDuration, int endOfByteDelay) {
    final result = ZQLoaderBindings.zqloader_set_durations(
        _handle, zeroDuration, oneDuration, endOfByteDelay);
    if (result == 0) throw Exception('setDurations failed');
  }

  /// Set spectrum clock frequency in Hz
  void setSpectrumClock(int spectrumClock) {
    final result = ZQLoaderBindings.zqloader_set_spectrum_clock(_handle, spectrumClock);
    if (result == 0) throw Exception('setSpectrumClock failed');
  }

  /// Set initial wait in milliseconds
  void setInitialWait(Duration duration) {
    final result =
        ZQLoaderBindings.zqloader_set_initial_wait(_handle, duration.inMilliseconds);
    if (result == 0) throw Exception('setInitialWait failed');
  }

  /// Set use standard speed for ROM
  void setUseStandardSpeedForRom(bool useStandard) {
    final result = ZQLoaderBindings.zqloader_set_use_standard_speed_for_rom(
        _handle, useStandard ? 1 : 0);
    if (result == 0) throw Exception('setUseStandardSpeedForRom failed');
  }

  // ============================================================================
  // Configuration - IO & Compression
  // ============================================================================

  /// Set IO values
  void setIoValues(int ioInitValue, int ioXorValue) {
    final result = ZQLoaderBindings.zqloader_set_io_values(_handle, ioInitValue, ioXorValue);
    if (result == 0) throw Exception('setIoValues failed');
  }

  /// Set compression type
  void setCompressionType(CompressionType compressionType) {
    final result =
        ZQLoaderBindings.zqloader_set_compression_type(_handle, compressionType.value);
    if (result == 0) throw Exception('setCompressionType failed');
  }

  /// Set decompression speed in KB/sec
  void setDecompressionSpeed(int kbPerSec) {
    final result = ZQLoaderBindings.zqloader_set_decompression_speed(_handle, kbPerSec);
    if (result == 0) throw Exception('setDecompressionSpeed failed');
  }

  // ============================================================================
  // Configuration - Behavior
  // ============================================================================

  /// Set action
  void setAction(LoaderAction action) {
    final result = ZQLoaderBindings.zqloader_set_action(_handle, action.value);
    if (result == 0) throw Exception('setAction failed');
  }

  /// Set loader copy target address
  void setLoaderCopyTarget(int address) {
    final result = ZQLoaderBindings.zqloader_set_loader_copy_target(_handle, address);
    if (result == 0) throw Exception('setLoaderCopyTarget failed');
  }

  /// Set fun attributes
  void setFunAttribs(bool value) {
    final result = ZQLoaderBindings.zqloader_set_fun_attribs(_handle, value ? 1 : 0);
    if (result == 0) throw Exception('setFunAttribs failed');
  }

  /// Set when done behavior
  void setWhenDoneDo(int usrAddress, {bool returnToBasic = false}) {
    final result = ZQLoaderBindings.zqloader_set_when_done_do(
        _handle, usrAddress, returnToBasic ? 1 : 0);
    if (result == 0) throw Exception('setWhenDoneDo failed');
  }

  // ============================================================================
  // Control
  // ============================================================================

  /// Reset loader
  void reset() {
    final result = ZQLoaderBindings.zqloader_reset(_handle);
    if (result == 0) throw Exception('reset failed');
  }

  /// Run synchronously
  void run() {
    final result = ZQLoaderBindings.zqloader_run(_handle);
    if (result == 0) throw Exception('run failed');
  }

  /// Start asynchronously
  void start() {
    final result = ZQLoaderBindings.zqloader_start(_handle);
    if (result == 0) throw Exception('start failed');
  }

  /// Stop loading
  void stop() {
    final result = ZQLoaderBindings.zqloader_stop(_handle);
    if (result == 0) throw Exception('stop failed');
  }

  /// Wait until done
  void waitUntilDone() {
    final result = ZQLoaderBindings.zqloader_wait_until_done(_handle);
    if (result == 0) throw Exception('waitUntilDone failed');
  }

  /// Check if busy
  bool isBusy() {
    return ZQLoaderBindings.zqloader_is_busy(_handle) != 0;
  }

  /// Set preload
  void setPreload() {
    final result = ZQLoaderBindings.zqloader_set_preload(_handle);
    if (result == 0) throw Exception('setPreload failed');
  }

  /// Check if preloaded
  bool isPreloaded() {
    return ZQLoaderBindings.zqloader_is_preloaded(_handle) != 0;
  }

  /// Play leader tone
  void playLeaderTone() {
    final result = ZQLoaderBindings.zqloader_play_leader_tone(_handle);
    if (result == 0) throw Exception('playLeaderTone failed');
  }

  // ============================================================================
  // Status
  // ============================================================================

  /// Get time needed
  Duration getTimeNeeded() {
    final ms = ZQLoaderBindings.zqloader_get_time_needed(_handle);
    return Duration(milliseconds: ms);
  }

  /// Get current time
  Duration getCurrentTime() {
    final ms = ZQLoaderBindings.zqloader_get_current_time(_handle);
    return Duration(milliseconds: ms);
  }

  /// Get estimated duration
  Duration getEstimatedDuration() {
    final ms = ZQLoaderBindings.zqloader_get_estimated_duration(_handle);
    return Duration(milliseconds: ms);
  }

  /// Get duration in TStates
  int getDurationInTStates() {
    return ZQLoaderBindings.zqloader_get_duration_in_tstates(_handle);
  }
}
