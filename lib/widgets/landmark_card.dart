import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/landmark.dart';

class LandmarkCard extends StatelessWidget {
  final Landmark landmark;
  const LandmarkCard({super.key, required this.landmark});

  bool get _hasValidImage => landmark.imageUrl != null && landmark.imageUrl!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: _hasValidImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: landmark.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox(width: 56, height: 56, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
                ),
              )
            : const Icon(Icons.place, size: 48),
        title: Text(landmark.title),
        subtitle: Text('Lat: ${landmark.lat.toStringAsFixed(4)}, Lon: ${landmark.lon.toStringAsFixed(4)}'),
      ),
    );
  }
}
