import 'package:flutter/material.dart';
import '../models/landmark.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import '../widgets/landmark_card.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Landmark Records')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (ctx, i) => Dismissible(
                  key: ValueKey(_items[i].id ?? i),
                  background: Container(color: Colors.green, alignment: Alignment.centerLeft, child: const Padding(padding: EdgeInsets.only(left:16.0), child: Icon(Icons.edit, color: Colors.white))),
                  secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, child: const Padding(padding: EdgeInsets.only(right:16.0), child: Icon(Icons.delete, color: Colors.white))),
                  onDismissed: (direction) async {
                    final item = _items[i];
                    if (direction == DismissDirection.endToStart) {
                      await _api.delete(item.id!);
                      await _db.delete(item.id!);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
                    } else {
                      // Edit: navigate to form (not implemented) — open NewEntryScreen with data
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit not implemented')));
                    }
                    _load();
                  },
                  child: LandmarkCard(landmark: _items[i]),
                ),
              ),
            ),
    );
  }
}
