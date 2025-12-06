import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'question_flow.dart';
import 'history_screen.dart';
import 'components/background_scaffold.dart';
import 'sound_manager.dart';
import 'settings_screen.dart';
import 'package:audioplayers/audioplayers.dart';

final Logger _logger = Logger('MyApp');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ログの出力方法を設定
  Logger.root.level = Level.ALL; // すべてのログを出す
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
  _logger.info('アプリ起動しました');
  await dotenv.load(fileName: ".env");
  _logger.info('dotenv loaded: ${dotenv.isInitialized}');
  await SoundManager().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coredo',
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.lightBlue,
            side: const BorderSide(color: Colors.lightBlue, width: 2),
            elevation: 0,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/question': (context) => const QuestionFlow(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      overlayVideos: ['assets/21.mp4'], // ← 画像でも動画でもOK
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color.fromARGB(255, 75, 75, 75)),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Column(
            children: [
              const Spacer(flex: 4),
              Expanded(
                flex: 1,
                child: Center(
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          child: const Text('ごはんにする'),
                          onPressed: () {
                            Navigator.pushNamed(context, '/question');
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          child: const Text('履歴を見る'),
                          onPressed: () {
                            Navigator.pushNamed(context, '/history');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Coredo',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop); // ループ再生
    await _bgmPlayer.play(AssetSource('audio/437_long_BPM120.mp3')); // assets/audio/bgm.mp3
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> setVolume(double volume) async {
    await _bgmPlayer.setVolume(volume);
  }
}
