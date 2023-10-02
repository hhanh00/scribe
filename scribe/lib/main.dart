import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'store.dart';
import 'whisper.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/record',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/record'),
    StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ScaffoldBar(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/record',
              builder: (context, state) => const RecordPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryPage()),
          ]),
        ])
]);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDb();
  await store.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

class ScaffoldBar extends StatefulWidget {
  final StatefulNavigationShell shell;

  const ScaffoldBar({required this.shell, Key? key});

  @override
  State<ScaffoldBar> createState() => _ScaffoldBar();
}

class _ScaffoldBar extends State<ScaffoldBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.mic), label: 'Record'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'History'),
        ],
        currentIndex: widget.shell.currentIndex,
        onTap: (index) {
          widget.shell.goBranch(index);
        },
      ),
      body: widget.shell,
    );
  }
}

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  bool _isRecording = false;
  final _record = AudioRecorder();
  String _filename = '';
  String _audioFile = '';
  Transcript? _transcript;

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
      final tempPath = await getAudioDir();
      final now = DateTime.now();
      final nowFormatted = DateFormat('yyyyMMdd_HHmmss').format(now);
      _filename = 'scribe-$nowFormatted.wav';
      _audioFile = '$tempPath/$_filename';
      _transcript = Transcript(_filename, now, '');
      await _record.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 16000,
        ),
        path: _audioFile,
      );
    }
    _isRecording = true;
    setState(() {});
  }

  _stop() async {
    await _record.stop();
    _isRecording = false;
    setState(() {});
    final content = await Whisper.transcribe(_audioFile);
    await store.add(_transcript!.name, _transcript!.timestamp, content);
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Observer(builder: (context) {
        final t = store.transcripts;
        return ListView.separated(itemBuilder: (context, index) => 
          ListTile(leading: SizedBox(width: 100, child: Text(t[index].name)), title: Text(t[index].content)), 
        separatorBuilder: (context, index) => Divider(), 
        itemCount: store.transcripts.length);
      },),
    );
  }
}

Future<String?> getAudioDir() async {
  if (Platform.isAndroid)
    return (await getExternalStorageDirectory())?.path;
  else if (Platform.isMacOS)
    return (await getApplicationDocumentsDirectory())?.path;
  return null;
}
