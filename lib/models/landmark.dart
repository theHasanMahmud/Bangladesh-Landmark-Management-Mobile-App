class Landmark {
  final int? id;
  final String title;
  final double lat;
  final double lon;
  final String? imageUrl; // remote URL

  Landmark({this.id, required this.title, required this.lat, required this.lon, this.imageUrl});

  static const double _defaultLat = 23.6850;
  static const double _defaultLon = 90.3563;

  factory Landmark.fromJson(Map<String, dynamic> json) {
    double parseCoord(dynamic value, double min, double max, double fallback) {
      final parsed = (value is String) ? double.tryParse(value) : (value is num ? value.toDouble() : null);
      if (parsed == null || !parsed.isFinite) return fallback;
      return parsed.clamp(min, max).toDouble();
    }

    return Landmark(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      title: json['title'] ?? '',
      lat: parseCoord(json['lat'], -90, 90, _defaultLat),
      lon: parseCoord(json['lon'], -180, 180, _defaultLon),
      imageUrl: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'lat': lat,
        'lon': lon,
        'image': imageUrl,
      };
}
