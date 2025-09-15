import 'package:afasi/features/wallpapers/cubit/wallpapers_cubit.dart';
import 'package:afasi/features/wallpapers/data/models/blog_image.dart';
import 'package:afasi/features/wallpapers/presentation/pages/wallpapers_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWallpapersCubit extends Mock implements WallpapersCubit {}

void main() {
  late MockWallpapersCubit cubit;

  setUp(() {
    cubit = MockWallpapersCubit();
    when(() => cubit.close()).thenAnswer((_) async {});
  });

  Widget buildWidget() {
    return MaterialApp(
      home: BlocProvider<WallpapersCubit>.value(
        value: cubit,
        child: const WallpapersPage(),
      ),
    );
  }

  testWidgets('shows loading indicator when state is loading', (tester) async {
    when(() => cubit.state).thenReturn(
      const WallpapersState(status: WallpapersStatus.loading),
    );
    when(() => cubit.stream).thenAnswer(
      (_) => Stream<WallpapersState>.empty(),
    );

    await tester.pumpWidget(buildWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message when state is failure', (tester) async {
    when(() => cubit.state).thenReturn(
      const WallpapersState(
        status: WallpapersStatus.failure,
        errorMessage: 'خطأ',
      ),
    );
    when(() => cubit.stream).thenAnswer(
      (_) => Stream<WallpapersState>.empty(),
    );

    await tester.pumpWidget(buildWidget());

    expect(find.text('خطأ'), findsOneWidget);
  });

  testWidgets('shows grid when images are available', (tester) async {
    final images = [
      BlogImage(title: 'صورة 1', imageUrl: 'https://example.com/1.jpg'),
    ];

    when(() => cubit.state).thenReturn(
      WallpapersState(
        status: WallpapersStatus.success,
        images: images,
      ),
    );
    when(() => cubit.stream).thenAnswer(
      (_) => Stream<WallpapersState>.empty(),
    );

    await tester.pumpWidget(buildWidget());

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });
}
