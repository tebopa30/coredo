import 'package:flutter/material.dart';
import 'dart:math';
import 'package:coredo_app/services/api_service.dart';
import 'package:coredo_app/result_screen.dart';
import 'components/background_scaffold.dart';
import 'package:coredo_app/sound_manager.dart';
import 'package:coredo_app/components/interstitial_ad_widget.dart';

class QuestionFlow extends StatefulWidget {
  const QuestionFlow({super.key});

  @override
  State<QuestionFlow> createState() => _QuestionFlowState();
}

class _QuestionFlowState extends State<QuestionFlow> {
  bool isLoading = true;
  String sessionId = '';
  String prompt = '';
  List<String> options = [];
  String? overlayPath;
  String? errorMessage;
  String? loadingAnswer;

  final List<String> _overlayPaths = [
    'assets/winter/2.png',
    'assets/winter/3.png',
    'assets/winter/4.png',
    'assets/winter/5.png',
    'assets/winter/6.png',
    'assets/winter/7.png',
    'assets/winter/8.png',
  ];

  @override
  void initState() {
    super.initState();
    overlayPath = _overlayPaths[Random().nextInt(_overlayPaths.length)];
    Future.microtask(() {
      AudioManager.playRandom();
      AdManager().loadInterstitialAd();
    });
  }
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final mode = args?["mode"] ?? "meal";
      _loadFirstQuestion(mode);
      _initialized = true;
    }
  }

  Future<void> _loadFirstQuestion(String mode) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.start(mode: mode);

      final next = List<Map<String, dynamic>>.from(data['next_questions'] ?? []);

      if (next.isNotEmpty) {
        setState(() {
          sessionId = data['session_id'] ?? '';
          prompt = next.first['question'];
          options = List<String>.from(next.first['options']);
        });
      } else {
        setState(() {
          errorMessage = '質問が見つかりませんでした';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'エラーが発生しました: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

Future<void> _answer(String answer) async {
  setState(() {
    loadingAnswer = answer;
  });

  final data = await ApiService.answer(sessionId, answer);
  if (!mounted) return;

  if (data.containsKey('next_questions')) {
    final next = List<Map<String, dynamic>>.from(data['next_questions']);

    overlayPath = _overlayPaths[Random().nextInt(_overlayPaths.length)];

    Future.delayed(const Duration(milliseconds: 100), () {
      AudioManager.playRandom();
    });
    if (!mounted) return;

    setState(() {
      prompt = next.first['question'];
      options = List<String>.from(next.first['options']);
      loadingAnswer = null;
    });

    return;
  }

  if (data.containsKey('result')) {
    final resultMap = data['result'];
    if (!mounted) return;

    final adManager = AdManager();
    adManager.showInterstitialAd(() {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: resultMap),
        ),
      );
    });
    return;
  }

  setState(() {
    errorMessage = "Unexpected API response";
    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Image.asset(
              overlayPath!,
              fit: BoxFit.cover,
            ),
          ),

          Column(
            children: [
              const Spacer(flex: 2),

              Expanded(
                flex: 1,
                child: Center(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : errorMessage != null
                          ? Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            )
                          : Column(
                              children: [
                                Text(
                                  prompt,
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),

                                Expanded(
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30),
                                    childAspectRatio: 3.0,
                                    children: options.map((opt) {
                                      return ElevatedButton(
                                        onPressed: loadingAnswer == null ? () => _answer(opt) : null,
                                        child: loadingAnswer == opt
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(opt),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}