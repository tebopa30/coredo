import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenvをimport

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
          details = data; // トップレベルをそのまま使う
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

    final photos = details?['photos'] as List<dynamic>?;
    final apiKey = dotenv.env['MAPS_API_KEY'] ?? ''; // ← .envから取得

    return Scaffold(
      appBar: AppBar(title: Text(details?['name'] ?? '不明')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("住所: ${details?['address'] ?? '不明'}"),
          const SizedBox(height: 8),
          Text("電話番号: ${details?['phone'] ?? '不明'}"),
          const SizedBox(height: 8),
          if (details?['rating'] != null)
            Text("評価: ${details?['rating']} / 5"),
          const SizedBox(height: 16),

          // 写真表示
          if (photos != null && photos.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("写真:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      final ref = photo['photo_reference'];
                      final url =
                          "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$ref&key=$apiKey";
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image,
                                size: 100, color: Colors.grey);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // レビュー表示
          if (details?['reviews'] != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("レビュー:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...List<Map<String, dynamic>>.from(details?['reviews'] ?? [])
                    .map((review) => Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text("- ${review['text'] ?? ''}"),
                        )),
              ],
            ),
        ],
      ),
    );
  }
}