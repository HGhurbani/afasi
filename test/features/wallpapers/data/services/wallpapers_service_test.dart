import 'package:afasi/features/wallpapers/data/services/wallpapers_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient client;
  late WallpapersService service;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    client = MockHttpClient();
    service = WallpapersService(client: client);
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

    when(() => client.get(any())).thenAnswer(
      (_) async => http.Response(xml, 200),
    );

    final images = await service.fetchWallpapers();

    expect(images, hasLength(2));
    expect(images.first.title, 'صورة 1');
    expect(images.first.imageUrl, 'https://example.com/1.jpg');
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
}
