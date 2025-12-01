import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/background_scaffold.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  const ResultScreen({super.key, required this.result});

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
        url = 'https://tabelog.com/rstLst/?sw=${Uri.encodeComponent(dishName)}';
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
        padding: const EdgeInsets.all(8),
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
        child: Image.asset(logoPath, fit: BoxFit.contain),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dishName = result['dish'] ?? "不明な料理";
    final description = result['description'] ?? "説明なし";
    final imageUrl = result['image_url'];

    // 履歴からの遷移でなければ保存
    if (dishName.isNotEmpty && result['fromHistory'] != true) {
      saveHistory(dishName);
    }

    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('結果'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 24),
                  children: [
                    const TextSpan(text: 'これなんかどう？\n'),
                    TextSpan(text: dishName),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              if (imageUrl != null && imageUrl.isNotEmpty)
                SizedBox(width: 200, child: Image.network(imageUrl)),
              const SizedBox(height: 30),

              // External App Buttons Section
              const Text(
                'お店を探す',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildAppButton(
                    'googleMaps',
                    'assets/google_maps_logo.png',
                    dishName,
                  ),
                  _buildAppButton(
                    'yahooMaps',
                    'assets/yahoo_maps_logo.png',
                    dishName,
                  ),
                  _buildAppButton(
                    'hotpepper',
                    'assets/hotpepper_logo.png',
                    dishName,
                  ),
                  _buildAppButton(
                    'tabelog',
                    'assets/tabelog_logo.png',
                    dishName,
                  ),
                  _buildAppButton(
                    'ubereats',
                    'assets/ubereats_logo.png',
                    dishName,
                  ),
                ],
              ),

              const SizedBox(height: 30),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Navigator の最初の画面まで戻る
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
