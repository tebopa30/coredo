import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:coredo_app/places_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 店舗詳細ダイアログ
void showPlaceDetailsDialog(BuildContext context, Map<String, dynamic> details) {
  final name = details['name'] ?? '名前不明';
  final address = details['address'] ?? '住所不明';
  final rating = details['rating']?.toString() ?? '評価なし';
  final phone = details['phone'] ?? '電話番号なし';

  // 営業時間（配列で返ることが多い）
  List<String> openingHours = [];
  if (details['opening_hours'] != null &&
      details['opening_hours']['weekday_text'] != null) {
    openingHours = List<String>.from(details['opening_hours']['weekday_text']);
  }

  // photo_reference がある場合は URL を組み立てる
  String? photoUrl;
  if (details['photos'] != null && details['photos'].isNotEmpty) {
    final photoRef = details['photos'][0]['photo_reference'];
    photoUrl =
        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photoRef&key=${dotenv.env['MAPS_API_KEY']}';
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photoUrl != null)
                Image.network(photoUrl, fit: BoxFit.cover),
              const SizedBox(height: 10),
              Text(address),
              const SizedBox(height: 5),
              Text('評価: $rating'),
              const SizedBox(height: 5),
              Text('電話: $phone'),
              const SizedBox(height: 10),
              if (openingHours.isNotEmpty) ...[
                const Text('営業時間:'),
                for (var line in openingHours) Text(line),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      );
    },
  );
}

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

      // searchPlaces が Marker のリストを返す想定
      final markers = await searchPlaces(context, widget.dishName, current);

      setState(() {
        _markers.addAll(markers.map((m) {
          // Marker に onTap を追加してダイアログ表示
          return m.copyWith(
            onTapParam: () async {
              final details = await fetchPlaceDetails(m.markerId.value);
              showPlaceDetailsDialog(context, details);
            },
          );
        }));
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