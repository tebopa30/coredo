import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

final Logger _logger = Logger('MyApp');

class MapScreen extends StatefulWidget {
  final String dishName;
  const MapScreen({super.key, required this.dishName});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(35.6895, 139.6917); // 新宿仮置き

  /// 現在地を取得する関数
  Future<LatLng> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ユーザーが拒否した場合 → fallback 座標を返す
        return _center;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // 永久拒否 → 設定画面に誘導するか fallback
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

  /// Map生成時に呼ばれる関数
  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    try {
      LatLng current = await _getCurrentLocation();
      mapController.animateCamera(CameraUpdate.newLatLng(current));
    } catch (e) {
      _logger.warning('現在地取得失敗: $e');
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
          target: _center, // 仮置き位置
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        markers: {
          Marker(
            markerId: const MarkerId('shop1'),
            position: _center,
            infoWindow: InfoWindow(title: '${widget.dishName}のお店'),
          ),
        },
      ),
    );
  }
}