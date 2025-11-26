import 'dart:convert';
import 'package:http/http.dart' as http;

const baseUrl = 'http://10.0.2.2:3000/api';

class ApiService {
  static Future<Map<String, dynamic>> start() async {
    final r = await http.get(Uri.parse('$baseUrl/questions/start'),
    headers: {'Accept': 'application/json'}
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> answer(String sessionId, String optionId) async {
    final r = await http.post(
      Uri.parse('$baseUrl/answers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'session_id': sessionId, 'option_id': optionId}),
    );
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> result(String sessionId) async {
    final r = await http.get(Uri.parse('$baseUrl/results/$sessionId'));
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> finish(String sessionId, String question) async {
    final response = await http.post(
      Uri.parse('$baseUrl/answers/finish'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': sessionId,
        'question': question,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendAiAnswer(String sessionId, String question) async {
    final res = await http.post(
      Uri.parse('$baseUrl/questions/ai_answer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'session_id': sessionId, 'question': question}),
    );
    return jsonDecode(res.body);
  }
}