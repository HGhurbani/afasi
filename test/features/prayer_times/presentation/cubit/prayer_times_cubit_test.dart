import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:afasi/features/prayer_times/data/repositories/prayer_times_repository.dart';
import 'package:afasi/features/prayer_times/data/services/prayer_notification_service.dart';
import 'package:afasi/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPrayerTimesRepository extends Mock implements PrayerTimesRepository {}

class MockPrayerNotificationService extends Mock
    implements PrayerNotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockPrayerTimesRepository repository;
  late MockPrayerNotificationService notificationService;
  late PrayerTimesCubit cubit;
  late PrayerTimes testPrayerTimes;
  late List<PrayerTimesState> emittedStates;
  StreamSubscription<PrayerTimesState>? subscription;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = MockPrayerTimesRepository();
    notificationService = MockPrayerNotificationService();

    final coordinates = Coordinates(29.3759, 47.9774);
    final params = CalculationMethod.egyptian.getParameters()
      ..madhab = Madhab.hanafi;
    final date = DateComponents(2024, 1, 1);
    testPrayerTimes = PrayerTimes(coordinates, date, params);

    when(() => repository.fetchPrayerTimes())
        .thenAnswer((_) async => testPrayerTimes);
    when(() => notificationService.initialize()).thenAnswer((_) async {});
    when(() =>
            notificationService.schedulePrayerNotifications(testPrayerTimes))
        .thenAnswer((_) async {});
    when(() => notificationService.cancelAll()).thenAnswer((_) async {});

    cubit = PrayerTimesCubit(
      prayerTimesRepository: repository,
      notificationService: notificationService,
    );

    emittedStates = [];
    subscription = cubit.stream.listen(emittedStates.add);
  });

  tearDown(() async {
    await subscription?.cancel();
    await cubit.close();
  });

  test('initialize loads prayer times with notifications disabled by default',
      () async {
    await cubit.initialize();

    expect(emittedStates.length, 2);
    expect(emittedStates.first.isLoading, isTrue);
    expect(emittedStates.first.errorMessage, isNull);

    final loadedState = emittedStates.last;
    expect(loadedState.prayerTimes, same(testPrayerTimes));
    expect(loadedState.notificationsEnabled, isFalse);
    expect(loadedState.isLoading, isFalse);
    expect(loadedState.errorMessage, isNull);

    verify(() => notificationService.initialize()).called(1);
    verify(() => repository.fetchPrayerTimes()).called(1);
    verifyNever(() =>
        notificationService.schedulePrayerNotifications(testPrayerTimes));
  });

  test('initialize schedules notifications when preference is enabled',
      () async {
    SharedPreferences.setMockInitialValues({
      'notificationsScheduled': true,
    });

    await cubit.initialize();

    final loadedState = emittedStates.last;
    expect(loadedState.notificationsEnabled, isTrue);
    verify(() =>
            notificationService.schedulePrayerNotifications(testPrayerTimes))
        .called(1);
  });

  test('toggleNotifications schedules notifications when enabling', () async {
    await cubit.initialize();
    emittedStates.clear();

    await cubit.toggleNotifications();

    expect(emittedStates.length, 1);
    final toggledState = emittedStates.last;
    expect(toggledState.notificationsEnabled, isTrue);
    expect(toggledState.statusMessage, 'تم جدولة تنبيهات الصلاة بنجاح.');
    expect(toggledState.errorMessage, isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('notificationsScheduled'), isTrue);
    verify(() =>
            notificationService.schedulePrayerNotifications(testPrayerTimes))
        .called(1);
  });

  test('toggleNotifications cancels scheduled notifications when disabling',
      () async {
    SharedPreferences.setMockInitialValues({
      'notificationsScheduled': true,
    });

    await cubit.initialize();
    emittedStates.clear();

    await cubit.toggleNotifications();

    expect(emittedStates.length, 1);
    final toggledState = emittedStates.last;
    expect(toggledState.notificationsEnabled, isFalse);
    expect(toggledState.statusMessage, 'تم إلغاء تنبيهات الصلاة.');
    expect(toggledState.errorMessage, isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('notificationsScheduled'), isFalse);
    verify(() => notificationService.cancelAll()).called(1);
  });

  test('toggleNotifications emits error when prayer times are missing',
      () async {
    await cubit.toggleNotifications();

    expect(emittedStates.length, 1);
    final errorState = emittedStates.single;
    expect(errorState.errorMessage,
        'لا يمكن جدولة التنبيهات قبل تحميل أوقات الصلاة.');
    expect(errorState.notificationsEnabled, isFalse);
  });

  test('refreshPrayerTimes reloads times and schedules notifications when enabled',
      () async {
    SharedPreferences.setMockInitialValues({
      'notificationsScheduled': true,
    });

    await cubit.initialize();
    emittedStates.clear();

    final updatedCoordinates = Coordinates(21.3891, 39.8579);
    final updatedParams = CalculationMethod.egyptian.getParameters()
      ..madhab = Madhab.hanafi;
    final updatedDate = DateComponents(2024, 2, 1);
    final updatedTimes = PrayerTimes(updatedCoordinates, updatedDate, updatedParams);

    when(() => repository.fetchPrayerTimes())
        .thenAnswer((_) async => updatedTimes);
    when(() =>
            notificationService.schedulePrayerNotifications(updatedTimes))
        .thenAnswer((_) async {});

    await cubit.refreshPrayerTimes();

    expect(emittedStates.length, 2);
    final loadingState = emittedStates.first;
    expect(loadingState.isLoading, isTrue);
    expect(loadingState.errorMessage, isNull);

    final refreshedState = emittedStates.last;
    expect(refreshedState.prayerTimes, same(updatedTimes));
    expect(refreshedState.notificationsEnabled, isTrue);
    expect(refreshedState.isLoading, isFalse);
    expect(refreshedState.errorMessage, isNull);

    verify(() => repository.fetchPrayerTimes()).called(2);
    verify(() =>
            notificationService.schedulePrayerNotifications(updatedTimes))
        .called(1);
  });

  test('refreshPrayerTimes emits failure state when repository throws', () async {
    when(() => repository.fetchPrayerTimes())
        .thenThrow(Exception('فشل تحميل الأوقات'));

    await cubit.refreshPrayerTimes();

    expect(emittedStates.length, 2);
    final loadingState = emittedStates.first;
    expect(loadingState.isLoading, isTrue);
    expect(loadingState.errorMessage, isNull);

    final failureState = emittedStates.last;
    expect(failureState.isLoading, isFalse);
    expect(failureState.prayerTimes, isNull);
    expect(failureState.errorMessage, 'Exception: فشل تحميل الأوقات');
  });
}
