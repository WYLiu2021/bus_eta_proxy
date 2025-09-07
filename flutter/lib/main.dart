import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'map_home.dart';

void main() {
  runApp(const BusEtaApp());
}

class BusEtaApp extends StatelessWidget {
  const BusEtaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus ETA',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _routeController = TextEditingController();
  List<String> _routes = [];
  List<dynamic> _etas = [];
  bool _loading = false;
  String baseUrl = 'http://10.0.2.2:8000'; // Android emulator -> host machine. Replace with your backend URL.

  Future<void> _fetchRoutes() async {
    try {
      final uri = Uri.parse('$baseUrl/routes');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        setState(() => _routes = List<String>.from(json.decode(res.body)));
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _fetchEtas() async {
    final routeId = _routeController.text.trim();
    if (routeId.isEmpty) return;
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('$baseUrl/etas').replace(queryParameters: {'route_id': routeId});
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => _etas = data);
        // Navigate to map view and pass ETAs via arguments
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MapHomeWithData(etas: _etas)),
        );
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bus ETA')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _routeController,
              decoration: const InputDecoration(labelText: 'Route ID', hintText: 'e.g. TCL+1+Hong Kong+Tung Chung'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loading ? null : _fetchEtas,
              icon: const Icon(Icons.search),
              label: _loading ? const Text('Loading...') : const Text('Fetch ETAs'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _routes.isEmpty
                  ? const Center(child: Text('No routes'))
                  : ListView.builder(
                      itemCount: _routes.length,
                      itemBuilder: (context, i) {
                        final r = _routes[i];
                        return ListTile(
                          title: Text(r),
                          onTap: () {
                            _routeController.text = r;
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
