import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  static Future<File> resizeToFile(File input, int width, int height) async {
    if (kIsWeb) return input;
    final bytes = await input.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return input;
    final resized = img.copyResize(image, width: width, height: height);
    final out = await input.writeAsBytes(img.encodeJpg(resized, quality: 85));
    return out;
  }
}
