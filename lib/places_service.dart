import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:coredo_app/place_detail.dart';

final logger = Logger();

/// Rails API を叩いて店舗詳細を取得
Future<Map<String, dynamic>> fetchPlaceDetails(String placeId) async {
  final url = "http://10.0.2.2:3000/api/places/details?place_id=$placeId";

  final resp = await http.get(Uri.parse(url));
  if (resp.statusCode != 200) {
    throw Exception('Details HTTP ${resp.statusCode}');
  }

  final data = json.decode(resp.body) as Map<String, dynamic>;

  if (data.containsKey('error')) {
    throw Exception(
      'Details status=${data['status']}, error=${data['error']}, placeId=$placeId',
    );
  }

  logger.i("opening_hours: ${data['opening_hours']}");
  logger.i("reviews: ${data['reviews']}");

  return {
    'name': data['name'],
    'address': data['address'],
    'phone': data['phone'],
    'rating': data['rating'],
    'opening_hours': data['opening_hours'],
    // photos は Rails 側が返す完全 URL の配列をそのまま受け取る
    'photos': (data['photos'] as List<dynamic>?)?.cast<String>() ?? [],
    'reviews': data['reviews'] ?? [],
  };
}

/// 店舗詳細ダイアログを表示
void showPlaceDetailsDialog(
  BuildContext context,
  Map<String, dynamic> details,
  String placeId,
) {
  final List<String> photos =
      (details['photos'] as List<dynamic>?)?.cast<String>() ?? [];

  final List<Map<String, dynamic>> reviews =
      (details['reviews'] as List<dynamic>?)
          ?.map((r) => Map<String, dynamic>.from(r as Map))
          .toList() ??
      [];

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(details['name'] ?? '不明'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("住所: ${details['address'] ?? '不明'}"),
            Text("評価: ${details['rating']?.toString() ?? '評価なし'}"),
            if ((details['phone'] as String?)?.isNotEmpty == true)
              Text("電話: ${details['phone']}"),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            if (reviews.isNotEmpty) ...[
              const Text(
                "レビュー:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...reviews.map((review) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "${review['author_name']}: ${review['text'] ?? ''}",
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("閉じる"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaceDetailPage(placeId: placeId),
              ),
            );
          },
          child: const Text("詳細を見る"),
        ),
      ],
    ),
  );
}

/// Rails API を叩いて検索結果をマーカーに変換
Future<Set<Marker>> searchPlaces(
  BuildContext context,
  String dishName,
  LatLng current,
) async {
  try {
    final query = Uri.encodeComponent(dishName);
    final response = await http.get(
      Uri.parse(
        "http://10.0.2.2:3000/api/places/search?query=$query&lat=${current.latitude}&lng=${current.longitude}",
      ),
    );

    if (response.statusCode == 200) {
      final placesData = jsonDecode(response.body);

      if (placesData['results'] == null) {
        logger.w("Places API returned no results");
        return {};
      }

      final results = placesData['results'] as List;

      return results.map((r) {
        final loc = r['geometry']['location'];
        final placeId = r['place_id'];
        final name = r['name'];

        return Marker(
          markerId: MarkerId(placeId),
          position: LatLng(loc['lat'], loc['lng']),
          infoWindow: InfoWindow(title: name),
          onTap: () async {
            logger.i("Tapped marker: $name ($placeId)");

            // 読み込みダイアログ
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            try {
              final details = await fetchPlaceDetails(placeId);
              Navigator.pop(context); // ローディング閉じる

              showPlaceDetailsDialog(context, details, placeId);
            } catch (e) {
              Navigator.pop(context); // ローディング閉じる
              logger.e("詳細取得失敗: $e");
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('店舗情報の取得に失敗しました。$e')));
            }
          },
        );
      }).toSet();
    } else {
      logger.e("Places API error: ${response.statusCode}");
      throw Exception('Places API error: ${response.statusCode}');
    }
  } catch (e) {
    logger.e("Places API exception: $e");
    rethrow;
  }
}
