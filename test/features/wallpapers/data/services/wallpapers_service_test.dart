import 'dart:io';

import 'package:afasi/features/wallpapers/data/services/wallpapers_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHttpClient client;
  late WallpapersService service;
  late Directory tempDir;
  late Directory documentsDir;
  late PathProviderPlatform originalPlatform;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() async {
    client = MockHttpClient();
    tempDir = await Directory.systemTemp.createTemp('wallpapers_temp_');
    documentsDir = await Directory.systemTemp.createTemp('wallpapers_docs_');
    originalPlatform = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _TestPathProviderPlatform(
      temporaryPath: tempDir.path,
      applicationDocumentsPath: documentsDir.path,
    );
    service = WallpapersService(client: client);
  });

  tearDown(() async {
    PathProviderPlatform.instance = originalPlatform;
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    if (await documentsDir.exists()) {
      await documentsDir.delete(recursive: true);
    }
  });

  test('fetchWallpapers returns parsed images', () async {
    const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<feed>
  <entry>
    <title>صورة 1</title>
    <content type="html"><![CDATA[<img src="https://example.com/1.jpg"/>]]></content>
  </entry>
  <entry>
    <title>صورة 2</title>
    <content type="html"><![CDATA[<img src="https://example.com/2.jpg"/>]]></content>
  </entry>
</feed>
''';

    when(() => client.get(any())).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.first as Uri;
      expect(uri.queryParameters['max-results'], '100');
      expect(uri.queryParameters['start-index'], '1');
      return http.Response(xml, 200);
    });

    final images = await service.fetchWallpapers();

    expect(images, hasLength(2));
    expect(images.first.title, 'صورة 1');
    expect(images.first.imageUrl, 'https://example.com/1.jpg');
  });

  test('fetchWallpapers combines multiple pages until fewer than page size',
      () async {
    final firstPageXml = _buildFeedXml(100, start: 1);
    final secondPageXml = _buildFeedXml(60, start: 101);

    var callCount = 0;
    when(() => client.get(any())).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.first as Uri;
      callCount++;
      switch (callCount) {
        case 1:
          expect(uri.queryParameters['start-index'], '1');
          expect(uri.queryParameters['max-results'], '100');
          return http.Response(firstPageXml, 200);
        case 2:
          expect(uri.queryParameters['start-index'], '101');
          expect(uri.queryParameters['max-results'], '100');
          return http.Response(secondPageXml, 200);
        default:
          fail('Unexpected additional request: $uri');
      }
    });

    final images = await service.fetchWallpapers();

    expect(callCount, 2);
    expect(images, hasLength(160));
    expect(images.first.title, 'صورة 1');
    expect(images.last.title, 'صورة 160');
    expect(images.last.imageUrl, 'https://example.com/160.jpg');
  });

  test('fetchWallpapers throws when response code is not 200', () async {
    when(() => client.get(any())).thenAnswer(
      (_) async => http.Response('Error', 500),
    );

    expect(
      () => service.fetchWallpapers(),
      throwsA(
        isA<WallpapersException>().having(
          (e) => e.message,
          'message',
          contains('500'),
        ),
      ),
    );
  });

  test('fetchWallpapers wraps parsing errors inside WallpapersException',
      () async {
    when(() => client.get(any())).thenAnswer(
      (_) async => http.Response('<not><valid></xml>', 200),
    );

    expect(
      () => service.fetchWallpapers(),
      throwsA(
        isA<WallpapersException>().having(
          (e) => e.message,
          'message',
          contains('تعذر معالجة بيانات الخلفيات'),
        ),
      ),
    );
  });

  test('downloadImageBytes returns response bytes', () async {
    final bytes = <int>[1, 2, 3];
    when(() => client.get(any())).thenAnswer(
      (_) async => http.Response.bytes(bytes, 200),
    );

    final result =
        await service.downloadImageBytes('https://example.com/image.jpg');

    expect(result, equals(bytes));
  });

  test('downloadImageBytes throws WallpapersException on non-200 response',
      () async {
    when(() => client.get(any())).thenAnswer(
      (_) async => http.Response('Not Found', 404),
    );

    expect(
      () => service.downloadImageBytes('https://example.com/image.jpg'),
      throwsA(
        isA<WallpapersException>().having(
          (e) => e.message,
          'message',
          contains('404'),
        ),
      ),
    );
  });

  test('fetchWallpapers returns cached data when network fails', () async {
    when(() => client.get(any()))
        .thenAnswer(
          (_) async => http.Response(
            _buildFeedXml(1, start: 1),
            200,
          ),
        )
        .thenThrow(Exception('network'));

    final initialImages = await service.fetchWallpapers();
    expect(initialImages, isNotEmpty);

    final cachedImages = await service.fetchWallpapers();
    expect(cachedImages, isNotEmpty);
    expect(cachedImages.first.imageUrl, initialImages.first.imageUrl);
  });

  test('downloadImageBytes reuses cached file when available', () async {
    final bytes = <int>[1, 2, 3, 4];
    when(() => client.get(any())).thenAnswer(
      (_) async => http.Response.bytes(bytes, 200),
    );

    final firstDownload =
        await service.downloadImageBytes('https://example.com/image.jpg');
    expect(firstDownload, equals(bytes));

    when(() => client.get(any())).thenThrow(Exception('should not fetch'));

    final cachedDownload =
        await service.downloadImageBytes('https://example.com/image.jpg');
    expect(cachedDownload, equals(bytes));
  });
}

String _buildFeedXml(int count, {required int start}) {
  final buffer = StringBuffer(
    '<?xml version="1.0" encoding="UTF-8"?>\n<feed>\n',
  );

  for (var index = 0; index < count; index++) {
    final itemIndex = start + index;
    buffer
      ..writeln('  <entry>')
      ..writeln('    <title>صورة $itemIndex</title>')
      ..writeln(
        '    <content type="html"><![CDATA[<img src="https://example.com/$itemIndex.jpg"/>]]></content>',
      )
      ..writeln('  </entry>');
  }

  buffer.write('</feed>');
  return buffer.toString();
}

class _TestPathProviderPlatform extends PathProviderPlatform {
  _TestPathProviderPlatform({
    required this.temporaryPath,
    required this.applicationDocumentsPath,
  });

  final String temporaryPath;
  final String applicationDocumentsPath;

  @override
  Future<String?> getTemporaryPath() async => temporaryPath;

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      applicationDocumentsPath;
}
