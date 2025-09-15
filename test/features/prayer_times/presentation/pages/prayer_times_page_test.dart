import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:afasi/core/di/injection.dart';
import 'package:afasi/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:afasi/features/prayer_times/presentation/pages/prayer_times_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPrayerTimesCubit extends Mock implements PrayerTimesCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('PrayerTimesPage renders times and handles user interactions',
      (tester) async {
    final mockCubit = MockPrayerTimesCubit();
    final controller = StreamController<PrayerTimesState>.broadcast();
    addTearDown(() => controller.close());

    final coordinates = Coordinates(24.7136, 46.6753);
    final params = CalculationMethod.egyptian.getParameters()
      ..madhab = Madhab.hanafi;
    final date = DateComponents(2024, 1, 1);
    final prayerTimes = PrayerTimes(coordinates, date, params);

    final initialState = PrayerTimesState(
      prayerTimes: prayerTimes,
      notificationsEnabled: false,
      isLoading: false,
    );

    when(() => mockCubit.state).thenReturn(initialState);
    when(() => mockCubit.stream).thenAnswer((_) => controller.stream);
    when(() => mockCubit.initialize()).thenAnswer((_) async {});
    when(() => mockCubit.refreshPrayerTimes()).thenAnswer((_) async {});
    when(() => mockCubit.toggleNotifications()).thenAnswer((_) async {});
    when(() => mockCubit.clearMessages()).thenAnswer((_) {});
    when(() => mockCubit.close()).thenAnswer((_) async {});

    getIt.registerFactory<PrayerTimesCubit>(() => mockCubit);

    await tester.pumpWidget(const MaterialApp(home: PrayerTimesPage()));
    await tester.pump();

    verify(() => mockCubit.initialize()).called(1);

    expect(find.text('أوقات الصلاة'), findsOneWidget);
    expect(find.text('الفجر'), findsOneWidget);
    expect(find.text('الشروق'), findsOneWidget);
    expect(find.text('الظهر'), findsOneWidget);
    expect(find.text('العصر'), findsOneWidget);
    expect(find.text('المغرب'), findsOneWidget);
    expect(find.text('العشاء'), findsOneWidget);
    expect(find.text('تفعيل تنبيهات الصلاة'), findsOneWidget);

    await tester.tap(find.byTooltip('تحديث الأوقات'));
    verify(() => mockCubit.refreshPrayerTimes()).called(1);

    await tester.tap(find.text('تفعيل تنبيهات الصلاة'));
    verify(() => mockCubit.toggleNotifications()).called(1);

    final successState = initialState.copyWith(
      notificationsEnabled: true,
      statusMessage: 'تم التفعيل',
    );

    controller.add(successState);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('تم التفعيل'), findsOneWidget);
    verify(() => mockCubit.clearMessages()).called(1);
  });
}
