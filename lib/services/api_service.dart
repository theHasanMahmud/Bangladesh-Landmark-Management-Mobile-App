import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../models/landmark.dart';

class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  final http.Client _client;
  ApiService([http.Client? client]) : _client = client ?? http.Client();

  Future<List<Landmark>> fetchAll() async {
    final resp = await _client.get(Uri.parse(baseUrl));
    if (resp.statusCode == 200) {
      final list = json.decode(resp.body) as List<dynamic>;
      return list.map((e) => Landmark.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw HttpException('Failed to fetch landmarks: ${resp.statusCode}');
  }

  Future<int> create(Landmark landmark, {File? imageFile}) async {
    var uri = Uri.parse(baseUrl);
    var request = http.MultipartRequest('POST', uri);
    request.fields['title'] = landmark.title;
    request.fields['lat'] = landmark.lat.toString();
    request.fields['lon'] = landmark.lon.toString();
    if (imageFile != null && await imageFile.exists()) {
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipart = http.MultipartFile('image', stream, length, filename: p.basename(imageFile.path));
      request.files.add(multipart);
    }
    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 200) {
      final body = json.decode(resp.body);
      if (body is Map && body['id'] != null) {
        return body['id'] is String ? int.parse(body['id']) : body['id'];
      }
      throw const HttpException('Invalid response creating entity');
    }
    throw HttpException('Failed to create: ${resp.statusCode} ${resp.reasonPhrase}');
  }

  Future<bool> update(Landmark landmark, {File? imageFile}) async {
    // The API expects a PUT with x-www-form-urlencoded or multipart when image included.
    final uri = Uri.parse(baseUrl);
    if (imageFile != null && await imageFile.exists()) {
      var request = http.MultipartRequest('PUT', uri);
      request.fields['id'] = landmark.id.toString();
      request.fields['title'] = landmark.title;
      request.fields['lat'] = landmark.lat.toString();
      request.fields['lon'] = landmark.lon.toString();
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      request.files.add(http.MultipartFile('image', stream, length, filename: p.basename(imageFile.path)));
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      return resp.statusCode == 200;
    } else {
      // send as x-www-form-urlencoded via PUT
      final resp = await _client.put(uri, headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: {
        'id': landmark.id.toString(),
        'title': landmark.title,
        'lat': landmark.lat.toString(),
        'lon': landmark.lon.toString(),
      });
      return resp.statusCode == 200;
    }
  }

  Future<bool> delete(int id) async {
    final uri = Uri.parse(baseUrl);
    final resp = await _client.delete(uri.replace(queryParameters: {'id': id.toString()}));
    return resp.statusCode == 200;
  }
}
