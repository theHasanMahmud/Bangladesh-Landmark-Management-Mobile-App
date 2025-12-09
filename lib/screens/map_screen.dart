import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../models/landmark.dart';
import '../services/db_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _api = ApiService();
  final DbService _db = DbService();
  List<Landmark> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _api.fetchAll();
      await _db.upsertLandmarks(list);
      setState(() => _items = list);
    } catch (_) {
      final cached = await _db.getAll();
      setState(() => _items = cached);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : FlutterMap(
            options: MapOptions(center: LatLng(23.6850, 90.3563), zoom: 6.5),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _items
                    .map((e) => Marker(
                          point: LatLng(e.lat, e.lon),
                          width: 80,
                          height: 80,
                          builder: (ctx) => GestureDetector(
                            onTap: () => _showBottomSheet(e),
                            child: const Icon(Icons.location_on, size: 36, color: Colors.red),
                          ),
                        ))
                    .toList(),
              ),
            ],
          );
  }

  void _showBottomSheet(Landmark e) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(e.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (e.imageUrl != null)
            SizedBox(height: 160, child: Image.network(e.imageUrl!, fit: BoxFit.cover)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Edit')),
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.delete), label: const Text('Delete')),
          ])
        ]),
      ),
    );
  }
}
