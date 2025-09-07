import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapHome extends StatefulWidget {
  const MapHome({super.key});
  @override
  State<MapHome> createState() => _MapHomeState();
}

class _MapHomeState extends State<MapHome> {
  late GoogleMapController _mapController;
  final LatLng stop = LatLng(22.28552, 114.15769);
  List<dynamic> _etas = [];
  String baseUrl = 'http://10.0.2.2:8000';

  double _deg2rad(double deg) => deg * pi / 180;
  double _distanceKm(LatLng a, LatLng b) {
    const R = 6371; // km
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final lat1 = _deg2rad(a.latitude);
    final lat2 = _deg2rad(b.latitude);
    final h = (sin(dLat / 2) * sin(dLat / 2)) + (sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2));
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));
    return R * c;
  }

  Future<void> _fetchEtas(String routeId) async {
    try {
      final uri = Uri.parse('$baseUrl/etas').replace(queryParameters: {'route_id': routeId});
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        setState(() => _etas = json.decode(res.body));
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      Marker(markerId: const MarkerId('stop'), position: stop, infoWindow: const InfoWindow(title: 'Stop')),
      for (var i = 0; i < _etas.length; i++)
        if (_etas[i]['lat'] != null && _etas[i]['lon'] != null)
          Marker(
            markerId: MarkerId('bus_$i'),
            position: LatLng(_etas[i]['lat'], _etas[i]['lon']),
            infoWindow: InfoWindow(title: _etas[i]['co'] ?? 'bus'),
          ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Map ETA')),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: stop, zoom: 14),
              markers: markers,
              onMapCreated: (c) => _mapController = c,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _etas.length,
              itemBuilder: (c, i) {
                final e = _etas[i] as Map<String, dynamic>;
                final etaTime = e['eta'] ?? '';
                final lat = e['lat'];
                final lon = e['lon'];
                String distanceText = '';
                if (lat != null && lon != null) {
                  final d = _distanceKm(LatLng(lat, lon), stop);
                  final speed = max(1.0, (e['speed_kmh'] ?? 20).toDouble());
                  final minutes = ((d / speed) * 60).round();
                  distanceText = '$minutes min (${d.toStringAsFixed(2)} km)';
                }
                return ListTile(
                  title: Text(etaTime),
                  subtitle: Text('${e['co'] ?? ''} • ${e['remark']?['en'] ?? ''}'),
                  trailing: Text(distanceText),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
