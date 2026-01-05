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
            backgroundColor: const Color(0xFF4FC3F7),
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
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
  @override
  void initState() {
    super.initState();
    AudioManager.play('audio/6.m4a');
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      overlayVideos: ['assets/winter/9.png'],
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
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  childAspectRatio: 3.5, 
                  children: [
                    ElevatedButton(
                      child: Text('食事をする'),
                      onPressed: () => Navigator.pushNamed(context, '/question', arguments: {"mode": "meal"}),
                    ),
                    ElevatedButton(
                      child: Text('旅行に行く'),
                      onPressed: () => Navigator.pushNamed(context, '/question', arguments: {"mode": "travel"}),
                    ),
                    ElevatedButton(
                      child: Text('遊びに行く'),
                      onPressed: () => Navigator.pushNamed(context, '/question', arguments: {"mode": "play"}),
                    ),
                    ElevatedButton(
                      child: Text('贈り物を選ぶ'),
                      onPressed: () => Navigator.pushNamed(context, '/question', arguments: {"mode": "gift"}),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/history'),
                  child: const Text('履歴を見る'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}