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

  static const String _baseFeedUrl =
      'https://appstaki.blogspot.com/feeds/posts/default';

  final http.Client _client;

  Future<List<BlogImage>> fetchWallpapers() async {
    const pageSize = 100;
    var startIndex = 1;
    final images = <BlogImage>[];

    try {
      while (true) {
        final response = await _client.get(
          _buildFeedUri(maxResults: pageSize, startIndex: startIndex),
        );
        if (response.statusCode != 200) {
          throw WallpapersException(
            'فشل في جلب الخلفيات (رمز الاستجابة: ${response.statusCode})',
          );
        }

        final page = _parseFeed(response.body);
        images.addAll(page.images);

        if (page.entryCount < pageSize) {
          break;
        }

        startIndex += pageSize;
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

  Uri _buildFeedUri({required int maxResults, required int startIndex}) {
    return Uri.parse(_baseFeedUrl).replace(
      queryParameters: {
        'alt': 'atom',
        'max-results': '$maxResults',
        'start-index': '$startIndex',
      },
    );
  }

  ({List<BlogImage> images, int entryCount}) _parseFeed(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final entries = document.findAllElements('entry').toList();

    final images = <BlogImage>[];

    for (final entry in entries) {
      final title = entry.getElement('title')?.innerText ?? 'بدون عنوان';
      final content = entry.getElement('content')?.innerText ?? '';

      final match = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(content);
      if (match != null) {
        images.add(BlogImage(title: title, imageUrl: match.group(1)!));
      }
    }

    return (images: images, entryCount: entries.length);
  }
}
