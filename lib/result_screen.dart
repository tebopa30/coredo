import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'components/background_scaffold.dart';
import 'package:coredo_app/sound_manager.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late WebSocketChannel channel;
  double _titleHighlight = 0.1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initAsync();
    });
    AudioManager.play('audio/18.m4a');
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

      // gift
      case 'amazon':
        url = 'https://www.amazon.co.jp/s?k=${Uri.encodeComponent(title)}';
        break;

      case 'rakuten':
        url = 'https://search.rakuten.co.jp/search/mall/${Uri.encodeComponent(title)}/';
        break;

      case 'yahoo':
        url = 'https://shopping.yahoo.co.jp/search?p=${Uri.encodeComponent(title)}';
        break;

      // 共通
      case 'googleMaps':
        url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(title)}';
        break;
      case 'youtube':
        url = 'https://www.youtube.com/results?search_query=${Uri.encodeComponent(title)}';
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
          _buildAppButton('youtube', 'assets/youtube_logo.png', title, 'YouTube'),
          _buildAppButton('jalan', 'assets/jalan_logo.png', title, 'じゃらん'),
          _buildAppButton('rakutenTravel', 'assets/rakuten_travel_logo.png', title, '楽天トラベル'),
        ];

      case 'play':
        return [
          _buildAppButton('googleMaps', 'assets/google_maps_logo.png', title, 'Google Maps'),
          _buildAppButton('youtube', 'assets/youtube_logo.png', title, 'YouTube'),
          _buildAppButton('asoview', 'assets/asoview_logo.png', title, 'アソビュー'),
          _buildAppButton('jalanPlay', 'assets/jalan_logo.png', title, 'じゃらん遊び'),
        ];

      case 'gift':
        return [
          _buildAppButton('amazon', 'assets/amazon_logo.png', title, 'Amazon'),
          _buildAppButton('rakuten', 'assets/rakuten_logo.png', title, '楽天市場'),
          _buildAppButton('yahoo', 'assets/yahoo_logo.png', title, 'Yahoo!'),
          _buildAppButton('youtube', 'assets/youtube_logo.png', title, 'YouTube'),
        ];
      
      case 'free':
        return [
          _buildAppButton('googleMaps', 'assets/google_maps_logo.png', title, 'Google Maps'),
          _buildAppButton('youtube', 'assets/youtube_logo.png', title, 'YouTube'),
        ];

      default: // meal
        return [
          _buildAppButton('googleMaps', 'assets/google_maps_logo.png', title, 'Google Maps'),
          _buildAppButton('tabelog', 'assets/tabelog_logo.png', title, 'Tabelog'),
          _buildAppButton('ubereats', 'assets/ubereats_logo.png', title, 'Uber Eats'),
          _buildAppButton('cookpad', 'assets/cookpad_logo.png', title, 'Cookpad'),
          _buildAppButton('youtube', 'assets/youtube_logo.png', title, 'YouTube'),
        ];
    }
  }

  // -----------------------------
  // アイコンボタン
  // -----------------------------
  Widget _buildAppButton(String appName, String logoPath, String title, String label) {
    return StatefulBuilder(
      builder: (context, setState) {
      double highlight = 0.0;
      return GestureDetector(
        onTapDown: (_) => setState(() => highlight = 0.5), // ← 光る
        onTapUp: (_) => setState(() => highlight = 0.1),     // ← 元に戻る
        onTapCancel: () => setState(() => highlight = 0.1),
        onTap: () => _launchExternalApp(appName, title),
        child: Column(
        children: [AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 1.0 - highlight), // ← 光り方を表現
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withValues(alpha: 0.8),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
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
    },
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
      case 'gift':
        return "こんなプレゼントはどう？";
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 245, 138, 173),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/winter/1.png',
              fit: BoxFit.cover,
            ),
          ),
          
       SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 10),

       // 吹き出し
       Padding(
         padding: const EdgeInsets.symmetric(horizontal: 30),
         child: Container(
           padding: const EdgeInsets.all(20),
           decoration: BoxDecoration(
             color: const Color(0xFF2A2E3D),
             borderRadius: BorderRadius.circular(30),
             boxShadow: [
               BoxShadow(
                 color: const Color(0xFF2A2E3D),
                 blurRadius: 5,
                 offset: const Offset(0, 5),
               ),
             ],
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
        // mode ラベル
        Text(
          modeLabel(mode),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        // 🔥 タイトルを「押せるカード風」に変更
GestureDetector(
  onTapDown: (_) => setState(() => _titleHighlight = 0.2),
  onTapUp: (_) => setState(() => _titleHighlight = 0.05),
  onTapCancel: () => setState(() => _titleHighlight = 0.05),
  onTap: () async {
    final query = Uri.encodeComponent(title);
    final url = Uri.parse("https://www.google.com/search?q=$query");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  },
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 120),
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(_titleHighlight),
          blurRadius: 6,
          offset: const Offset(0, 2),
        )
      ],
    ),
    child: Row(
      children: [
        // 🔥 左側を Flexible で包む（長文対応）
        Flexible(
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2, // ← 2行まで許可
                  overflow: TextOverflow.ellipsis, // ← 長すぎる場合は「…」
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // 🔥 右端のアイコンは固定サイズ
        const Icon(Icons.open_in_new, color: Colors.blueAccent, size: 18),
      ],
    ),
  ),
),

        const SizedBox(height: 16),

        // 説明文
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
            ),
           ],
         ),
       ),
     ),
            const Spacer(flex: 2),

            // アイコン群
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Scrollbar(
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
     ],
    ),
   );
  }
}