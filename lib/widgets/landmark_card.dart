import 'package:flutter/material.dart';
import '../models/landmark.dart';

class LandmarkCard extends StatelessWidget {
  final Landmark landmark;
  const LandmarkCard({super.key, required this.landmark});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: landmark.imageUrl != null
            ? Image.network(landmark.imageUrl!, width: 56, height: 56, fit: BoxFit.cover)
            : const Icon(Icons.place, size: 48),
        title: Text(landmark.title),
        subtitle: Text('Lat: ${landmark.lat.toStringAsFixed(4)}, Lon: ${landmark.lon.toStringAsFixed(4)}'),
      ),
    );
  }
}
