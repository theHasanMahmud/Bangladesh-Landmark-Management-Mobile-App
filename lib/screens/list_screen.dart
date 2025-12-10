import 'package:flutter/material.dart';

import '../models/landmark.dart';
import '../screens/new_entry_screen.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import '../widgets/landmark_card.dart';

class ListScreen extends StatefulWidget {
  final bool embedded;
  const ListScreen({super.key, this.embedded = false});

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
      list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      if (_db.supported) {
        await _db.upsertLandmarks(list);
      }
      setState(() => _items = list);
    } catch (_) {
      if (_db.supported) {
        final cached = await _db.getAll();
        cached.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
        setState(() => _items = cached);
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (ctx, i) => Dismissible(
                key: ValueKey(_items[i].id ?? i),
                background: Container(color: Colors.green, alignment: Alignment.centerLeft, child: const Padding(padding: EdgeInsets.only(left: 16.0), child: Icon(Icons.edit, color: Colors.white))),
                secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, child: const Padding(padding: EdgeInsets.only(right: 16.0), child: Icon(Icons.delete, color: Colors.white))),
                onDismissed: (direction) async {
                  final item = _items[i];
                  if (direction == DismissDirection.endToStart) {
                    await _api.delete(item.id!);
                    if (_db.supported) {
                      await _db.delete(item.id!);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
                  } else {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewEntryScreen(landmark: item)));
                  }
                  _load();
                },
                child: LandmarkCard(landmark: _items[i]),
              ),
            ),
          );

    if (widget.embedded) return content;

    return Scaffold(appBar: AppBar(title: const Text('Landmark Records')), body: content);
  }
}
