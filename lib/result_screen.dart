import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  Future<void> saveHistory(String dishName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    history.add(dishName);
    await prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    final dish = ModalRoute.of(context)!.settings.arguments as Map;

    saveHistory(dish['name']); // 履歴保存

    return Scaffold(
      appBar: AppBar(title: const Text('結果')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('おすすめ料理: ${dish['name']}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Text('レシピ: ${dish['recipe']}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/map', arguments: dish['name']);
              },
              child: const Text('近くのお店を見る'),
            ),
          ],
        ),
      ),
    );
  }
}