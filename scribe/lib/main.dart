import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:scribe/whisper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Scribe',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isRecording = false;
  final _record = Record();
  String _audioFile = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scribe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            !_isRecording ? ElevatedButton.icon(onPressed: _start, icon: const Icon(Icons.mic), label: const Text('Record')) :
            ElevatedButton.icon(onPressed: _stop, icon: const Icon(Icons.stop), label: const Text('Stop')),
          ],
        ),
      ),
    );
  }

  _start() async {
    // Check and request permission
    if (await _record.hasPermission()) {
      final tempDir = await getExternalStorageDirectory();
      String tempPath = tempDir!.path;
      final now = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'scribe-$now.wav';
      _audioFile = '$tempPath/$filename';
      await _record.start(
        path: _audioFile,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 16000,
      );
    }
    _isRecording = true;
    setState(() {});
  }

  _stop() async {
    await _record.stop();
    _isRecording = false;
    final transcript = Whisper.transcribe(_audioFile);
    print(transcript);
    setState(() {});
  }
}
