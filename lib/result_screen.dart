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

    // 履歴保存（fromHistoryでない場合のみ）
    final dishName = widget.result['dish'] ?? "不明な料理";
    final description = widget.result['description'] ?? "説明なし";
    if (dishName.isNotEmpty && widget.result['fromHistory'] != true) {
      saveHistory(dishName, description);
    }
  }

  @override
  void dispose() {
    channel.sink.close(); // 接続終了を明示
    super.dispose();
  }

  Future<void> saveHistory(String dishName, String description) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    history.add('$dishName|$description');
    await prefs.setStringList('history', history);
  }

  Future<void> _launchExternalApp(String appName, String dishName) async {
    String url;
    switch (appName) {
      case 'googleMaps':
        url =
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(dishName)}';
        break;
      case 'yahooMaps':
        url =
            'https://map.yahoo.co.jp/search?p=${Uri.encodeComponent(dishName)}';
        break;
      case 'hotpepper':
        url =
            'https://www.hotpepper.jp/s/Y112/?sw=${Uri.encodeComponent(dishName)}';
        break;
      case 'tabelog':
        url = 'https://tabelog.com/rstLst/?sw=${Uri.encodeComponent(dishName)}';
        break;
      case 'ubereats':
        url =
            'https://www.ubereats.com/search?q=${Uri.encodeComponent(dishName)}';
        break;
      case 'cookpad':
        url = 'https://cookpad.com/search/${Uri.encodeComponent(dishName)}';
        break;
      default:
        return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildAppButton(String appName, String logoPath, String dishName, String label) {
    return InkWell(
      onTap: () => _launchExternalApp(appName, dishName),
      child: Column(
        children: [
          Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange,
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
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dishName = widget.result['dish'] ?? "不明な料理";
    final description = widget.result['description'] ?? "説明なし";
    //final screenHeight = MediaQuery.of(context).size.height;

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
              color: Colors.orange,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange,
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
                  const TextSpan(text: 'これはどうかな？'),
                  TextSpan(
                    text: '\n$dishName',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
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

        // アイコン群（Expandedで高さ制限）
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 2,
              childAspectRatio: 1.2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAppButton('googleMaps', 'assets/google_maps_logo.png', dishName, 'Google Maps'),
                _buildAppButton('yahooMaps', 'assets/yahoo_maps_logo.png', dishName, 'Yahoo Maps'),
                _buildAppButton('hotpepper', 'assets/hotpepper_logo.png', dishName, 'Hotpepper'),
                _buildAppButton('tabelog', 'assets/tabelog_logo.png', dishName, 'Tabelog'),
                _buildAppButton('ubereats', 'assets/ubereats_logo.png', dishName, 'Uber Eats'),
                _buildAppButton('cookpad', 'assets/cookpad_logo.png', dishName, 'Cookpad'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 戻るボタン
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