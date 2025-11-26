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
  List<String> options = [];

  @override
  void initState() {
    super.initState();
    _loadFirstQuestion();
  }

  Future<void> _loadFirstQuestion() async {
    try {
      final data = await ApiService.start();
      final nextQuestions = List<Map<String, dynamic>>.from(data['next_questions'] ?? []);

      if (nextQuestions.isNotEmpty) {
        setState(() {
          sessionId = data['session_id'] ?? '';
          prompt = nextQuestions.first['question'] as String;
          options = List<String>.from(nextQuestions.first['options'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('API error: $e');
    }
  }

  Future<void> nextQuestion(String answer) async {
    final data = await ApiService.answer(sessionId, answer);
    if (!mounted) return;

    if (data.containsKey('next_questions')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NextQuestionPage(
            nextQuestions: List<Map<String, dynamic>>.from(data['next_questions']),
            sessionId: sessionId,
          ),
        ),
      );
    } else if (data.containsKey('result')) {
      if (data['result'] is String) {
        final finishData = await ApiService.finish(sessionId, data['result'] as String);
        final resultMap = finishData['result'] as Map<String, dynamic>;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(result: resultMap),
          ),
        );
      } else if (data['result'] is Map<String, dynamic>) {
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
      appBar: AppBar(title: const Text('考え中')),
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

class NextQuestionPage extends StatelessWidget {
  final List<Map<String, dynamic>> nextQuestions;
  final String sessionId;

  const NextQuestionPage({
    super.key,
    required this.nextQuestions,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final question = nextQuestions.first['question'] as String;
    final options = List<String>.from(nextQuestions.first['options']);

    return Scaffold(
      appBar: AppBar(title: const Text("考え中")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            ...options.map((opt) => ElevatedButton(
                  onPressed: () => sendAnswer(context, opt),
                  child: Text(opt),
                )),
          ],
        ),
      ),
    );
  }

  void sendAnswer(BuildContext context, String answer) async {
    final data = await ApiService.sendAiAnswer(sessionId, answer);

    if (data.containsKey('next_questions')) {
      final next = data['next_questions'];
      if (next is List && next.isNotEmpty && next.first is Map<String, dynamic>) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NextQuestionPage(
              nextQuestions: List<Map<String, dynamic>>.from(next),
              sessionId: sessionId,
            ),
          ),
        );
        return;
      } else if (next is List && next.isNotEmpty && next.first is String) {
        final resultMap = {"dish": next.join(", "), "description": "AIからの提案です"};
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(result: resultMap),
          ),
        );
        return;
      } else if (next is Map<String, dynamic>) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NextQuestionPage(
              nextQuestions: [next],
              sessionId: sessionId,
            ),
          ),
        );
        return;
      } else {
        debugPrint("Unexpected next_questions format: $next");
        return;
      }
    }

    if (data.containsKey('result')) {
      if (data['result'] is String) {
        final finishData = await ApiService.finish(sessionId, data['result'] as String);
        final resultMap = finishData['result'] as Map<String, dynamic>;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(result: resultMap),
          ),
        );
      } else if (data['result'] is Map<String, dynamic>) {
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