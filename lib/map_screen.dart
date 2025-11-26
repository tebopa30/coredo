import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:coredo_app/places_service.dart';

final Logger _logger = Logger('MyApp');

class MapScreen extends StatefulWidget {
  final String dishName;
  const MapScreen({super.key, required this.dishName});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(35.6895, 139.6917); // 新宿仮置き
  final Set<Marker> _markers = {};
  bool _noResults = false;

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
      mapController?.animateCamera(CameraUpdate.newLatLng(current));

      final markers = await searchPlaces(context, widget.dishName, current);

      setState(() {
        _markers.addAll(markers);
        _noResults = markers.isEmpty;
      });
    } catch (e) {
      _logger.warning('検索失敗: $e');
      mapController?.animateCamera(CameraUpdate.newLatLng(_center));
      setState(() {
        _noResults = true;
      });
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.dishName} のお店')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            markers: _markers,
          ),
          if (_noResults)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '近くに該当するお店が見つかりませんでした',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}