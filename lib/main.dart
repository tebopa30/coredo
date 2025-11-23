import 'package:flutter/material.dart';
import 'question_flow.dart';
import 'result_screen.dart';
import 'map_screen.dart';
import 'history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coredo',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/question': (context) => const QuestionFlow(),
        '/result': (context) => const ResultScreen(),
        '/map': (context) => const MapScreen(dishName: 'ラーメン'),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coredo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('質問スタート'),
              onPressed: () {
                Navigator.pushNamed(context, '/question');
              },
            ),
            ElevatedButton(
              child: const Text('履歴を見る'),
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
          ],
        ),
      ),
    );
  }
}