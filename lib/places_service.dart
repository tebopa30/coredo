import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:coredo_app/place_detail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final logger = Logger();

/// Google Places Details API を叩いて店舗詳細を取得
Future<Map<String, dynamic>> fetchPlaceDetails(String placeId) async {
  final apiKey = dotenv.env['MAPS_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception("APIキーが読み込めていません。dotenv.load() が main.dart にあるか確認してください");
  }

  final url =
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=name,rating,formatted_phone_number,formatted_address,opening_hours,photos,reviews'
      '&language=ja'
      '&key=$apiKey';

  final resp = await http.get(Uri.parse(url));
  if (resp.statusCode != 200) {
    throw Exception('Details HTTP ${resp.statusCode}');
  }

  final data = json.decode(resp.body) as Map<String, dynamic>;
  final status = data['status'] as String?;
  final err = data['error_message'];

  if (status != 'OK') {
    throw Exception('Details status=$status, error=$err, placeId=$placeId');
  }

  final result = (data['result'] as Map<String, dynamic>?) ?? {};
  logger.i("opening_hours: ${result['opening_hours']}");
logger.i("reviews: ${result['reviews']}");

  return {
    'name': result['name'],
    'address': result['formatted_address'],
    'phone': result['formatted_phone_number'],
    'rating': result['rating'],
    'opening_hours': result['opening_hours'],
    'photos': result['photos'],
    'reviews': result['reviews'],
  };
}

/// Rails API を叩いて検索結果をマーカーに変換
Future<Set<Marker>> searchPlaces(
    BuildContext context, String dishName, LatLng current) async {
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

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(details['name'] ?? '不明'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("住所: ${details['address'] ?? '不明'}"),
                      Text("評価: ${details['rating']?.toString() ?? '評価なし'}"),
                      if ((details['phone'] as String?)?.isNotEmpty == true)
                        Text("電話: ${details['phone']}"),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("閉じる")),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  PlaceDetailPage(placeId: placeId)),
                        );
                      },
                      child: const Text("詳細を見る"),
                    ),
                  ],
                ),
              );
            } catch (e) {
              Navigator.pop(context); // ローディング閉じる
              logger.e("詳細取得失敗: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('店舗情報の取得に失敗しました。$e')),
              );
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