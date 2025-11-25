import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:coredo_app/place_detail.dart';

final logger = Logger();

Future<Set<Marker>> searchPlaces(
    BuildContext context, String dishName, LatLng current) async {
  final query = Uri.encodeComponent(dishName);
  final response = await http.get(
    Uri.parse(
        "http://10.0.2.2:3000/api/places/search?query=$query&lat=${current.latitude}&lng=${current.longitude}"),
  );

  if (response.statusCode == 200) {
    final placesData = jsonDecode(response.body);
    final results = placesData['results'] as List;

    return results.map((r) {
      final loc = r['geometry']['location'];
      return Marker(
        markerId: MarkerId(r['place_id']),
        position: LatLng(loc['lat'], loc['lng']),
        infoWindow: InfoWindow(title: r['name']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaceDetailPage(placeId: r['place_id']),
            ),
          );
        },
      );
    }).toSet();
  } else {
    throw Exception('Places API error: ${response.statusCode}');
  }
}