import 'package:flutter/material.dart';
import 'package:coredo_app/services/api_service.dart';

class QuestionFlow extends StatefulWidget {
  const QuestionFlow({super.key});
  @override
  State<QuestionFlow> createState() => _QuestionFlowState();
}

class _QuestionFlowState extends State<QuestionFlow> {
  String sessionId = '';
  String prompt = '';
  List<Map<String, dynamic>> options = [];

  @override
  void initState() {
    super.initState();
    _loadFirstQuestion();
  }

  Future<void> _loadFirstQuestion() async {
    try {
      final data = await ApiService.start();
        setState(() {
        sessionId = data['session_id'] ?? '';
        prompt = data['prompt'] ?? '';
        options = List<Map<String, dynamic>>.from(data['options'] ?? []);
      });
    } catch (e) {
      print('API error: $e');
    }
  }


  Future<void> nextQuestion(int optionId) async {
    final data = await ApiService.answer(sessionId, optionId);
    if (!mounted) return;

    if (data['result'] != null) {
      Navigator.pushNamed(context, '/result', arguments: data['result']);
    } else {
      setState(() {
        prompt = data['text'];
        options = List<Map<String, dynamic>>.from(data['options'] ?? []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('質問中')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(prompt, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          ...options.map((opt) => ElevatedButton(
                onPressed: () => nextQuestion(opt['id']),
                child: Text(opt['text']),
              )),
        ],
      ),
    );
  }
}