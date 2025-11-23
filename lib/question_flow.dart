import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'package:coredo_app/services/api_service.dart';

class QuestionFlow extends StatefulWidget {
  const QuestionFlow({super.key});
  @override
  State<QuestionFlow> createState() => _QuestionFlowState();
}

class _QuestionFlowState extends State<QuestionFlow> {
  String prompt = 'あっさり？こってり？';
  List<String> options = ['あっさり', 'こってり'];

  Future<void> nextQuestion(String answer) async {
    final data = await ApiService.nextQuestion(answer);
    if (data['dish'] != null) {
      Navigator.pushNamed(context, '/result', arguments: data['dish']);
    } else {
      setState(() {
        prompt = data['prompt'];
        options = List<String>.from(data['options']);
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
                onPressed: () => nextQuestion(opt),
                child: Text(opt),
              )),
        ],
      ),
    );
  }
}