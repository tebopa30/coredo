import 'package:flutter/material.dart';
import 'package:coredo_app/services/api_service.dart';
import 'package:coredo_app/result_screen.dart';

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
      debugPrint('API error: $e');
    }
  }

  Future<void> nextQuestion(String optionId) async {
    final data = await ApiService.answer(sessionId, optionId);
    if (!mounted) return;

    if (data.containsKey('next_questions')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NextQuestionPage(
            nextQuestions: List<String>.from(data['next_questions']),
            sessionId: sessionId,
          ),
        ),
      );
    } else if (data.containsKey('result')) {
  if (data['result'] is String) {
    // ai_answer が String を返した場合 → finish API を呼ぶ
    final finishData = await ApiService.finish(sessionId, data['result'] as String);
    final resultMap = finishData['result'] as Map<String, dynamic>;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(result: resultMap),
      ),
    );
  } else if (data['result'] is Map<String, dynamic>) {
    // すでに Map が返ってきている場合 → そのまま ResultScreen に渡す
      final resultMap = data['result'] as Map<String, dynamic>;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: resultMap),
        ),
      );
    }
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
                onPressed: () => nextQuestion(opt['id'] as String),
                child: Text(opt['text']),
              )),
        ],
      ),
    );
  }
}

class NextQuestionPage extends StatelessWidget {
  final List<String> nextQuestions;
  final String sessionId;

  const NextQuestionPage({
    super.key,
    required this.nextQuestions,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("次の質問を選んでください")),
      body: ListView.builder(
        itemCount: nextQuestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(nextQuestions[index]),
            onTap: () {
              // ユーザーが選んだ質問を送信
              sendAnswer(context, nextQuestions[index]);
            },
          );
        },
      ),
    );
  }

void sendAnswer(BuildContext context, String question) async {
  final data = await ApiService.sendAiAnswer(sessionId, question);

  if (data.containsKey('next_questions')) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextQuestionPage(
          nextQuestions: List<String>.from(data['next_questions']),
          sessionId: sessionId,
        ),
      ),
    );
  } else if (data.containsKey('result')) {
    if (data['result'] is String) {
      // ai_answer が String を返した場合 → finish API を呼ぶ
      final finishData = await ApiService.finish(sessionId, data['result'] as String);
      final resultMap = finishData['result'] as Map<String, dynamic>;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: resultMap),
        ),
      );
    } else if (data['result'] is Map<String, dynamic>) {
      // すでに Map が返ってきている場合 → そのまま ResultScreen に渡す
      final resultMap = data['result'] as Map<String, dynamic>;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: resultMap),
        ),
      );
    }
  } else {
    debugPrint("Unexpected API response: $data");
  }
}
}