import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/landmark.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import 'new_entry_screen.dart';

enum MapStyle { standard, terrain, light }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _api = ApiService();
  final DbService _db = DbService();
  final MapController _controller = MapController();
  List<Landmark> _items = [];
  LatLng _center = LatLng(23.6850, 90.3563);
  bool _loading = true;
  bool _locating = false;
  MapStyle _style = MapStyle.standard;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _api.fetchAll();
      if (_db.supported) {
        await _db.upsertLandmarks(list);
      }
      setState(() => _items = list);
    } catch (_) {
      if (_db.supported) {
        final cached = await _db.getAll();
        setState(() => _items = cached);
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Map<String, dynamic> _tileForStyle(MapStyle style) {
    switch (style) {
      case MapStyle.terrain:
        return {
          'url': 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
          'subs': const ['a', 'b', 'c']
        };
      case MapStyle.light:
        return {
          'url': 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          'subs': const ['a', 'b', 'c', 'd']
        };
      case MapStyle.standard:
      default:
        return {
          'url': 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          'subs': const ['a', 'b', 'c']
        };
    }
  }

  Future<void> _locateMe() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Enable location services');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final target = LatLng(pos.latitude, pos.longitude);
      setState(() => _center = target);
      _controller.move(target, 13);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Centered on your location')));
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Location error'),
            content: Text(e.toString()),
            actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final tile = _tileForStyle(_style);
    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(center: _center, zoom: 6.5),
          children: [
            TileLayer(
              urlTemplate: tile['url'] as String,
              subdomains: (tile['subs'] as List<String>),
              userAgentPackageName: 'bd.landmarks.app',
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 45,
                size: const Size(40, 40),
                anchor: AnchorPos.align(AnchorAlign.center),
                fitBoundsOptions: const FitBoundsOptions(padding: EdgeInsets.all(50)),
                markers: _items.map((e) {
                  return Marker(
                    point: LatLng(e.lat, e.lon),
                    width: 50,
                    height: 50,
                    builder: (ctx) => GestureDetector(
                      onTap: () => _showBottomSheet(e),
                      child: e.imageUrl != null
                          ? CircleAvatar(backgroundImage: NetworkImage(e.imageUrl!), radius: 20)
                          : const Icon(Icons.location_on, size: 32, color: Colors.red),
                    ),
                  );
                }).toList(),
                builder: (context, markers) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.blue.shade700, shape: BoxShape.circle),
                    child: Text('${markers.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 12,
          bottom: 24,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'locate_me',
                mini: true,
                onPressed: _locating ? null : _locateMe,
                child: _locating ? const CircularProgressIndicator(strokeWidth: 2) : const Icon(Icons.my_location),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'style_btn',
                mini: true,
                onPressed: () async {
                  final chosen = await showModalBottomSheet<MapStyle>(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(title: const Text('Standard'), onTap: () => Navigator.of(ctx).pop(MapStyle.standard)),
                          ListTile(title: const Text('Terrain'), onTap: () => Navigator.of(ctx).pop(MapStyle.terrain)),
                          ListTile(title: const Text('Light'), onTap: () => Navigator.of(ctx).pop(MapStyle.light)),
                        ],
                      ),
                    ),
                  );
                  if (chosen != null && mounted) {
                    setState(() => _style = chosen);
                  }
                },
                child: const Icon(Icons.layers),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(Landmark e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(height: 4, width: 40, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
          ),
          Text(e.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (e.imageUrl != null)
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(e.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('Lat: ${e.lat.toStringAsFixed(5)}', style: Theme.of(context).textTheme.bodyMedium)),
            Expanded(child: Text('Lon: ${e.lon.toStringAsFixed(5)}', style: Theme.of(context).textTheme.bodyMedium)),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton.icon(onPressed: () async { Navigator.of(context).pop(); await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewEntryScreen(landmark: e))); _load(); }, icon: const Icon(Icons.edit), label: const Text('Edit')),
            const SizedBox(width: 8),
            ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(context: context, builder: (dCtx) => AlertDialog(title: const Text('Confirm'), content: const Text('Delete this landmark?'), actions: [TextButton(onPressed: () => Navigator.of(dCtx).pop(false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.of(dCtx).pop(true), child: const Text('Delete'))]));
                  if (confirm == true && e.id != null) {
                    final ok = await _api.delete(e.id!);
                    if (ok) {
                      if (_db.supported) {
                        await _db.delete(e.id!);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
                      Navigator.of(context).pop();
                      _load();
                    } else {
                      showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Error'), content: const Text('Failed to delete'), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))]));
                    }
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete')),
          ])
        ]),
      ),
    );
  }
}
