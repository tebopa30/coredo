import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlaceDetailPage extends StatefulWidget {
  final String placeId;
  const PlaceDetailPage({super.key, required this.placeId});

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  Map<String, dynamic>? details;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/api/places/details?place_id=${widget.placeId}"),
      );
      debugPrint("Details status=${response.statusCode}");
      debugPrint("Details body=${response.body}");

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          details = data['result']; // ← 実際のキー名を確認
        });
      } else {
        debugPrint("Details API error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Details fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (details == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(details?['name'] ?? '不明')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("住所: ${details?['formatted_address'] ?? '不明'}"),
          Text("電話番号: ${details?['formatted_phone_number'] ?? '不明'}"),
          if (details?['opening_hours']?['weekday_text'] != null)
            Text("営業時間:\n${(details?['opening_hours']['weekday_text'] as List).join('\n')}"),
          if (details?['rating'] != null)
            Text("評価: ${details?['rating']} / 5"),
        ],
      ),
    );
  }
}