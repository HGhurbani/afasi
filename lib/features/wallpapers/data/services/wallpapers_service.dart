import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/blog_image.dart';

class WallpapersService {
  WallpapersService({http.Client? client}) : _client = client ?? http.Client();

  static const String _feedUrl =
      'https://appstaki.blogspot.com/feeds/posts/default?alt=atom&max-results=100';

  final http.Client _client;

  Future<List<BlogImage>> fetchWallpapers() async {
    final response = await _client.get(Uri.parse(_feedUrl));
    if (response.statusCode != 200) {
      throw Exception('فشل في جلب الصور (${response.statusCode})');
    }

    final document = XmlDocument.parse(response.body);
    final entries = document.findAllElements('entry');

    final images = <BlogImage>[];

    for (final entry in entries) {
      final title = entry.getElement('title')?.innerText ?? 'بدون عنوان';
      final content = entry.getElement('content')?.innerText ?? '';

      final match = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(content);
      if (match != null) {
        images.add(BlogImage(title: title, imageUrl: match.group(1)!));
      }
    }

    return images;
  }

  Future<Uint8List> downloadImageBytes(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('فشل تحميل الصورة (${response.statusCode})');
    }
    return response.bodyBytes;
  }
}
