import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get apiKey => dotenv.env['MAPS_API_KEY'] ?? '';

Future<Set<Marker>> searchPlaces(String dishName, LatLng current) async {
  final key = dotenv.env['MAPS_API_KEY'];
  if (key == null || key.isEmpty) {
    throw Exception('APIキーが未初期化です。dotenv.load() が呼ばれているか確認してください');
  }

  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/textsearch/json'
    '?query=${Uri.encodeComponent("$dishName 店")}'
    '&location=${current.latitude},${current.longitude}'
    '&radius=2000'
    '&key=$apiKey',
  );

  final response = await http.get(url);
  debugPrint(response.body);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final results = data['results'] as List;
    return results.map((r) {
      final loc = r['geometry']['location'];
      return Marker(
        markerId: MarkerId(r['place_id']),
        position: LatLng(loc['lat'], loc['lng']),
        infoWindow: InfoWindow(title: r['name']),
      );
    }).toSet();
  } else {
    throw Exception('Places API error: ${response.statusCode}');
  }
}