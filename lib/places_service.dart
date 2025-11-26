import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:coredo_app/place_detail.dart';

final logger = Logger();

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
          onTap: () {
            logger.i("Tapped marker: $name ($placeId)");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaceDetailPage(placeId: placeId),
              ),
            );
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