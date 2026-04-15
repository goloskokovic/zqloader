import 'package:flutter/material.dart';
import 'package:zqloader_ffi/zqloader.dart';
import 'package:zqloader_ffi/zqloader_bindings.dart';
import 'dart:io';

void main() {
  // Initialize FFI bindings
  try {
    ZQLoaderBindings.init();
  } catch (e) {
    print('Warning: FFI initialization failed: $e');
  }
  runApp(const ZQLoaderApp());
}

class ZQLoaderApp extends StatelessWidget {
  const ZQLoaderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZQLoader FFI Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ZQLoaderScreen(),
    );
  }
}

class ZQLoaderScreen extends StatefulWidget {
  const ZQLoaderScreen({Key? key}) : super(key: key);

  @override
  State<ZQLoaderScreen> createState() => _ZQLoaderScreenState();
}

class _ZQLoaderScreenState extends State<ZQLoaderScreen> {
  ZQLoader? _loader;
  String _status = 'Ready';
  String _version = 'Loading...';
  bool _isBusy = false;
  Duration _currentTime = Duration.zero;
  Duration _estimatedDuration = Duration.zero;

  final _normalFilenameController = TextEditingController();
  final _turboFilenameController = TextEditingController();
  final _volumeController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _initLoader();
  }

  void _initLoader() {
    try {
      // Create new loader instance
      _loader = ZQLoader.create();
      _updateStatus('Loader created successfully');

      // Get and display version
      final version = ZQLoader.getVersion();
      setState(() {
        _version = version;
      });
    } catch (e) {
      _updateStatus('Error: $e');
    }
  }

  void _updateStatus(String message) {
    setState(() {
      _status = message;
    });
  }

  void _setNormalFile() {
    try {
      final filename = _normalFilenameController.text;
      if (filename.isEmpty) {
        _updateStatus('Please enter a filename');
        return;
      }

      if (!File(filename).existsSync()) {
        _updateStatus('File not found: $filename');
        return;
      }

      _loader?.setNormalFilename(filename);
      _updateStatus('Normal file set: $filename');
    } catch (e) {
      _updateStatus('Error: $e');
    }
  }

  void _setTurboFile() {
    try {
      final filename = _turboFilenameController.text;
      if (filename.isEmpty) {
        _updateStatus('Please enter a filename');
        return;
      }

      if (!File(filename).existsSync()) {
        _updateStatus('File not found: $filename');
        return;
      }

      _loader?.setTurboFilename(filename);
      _updateStatus('Turbo file set: $filename');
    } catch (e) {
      _updateStatus('Error: $e');
    }
  }

  void _setVolume() {
    try {
      final volume = int.tryParse(_volumeController.text) ?? 100;
      if (volume < -100 || volume > 100) {
        _updateStatus('Volume must be between -100 and 100');
        return;
      }

      _loader?.setVolume(volume, volume);
      _updateStatus('Volume set to $volume');
    } catch (e) {
      _updateStatus('Error: $e');
    }
  }

  void _playAudio() async {
    try {
      _loader?.setAction(LoaderAction.playAudio);
      _updateStatus('Playing audio...');
      setState(() {
        _isBusy = true;
      });

      _loader?.start();

      // Update status periodically
      while (_loader?.isBusy() ?? false) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _currentTime = _loader?.getCurrentTime() ?? Duration.zero;
          _estimatedDuration = _loader?.getEstimatedDuration() ?? Duration.zero;
        });
      }

      setState(() {
        _isBusy = false;
      });
      _updateStatus('Playback completed');
    } catch (e) {
      setState(() {
        _isBusy = false;
      });
      _updateStatus('Error: $e');
    }
  }

  void _playLeaderTone() {
    try {
      _updateStatus('Playing leader tone...');
      _loader?.playLeaderTone();
    } catch (e) {
      _updateStatus('Error: $e');
    }
  }

  void _stop() {
    try {
      _loader?.stop();
      setState(() {
        _isBusy = false;
      });
      _updateStatus('Stopped');
    } catch (e) {
      _updateStatus('Error: $e');
    }
  }

  void _reset() {
    try {
      _loader?.reset();
      _updateStatus('Loader reset');
    } catch (e) {
      _updateStatus('Error: $e');
    }
  }

  @override
  void dispose() {
    _loader?.dispose();
    _normalFilenameController.dispose();
    _turboFilenameController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZQLoader FFI Example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Version info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Library Version',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_version),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // File selection
          TextField(
            controller: _normalFilenameController,
            decoration: InputDecoration(
              labelText: 'Normal File (TAP/TZX)',
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: _setNormalFile,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _turboFilenameController,
            decoration: InputDecoration(
              labelText: 'Turbo File (TAP/TZX/Z80/SNA)',
              suffixIcon: IconButton(
                icon: const Icon(Icons.check),
                onPressed: _setTurboFile,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _volumeController,
            decoration: InputDecoration(
              labelText: 'Volume (-100 to 100)',
              suffixIcon: IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: _setVolume,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_status),
                  if (_isBusy) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _estimatedDuration.inMilliseconds > 0
                          ? _currentTime.inMilliseconds /
                              _estimatedDuration.inMilliseconds
                          : 0,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Playing: ${_currentTime.inSeconds}s / ${_estimatedDuration.inSeconds}s',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Control buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _playAudio,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Audio'),
              ),
              ElevatedButton.icon(
                onPressed: _isBusy ? null : _playLeaderTone,
                icon: const Icon(Icons.music_note),
                label: const Text('Leader Tone'),
              ),
              ElevatedButton.icon(
                onPressed: _isBusy ? _stop : null,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
