import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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
  static const String _cacheFileName = 'wallpapers_cache.json';
  static const String _imageCacheFolderName = 'wallpapers_images';

  final http.Client _client;

  Future<List<BlogImage>> fetchWallpapers() async {
    final cachedImages = await loadCachedWallpapers();

    try {
      final remoteImages = await _fetchWallpapersFromNetwork();
      await _saveWallpapersToCache(remoteImages);
      return remoteImages;
    } on WallpapersException {
      if (cachedImages.isNotEmpty) {
        return cachedImages;
      }
      rethrow;
    } catch (error, stackTrace) {
      if (cachedImages.isNotEmpty) {
        return cachedImages;
      }
      Error.throwWithStackTrace(
        WallpapersException('تعذر معالجة بيانات الخلفيات: $error'),
        stackTrace,
      );
    }
  }

  Future<Uint8List> downloadImageBytes(String url) async {
    final file = await ensureImageFile(url);
    return await file.readAsBytes();
  }

  Future<File?> getCachedImageFile(String url) async {
    final file = await _getImageCacheFile(url);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<File> ensureImageFile(String url) async {
    final file = await _getImageCacheFile(url);
    if (await file.exists()) {
      return file;
    }

    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw WallpapersException('فشل تحميل الصورة (${response.statusCode})');
    }

    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file;
  }

  Future<List<BlogImage>> loadCachedWallpapers() async {
    try {
      final file = await _getCacheFile();
      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      if (jsonString.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return [];
      }

      final images = <BlogImage>[];
      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          try {
            images.add(BlogImage.fromJson(entry));
          } catch (_) {
            continue;
          }
        } else if (entry is Map) {
          try {
            images.add(BlogImage.fromJson(Map<String, dynamic>.from(entry)));
          } catch (_) {
            continue;
          }
        }
      }

      return images;
    } catch (_) {
      return [];
    }
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

  Future<List<BlogImage>> _fetchWallpapersFromNetwork() async {
    const pageSize = 100;
    var startIndex = 1;
    final images = <BlogImage>[];

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
  }

  Future<void> _saveWallpapersToCache(List<BlogImage> images) async {
    try {
      final file = await _getCacheFile();
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      final encoded = jsonEncode(images.map((image) => image.toJson()).toList());
      await file.writeAsString(encoded, flush: true);
    } catch (_) {
      // Ignored: caching failure shouldn't break the flow.
    }
  }

  Future<File> _getCacheFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_cacheFileName');
  }

  Future<File> _getImageCacheFile(String url) async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/$_imageCacheFolderName');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final fileName = base64Url.encode(utf8.encode(url)).replaceAll('=', '');
    return File('${cacheDir.path}/$fileName.jpg');
  }
}
