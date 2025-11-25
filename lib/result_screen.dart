import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coredo_app/map_screen.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  const ResultScreen({super.key, required this.result});

  Future<void> saveHistory(String dishName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    history.add(dishName);
    await prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    final dishName = result['name']; // ← コンストラクタから受け取った result を使う
    saveHistory(dishName);

    return Scaffold(
      appBar: AppBar(title: const Text('結果')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('おすすめ料理: $dishName', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Text('レシピ: ${result['recipe'] ?? "レシピ情報なし"}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(dishName: dishName),
                  ),
                );
              },
              child: const Text('近くのお店を探す'),
            ),
          ],
        ),
      ),
    );
  }
}