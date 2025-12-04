import 'package:flutter/material.dart';
import 'dart:math';
import 'package:coredo_app/services/api_service.dart';
import 'package:coredo_app/result_screen.dart';
import 'components/background_scaffold.dart';

class QuestionFlow extends StatefulWidget {
  const QuestionFlow({super.key});
  @override
  State<QuestionFlow> createState() => _QuestionFlowState();
}

class _QuestionFlowState extends State<QuestionFlow> {
  String sessionId = '';
  String prompt = '';
  List<String> options = [];
  String? overlayPath;

  final List<String> _overlayPaths = [
    'assets/3.MP4',
    'assets/4.MP4',
    'assets/5.MP4',
    'assets/6.MP4',
    'assets/7.MP4',
  ];

  @override
  void initState() {
    super.initState();
    _loadFirstQuestion();
  }

  Future<void> _loadFirstQuestion() async {
    try {
      final data = await ApiService.start();
      final nextQuestions = List<Map<String, dynamic>>.from(
        data['next_questions'] ?? [],
      );

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
            nextQuestions: List<Map<String, dynamic>>.from(
              data['next_questions'],
            ),
            sessionId: sessionId,
          ),
        ),
      );
    } else if (data.containsKey('result')) {
      final resultMap = data['result'] as Map<String, dynamic>;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: resultMap),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    overlayPath ??= _overlayPaths[Random().nextInt(_overlayPaths.length)];
    return BackgroundScaffold(
      overlayVideos: [overlayPath!],
      body: Column(
        children: [
          const Spacer(flex: 2),
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        prompt,
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ...options.map(
                        (opt) => Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: ElevatedButton(
                            onPressed: () => nextQuestion(opt),
                            child: Text(opt),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NextQuestionPage extends StatefulWidget {
  final List<Map<String, dynamic>> nextQuestions;
  final String sessionId;

  const NextQuestionPage({
    super.key,
    required this.nextQuestions,
    required this.sessionId,
  });

  @override
  State<NextQuestionPage> createState() => _NextQuestionPageState();
}

class _NextQuestionPageState extends State<NextQuestionPage> {
  String? overlayPath;

  final List<String> _overlayPaths = [
    'assets/3.MP4',
    'assets/4.MP4',
    'assets/5.MP4',
    'assets/6.MP4',
    'assets/7.MP4',
  ];

  @override
  Widget build(BuildContext context) {
    overlayPath ??= _overlayPaths[Random().nextInt(_overlayPaths.length)];
    final question = widget.nextQuestions.first['question'] as String;
    final options = List<String>.from(widget.nextQuestions.first['options']);

    return BackgroundScaffold(
      overlayVideos: _overlayPaths,
      body: Column(
        children: [
          const Spacer(flex: 2),
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        question,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ...options.map(
                        (opt) => Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: ElevatedButton(
                            onPressed: () => sendAnswer(context, opt),
                            child: Text(opt),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendAnswer(BuildContext context, String answer) async {
    final data = await ApiService.answer(widget.sessionId, answer);

    if (data.containsKey('next_questions')) {
      final next = data['next_questions'];
      if (next is List &&
          next.isNotEmpty &&
          next.first is Map<String, dynamic>) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NextQuestionPage(
              nextQuestions: List<Map<String, dynamic>>.from(next),
              sessionId: widget.sessionId,
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
              sessionId: widget.sessionId,
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
      final resultMap = data['result'] as Map<String, dynamic>;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: resultMap),
        ),
      );
    } else {
      debugPrint("Unexpected API response: $data");
    }
  }
}
