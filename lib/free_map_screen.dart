import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Google Maps ki jagah free map
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class FreeMapScreen extends StatefulWidget {
  @override
  State<FreeMapScreen> createState() => _FreeMapScreenState();
}

class _FreeMapScreenState extends State<FreeMapScreen> {
  LatLng _currentLatLng = LatLng(31.4504, 73.1350); // Default (Faisalabad)
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Location fetch karne ka asli logic (No Card Needed)
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low, // High ki jagah Low kar ke dekhein, ye jaldi connect hota hai
      timeLimit: const Duration(seconds: 10), // 10 second baad agar location na mile to error de de
    );

    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
      _isFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live Location (Free)")),
      body: _isFetching
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
        options: MapOptions(initialCenter: _currentLatLng, initialZoom: 15),
        children: [
          TileLayer( // Ye internet se free map tiles load karega
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.sidra.taskapp',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLatLng,
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        color: Colors.white,
        child: Text("📍 Now apki live location yeh hy:\n${_currentLatLng.latitude}, ${_currentLatLng.longitude}"),
      ),
    );
  }
}