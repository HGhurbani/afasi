import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/blog_image.dart';

class WallpapersException implements Exception {
  const WallpapersException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WallpapersService {
  WallpapersService({http.Client? client}) : _client = client ?? http.Client();

  static const String _feedUrl =
      'https://appstaki.blogspot.com/feeds/posts/default?alt=atom&max-results=100';

  final http.Client _client;

  Future<List<BlogImage>> fetchWallpapers() async {
    try {
      final response = await _client.get(Uri.parse(_feedUrl));
      if (response.statusCode != 200) {
        throw WallpapersException(
          'فشل في جلب الخلفيات (رمز الاستجابة: ${response.statusCode})',
        );
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
    } on WallpapersException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        WallpapersException('تعذر معالجة بيانات الخلفيات: $error'),
        stackTrace,
      );
    }
  }

  Future<Uint8List> downloadImageBytes(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw WallpapersException('فشل تحميل الصورة (${response.statusCode})');
    }
    return response.bodyBytes;
  }
}
