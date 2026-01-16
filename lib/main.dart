import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'question_flow.dart';
import 'history_screen.dart';
import 'components/background_scaffold.dart';
import 'settings_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:coredo_app/components/banner_ad_widget.dart';
import 'package:coredo_app/sound_manager.dart';
import 'package:coredo_app/voice_list_screen.dart';

final Logger _logger = Logger('MyApp');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
  _logger.info('アプリ起動しました');
  await MobileAds.instance.initialize();
  await SoundManager().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coredo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 16, 175, 249),
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 1),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/question': (context) => const QuestionFlow(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/voices': (context) => const VoiceListScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    AudioManager.play('audio/11.m4a');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      IconButton(
        icon: const Icon(Icons.record_voice_over,
            color: Color.fromARGB(255, 252, 153, 186)),
        onPressed: () {
          Navigator.pushNamed(context, '/voices');
        },
      ),
      IconButton(
        icon: const Icon(Icons.settings,
            color: Color.fromARGB(255, 252, 153, 186)),
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
        },
      ),
    ],
  ),

  body: Stack(
    children: [
      Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: Image.asset(
          'assets/winter/9.png',
          fit: BoxFit.cover,
        ),
      ),

      Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---- TextField + 決定 ----
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText:
                              'キーワードを入れてみてね',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            minimumSize: const Size(0, 20),
                          ),
                        onPressed: () {
                          final text = _controller.text.trim();
                          if (text.isNotEmpty) {
                            Navigator.pushNamed(
                                context, '/question',
                                arguments: {"freeword": text});
                          }
                        },
                        child: const Icon(Icons.search, size: 20),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ---- モード選択 ----
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final label in [
                      '食事をする',
                      '旅行に行く',
                      '遊びに行く',
                      '贈り物を選ぶ'
                    ])
                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/question',
                            arguments: {
                              "mode": label.contains('食事')
                                  ? "meal"
                                  : label.contains('旅行')
                                      ? "travel"
                                      : label.contains('遊び')
                                          ? "play"
                                          : "gift"
                            },
                          ),
                          child: Text(label),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // ---- 履歴ボタン（中央揃え）----
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    child: const Text('履歴'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);
}
}
