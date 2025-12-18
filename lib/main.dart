import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'question_flow.dart';
import 'history_screen.dart';
import 'components/background_scaffold.dart';
import 'settings_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:coredo_app/components/banner_ad_widget.dart';
import 'package:coredo_app/sound_manager.dart';

final Logger _logger = Logger('MyApp');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ログの出力方法を設定
  Logger.root.level = Level.ALL; // すべてのログを出す
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
            backgroundColor: const Color.fromARGB(255, 253, 166, 35),
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color.fromARGB(255, 253, 166, 35), width: 2),
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
      overlayVideos: ['assets/21.mp4'],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Color.fromARGB(255, 75, 75, 75),
            ),
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
              const Spacer(flex: 3),
              Expanded(
                flex: 1,
                child: Center(
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          child: const Text('食事を決める'),
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
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Coredo',
                  style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          ),
        ],
      ),
      //bottomNavigationBar: const BannerAdWidget(),
    );
  }
}
