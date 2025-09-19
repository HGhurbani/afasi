import 'package:afasi/features/wallpapers/cubit/wallpapers_cubit.dart';
import 'package:afasi/features/wallpapers/data/models/blog_image.dart';
import 'package:afasi/features/wallpapers/data/services/wallpapers_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWallpapersService extends Mock implements WallpapersService {}

void main() {
  late MockWallpapersService service;
  late WallpapersCubit cubit;

  setUp(() {
    service = MockWallpapersService();
    cubit = WallpapersCubit(service: service);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('loadWallpapers emits loading then success state', () async {
    final images = List.generate(
      150,
      (index) => BlogImage(
        title: 'صورة ${index + 1}',
        imageUrl: 'https://example.com/${index + 1}.jpg',
      ),
    );

    when(() => service.fetchWallpapers()).thenAnswer((_) async => images);

    expectLater(
      cubit.stream,
      emitsInOrder([
        const WallpapersState(status: WallpapersStatus.loading),
        WallpapersState(
          status: WallpapersStatus.success,
          images: images,
        ),
      ]),
    );

    await cubit.loadWallpapers();
  });

  test('loadWallpapers emits failure when service throws WallpapersException',
      () async {
    when(() => service.fetchWallpapers())
        .thenThrow(const WallpapersException('خطأ'));

    expectLater(
      cubit.stream,
      emitsInOrder([
        const WallpapersState(status: WallpapersStatus.loading),
        const WallpapersState(
          status: WallpapersStatus.failure,
          errorMessage: 'خطأ',
        ),
      ]),
    );

    await cubit.loadWallpapers();
  });

  test('loadWallpapers emits generic message for unexpected errors', () async {
    when(() => service.fetchWallpapers()).thenThrow(Exception('خطأ')); 

    expectLater(
      cubit.stream,
      emitsInOrder([
        const WallpapersState(status: WallpapersStatus.loading),
        const WallpapersState(
          status: WallpapersStatus.failure,
          errorMessage: 'تعذر تحميل الخلفيات. الرجاء المحاولة لاحقاً.',
        ),
      ]),
    );

    await cubit.loadWallpapers();
  });
}
