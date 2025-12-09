class Landmark {
  final int? id;
  final String title;
  final double lat;
  final double lon;
  final String? imageUrl; // remote URL

  Landmark({this.id, required this.title, required this.lat, required this.lon, this.imageUrl});

  factory Landmark.fromJson(Map<String, dynamic> json) {
    return Landmark(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      title: json['title'] ?? '',
      lat: (json['lat'] is String) ? double.tryParse(json['lat']) ?? 0.0 : (json['lat'] ?? 0.0).toDouble(),
      lon: (json['lon'] is String) ? double.tryParse(json['lon']) ?? 0.0 : (json['lon'] ?? 0.0).toDouble(),
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
