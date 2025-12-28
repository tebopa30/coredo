import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'components/background_scaffold.dart';
import 'package:coredo_app/sound_manager.dart';
import 'package:flutter/gestures.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initAsync();
    });
  }

  Future<void> _initAsync() async {
    final sessionId = widget.result['session_id'];
    try {
      channel = WebSocketChannel.connect(
        Uri.parse("ws://10.0.2.2:3000/cable?session_id=$sessionId"),
      );
    } catch (e) {
      debugPrint("WebSocket error: $e");
    }

    AudioManager.playSetA();

    final title = widget.result['title'] ?? "おすすめ";
    final description = widget.result['description'] ?? "説明なし";

    if (title.isNotEmpty && widget.result['fromHistory'] != true) {
      saveHistory(title, description);
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Future<void> saveHistory(String title, String description) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> history = prefs.getStringList('history') ?? [];

  final mode = widget.result['extra']?['mode'] ?? 'meal';

  history.add('$title|$description|$mode');
  await prefs.setStringList('history', history);
  }
  // -----------------------------
  // 外部リンク（mode 別）
  // -----------------------------
  Future<void> _launchExternalApp(String appName, String title) async {
    String url;

    switch (appName) {
      // meal
      case 'tabelog':
        url = 'https://tabelog.com/rstLst/?sw=${Uri.encodeComponent(title)}';
        break;
      case 'ubereats':
        url = 'https://www.ubereats.com/search?q=${Uri.encodeComponent(title)}';
        break;
      case 'cookpad':
        url = 'https://cookpad.com/search/${Uri.encodeComponent(title)}';
        break;

      // travel
      case 'jalan':
        url = 'https://www.jalan.net/?keyword=${Uri.encodeComponent(title)}';
        break;

      case 'rakutenTravel':
        url = 'https://travel.rakuten.co.jp/';
        break;

      // play
      case 'asoview':
        url = 'https://www.asoview.com/';
        break;

      case 'jalanPlay':
        url = 'https://www.jalan.net/activity/';
        break;

      // 共通
      case 'googleMaps':
        url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(title)}';
        break;

      default:
        return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // -----------------------------
  // mode 別アイコンセット
  // -----------------------------
  List<Widget> buildButtons(String mode, String title) {
    switch (mode) {
      case 'travel':
        return [
          _buildAppButton('googleMaps', 'assets/google_maps_logo.png', title, 'Google Maps'),
          _buildAppButton('jalan', 'assets/jalan_logo.png', title, 'じゃらん'),
          _buildAppButton('rakutenTravel', 'assets/rakuten_travel_logo.png', title, '楽天トラベル'),
        ];

      case 'play':
        return [
          _buildAppButton('googleMaps', 'assets/google_maps_logo.png', title, 'Google Maps'),
          _buildAppButton('asoview', 'assets/asoview_logo.png', title, 'アソビュー'),
          _buildAppButton('jalanPlay', 'assets/jalan_logo.png', title, 'じゃらん遊び'),
        ];

      default: // meal
        return [
          _buildAppButton('googleMaps', 'assets/google_maps_logo.png', title, 'Google Maps'),
          _buildAppButton('tabelog', 'assets/tabelog_logo.png', title, 'Tabelog'),
          _buildAppButton('ubereats', 'assets/ubereats_logo.png', title, 'Uber Eats'),
          _buildAppButton('cookpad', 'assets/cookpad_logo.png', title, 'Cookpad'),
        ];
    }
  }

  // -----------------------------
  // アイコンボタン
  // -----------------------------
  Widget _buildAppButton(String appName, String logoPath, String title, String label) {
    return InkWell(
      onTap: () => _launchExternalApp(appName, title),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4FC3F7),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                logoPath,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // mode 別の吹き出しテキスト
  // -----------------------------
  String modeLabel(String mode) {
    switch (mode) {
      case 'travel':
        return "こんな旅行先はどう？";
      case 'play':
        return "こんな遊びはどう？";
      default:
        return "これはどうかな？";
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.result['title'] ?? "おすすめ";
    final description = widget.result['description'] ?? "説明なし";
    final mode = widget.result['extra']?['mode'] ?? 'meal';

    return BackgroundScaffold(
      overlayVideos: ['assets/20.mp4'],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 10),

            // 吹き出し
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2E3D),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2A2E3D),
                      blurRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(text: modeLabel(mode)),
                      TextSpan(
                        text: '\n$title',
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final query = Uri.encodeComponent(title);
                            final url = Uri.parse("https://www.google.com/search?q=$query");
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                      ),
                      const TextSpan(text: '\n'),
                      TextSpan(
                        text: description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const Spacer(flex: 2),

            // アイコン群
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                  physics: const BouncingScrollPhysics(),
                  children: buildButtons(mode, title),
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('メインに戻る'),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}