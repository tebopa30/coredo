import 'package:flutter/material.dart';
import 'package:coredo_app/places_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<dynamic> photos = (details?['photos'] as List<dynamic>?) ?? const [];
    final List<dynamic> rawReviews = (details?['reviews'] as List<dynamic>?) ?? const [];
    final Map<String, dynamic>? openingHours = details?['opening_hours'] as Map<String, dynamic>?;
    final List<dynamic> weekdayText = (openingHours?['weekday_text'] as List<dynamic>?) ?? const [];

    final List<Map<String, dynamic>> reviews = rawReviews
        .where((r) => r is Map)
        .map((r) => Map<String, dynamic>.from(r as Map))
        .where((r) => (r['text'] as String?)?.trim().isNotEmpty ?? false)
        .toList();

    final apiKey = dotenv.env['MAPS_API_KEY'] ?? '';

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

          // 営業時間
          if (weekdayText.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("営業時間:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...weekdayText.map((line) => Text(line.toString())).toList(),
              ],
            )
          else
            const Text("営業時間情報は登録されていません"),

          const SizedBox(height: 16),

          // 写真
          if (photos.isNotEmpty)
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
                      final photoRef = (photo is Map) ? photo['photo_reference'] : null;
                      if (photoRef == null) return const SizedBox.shrink();
                      final url =
                          "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoRef&key=$apiKey";
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          else
            const Text("写真はまだ登録されていません"),

          const SizedBox(height: 16),

          // レビュー
          if (reviews.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("レビュー:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...reviews.map((review) {
                  final author = review['author_name'] ?? '匿名';
                  final rating = review['rating']?.toString() ?? '-';
                  final when = review['relative_time_description'] ?? '';
                  final text = review['text'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "⭐ $rating - $author（$when）",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          text,
                          softWrap: true,
                          maxLines: null,
                          overflow: TextOverflow.visible,
                        ),
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