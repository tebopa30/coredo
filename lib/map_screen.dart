import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:coredo_app/places_service.dart'; // ← REST API直叩きの関数をimport

final Logger _logger = Logger('MyApp');

class MapScreen extends StatefulWidget {
  final String dishName; // ← 「ラーメン」「カレー」など
  const MapScreen({super.key, required this.dishName});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(35.6895, 139.6917); // 新宿仮置き
  final Set<Marker> _markers = {};

  Future<LatLng> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _center;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return _center;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }

  void _onMapCreated(GoogleMapController controller) async {
    debugPrint('Map created');
    mapController = controller;
    try {
      LatLng current = await _getCurrentLocation();
      mapController.animateCamera(CameraUpdate.newLatLng(current));

      // 🔍 dishName に応じて検索 (REST API直叩き)
      final markers = await searchPlaces(widget.dishName, current);

      setState(() {
        _markers.addAll(markers);
      });
    } catch (e) {
      _logger.warning('検索失敗: $e');
      mapController.animateCamera(CameraUpdate.newLatLng(_center));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.dishName} のお店')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        markers: _markers,
      ),
    );
  }
}