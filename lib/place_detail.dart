import 'package:flutter/material.dart';
import 'package:coredo_app/places_service.dart';

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
      final result = await fetchPlaceDetails(widget.placeId);
      debugPrint("fetchPlaceDetails result reviews: ${result['reviews']}");
      if (!mounted) return;
      setState(() => details = result);
    } catch (e) {
      debugPrint("詳細取得失敗: $e");
      if (!mounted) return;
      setState(() => details = const {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (details == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<dynamic> rawReviews =
        (details?['reviews'] as List<dynamic>?) ?? const [];
    final List<Map<String, dynamic>> reviews = rawReviews
        .where((r) => r is Map)
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();

    // Rails 側が返す photos はすでに完全な URL
    final List<String> photos =
        (details?['photos'] as List<dynamic>?)?.cast<String>() ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(details?['name'] ?? '不明')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("住所: ${details?['address'] ?? '不明'}"),
          const SizedBox(height: 8),
          Text("電話番号: ${details?['phone'] ?? '不明'}"),
          const SizedBox(height: 8),
          if (details?['rating'] != null) Text("評価: ${details?['rating']} / 5"),
          const SizedBox(height: 16),

          // 写真表示（photo_reference を使わず、Rails 側の完全 URL をそのまま利用）
          if (photos.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: photos
                    .map(
                      (url) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.network(url, fit: BoxFit.cover),
                      ),
                    )
                    .toList(),
              ),
            ),

          const SizedBox(height: 16),

          // レビュー部分
          if (reviews.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "レビュー:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...reviews.map((review) {
                  final author = review['author_name'] ?? '匿名';
                  final rating = review['rating']?.toString() ?? '-';
                  final when = review['relative_time_description'] ?? '';
                  final text = review['text'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "⭐ $rating - $author（$when）",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(text),
                        const Divider(height: 20),
                      ],
                    ),
                  );
                }).toList(),
              ],
            )
          else
            const Text("レビューはまだありません"),
        ],
      ),
    );
  }
}
