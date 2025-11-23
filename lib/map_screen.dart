import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final String dishName;
  const MapScreen({super.key, required this.dishName});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(35.6895, 139.6917); // 新宿仮置き

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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