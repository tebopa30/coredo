import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coredo_app/result_screen.dart';
import 'components/background_scaffold.dart';
import 'package:coredo_app/components/banner_ad_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> deleteHistoryItemByValue(String value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      history.removeWhere((item) => item == value); // 値ベースですべて削除
    });
    await prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    // 重複を除去して表示用のリストを作成し、最新20件のみ取得
    final uniqueHistory = history.toSet().toList().reversed.take(20).toList();

    return BackgroundScaffold(
  appBar: AppBar(
    title: const Text('履歴'),
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  ),
  extendBodyBehindAppBar: true,
  body: Stack(
    children: [
      // 🖼 共通背景画像
      Image.asset(
        'assets/bg1.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
      ListView.builder(
        itemCount: uniqueHistory.length,
        itemBuilder: (context, index) {
          final item = uniqueHistory[index];
          final parts = item.split('|');
          final dish = parts[0];
          final description = parts.length > 1 ? parts[1] : '説明なし';

          return Dismissible(
            key: Key(item),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              await deleteHistoryItemByValue(item);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$dish を削除しました')),
              );
            },
            child: ListTile(
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$dish\n',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      result: {
                        'dish': dish,
                        'description': description,
                        'image_url': '',
                        'fromHistory': true,
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    ],
  ),
  bottomNavigationBar: const BannerAdWidget(),
 );
 }
}