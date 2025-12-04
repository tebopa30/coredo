import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'components/background_scaffold.dart';

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
    final sessionId = widget.result['session_id'];
    channel = WebSocketChannel.connect(
      Uri.parse("ws://10.0.2.2:3000/cable?session_id=$sessionId"),
    );

    // 履歴保存（fromHistoryでない場合のみ）
    final dishName = widget.result['dish'] ?? "不明な料理";
    if (dishName.isNotEmpty && widget.result['fromHistory'] != true) {
      saveHistory(dishName);
    }
  }

  @override
  void dispose() {
    channel.sink.close(); // 接続終了を明示
    super.dispose();
  }

  Future<void> saveHistory(String dishName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    history.add(dishName);
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
        url =
            'https://tabelog.com/rstLst/?sw=${Uri.encodeComponent(dishName)}';
        break;
      case 'ubereats':
        url =
            'https://www.ubereats.com/search?q=${Uri.encodeComponent(dishName)}';
        break;
      default:
        return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildAppButton(String appName, String logoPath, String dishName) {
    return InkWell(
      onTap: () => _launchExternalApp(appName, dishName),
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final dishName = widget.result['dish'] ?? "不明な料理";
    final description = widget.result['description'] ?? "説明なし";

    return BackgroundScaffold(
      overlayVideos: ['assets/8.MP4'], // ← 固定の背景動画を設定
      appBar: AppBar(
        title: const Text('結果'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 24),
                  children: [
                    const TextSpan(text: 'これはどうかな？\n\n'),
                    TextSpan(
                      text: dishName,
                      style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: Colors.pink,
                    ),
                   ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              const Text(
                '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildAppButton(
                      'googleMaps', 'assets/google_maps_logo.png', dishName),
                  _buildAppButton(
                      'yahooMaps', 'assets/yahoo_maps_logo.png', dishName),
                  _buildAppButton(
                      'hotpepper', 'assets/hotpepper_logo.png', dishName),
                  _buildAppButton(
                      'tabelog', 'assets/tabelog_logo.png', dishName),
                  _buildAppButton(
                      'ubereats', 'assets/ubereats_logo.png', dishName),
                ],
              ),
              const SizedBox(height: 0),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text('メインに戻る'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}