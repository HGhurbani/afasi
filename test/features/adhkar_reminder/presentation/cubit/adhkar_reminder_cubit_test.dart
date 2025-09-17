import 'dart:async';

import 'package:afasi/features/adhkar_reminder/data/services/adhkar_reminder_service.dart';
import 'package:afasi/features/adhkar_reminder/presentation/cubit/adhkar_reminder_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAdhkarReminderService extends Mock
    implements AdhkarReminderService {}

class TestAdhkarReminderCubit extends AdhkarReminderCubit {
  TestAdhkarReminderCubit({required AdhkarReminderService service})
      : super(service: service);

  void emitTestState(AdhkarReminderState newState) => emit(newState);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const TimeOfDay(hour: 0, minute: 0));
  });

  late MockAdhkarReminderService service;
  late TestAdhkarReminderCubit cubit;
  late List<AdhkarReminderState> emittedStates;
  StreamSubscription<AdhkarReminderState>? subscription;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = MockAdhkarReminderService();

    when(() => service.scheduleDailyReminder(
          id: any(named: 'id'),
          timeOfDay: any(named: 'timeOfDay'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          sound: any(named: 'sound'),
          channelId: any(named: 'channelId'),
          channelName: any(named: 'channelName'),
          channelDescription: any(named: 'channelDescription'),
        )).thenAnswer((_) async {});
    when(() => service.cancelReminder(
          any(),
          channelId: any(named: 'channelId'),
        )).thenAnswer((_) async {});

    cubit = TestAdhkarReminderCubit(service: service);
    emittedStates = [];
    subscription = cubit.stream.listen(emittedStates.add);
  });

  tearDown(() async {
    await subscription?.cancel();
    await cubit.close();
  });

  test('toggleMorning enables reminder and schedules notification', () async {
    await cubit.toggleMorning(true);

    expect(emittedStates.length, 2);

    final toggledState = emittedStates.first;
    expect(toggledState.morningEnabled, isTrue);
    expect(toggledState.statusMessage, isNull);

    final statusState = emittedStates.last;
    expect(statusState.morningEnabled, isTrue);
    expect(statusState.statusMessage, 'تم تفعيل تذكير أذكار الصباح');
    expect(statusState.errorMessage, isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('morningEnabled'), isTrue);

    verify(() => service.scheduleDailyReminder(
          id: 100,
          timeOfDay: const TimeOfDay(hour: 6, minute: 0),
          title: any(named: 'title'),
          body: any(named: 'body'),
          sound: any(named: 'sound'),
          channelId: 'adhkar_morning_channel',
          channelName: 'قناة أذكار الصباح',
          channelDescription: 'تنبيهات يومية لأذكار الصباح',
        )).called(1);
  });

  test('toggleMorning disables reminder and cancels scheduled notification',
      () async {
    cubit.emitTestState(const AdhkarReminderState(morningEnabled: true));
    emittedStates.clear();

    await cubit.toggleMorning(false);

    expect(emittedStates.length, 2);

    final toggledState = emittedStates.first;
    expect(toggledState.morningEnabled, isFalse);
    expect(toggledState.statusMessage, isNull);

    final statusState = emittedStates.last;
    expect(statusState.morningEnabled, isFalse);
    expect(statusState.statusMessage, 'تم تعطيل تذكير أذكار الصباح');
    expect(statusState.errorMessage, isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('morningEnabled'), isFalse);

    verify(() => service.cancelReminder(
          100,
          channelId: 'adhkar_morning_channel',
        )).called(1);
  });

  test('toggleEvening enables reminder and schedules notification', () async {
    await cubit.toggleEvening(true);

    expect(emittedStates.length, 2);

    final toggledState = emittedStates.first;
    expect(toggledState.eveningEnabled, isTrue);
    expect(toggledState.statusMessage, isNull);

    final statusState = emittedStates.last;
    expect(statusState.eveningEnabled, isTrue);
    expect(statusState.statusMessage, 'تم تفعيل تذكير أذكار المساء');
    expect(statusState.errorMessage, isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('eveningEnabled'), isTrue);

    verify(() => service.scheduleDailyReminder(
          id: 101,
          timeOfDay: const TimeOfDay(hour: 18, minute: 0),
          title: any(named: 'title'),
          body: any(named: 'body'),
          sound: any(named: 'sound'),
          channelId: 'adhkar_evening_channel',
          channelName: 'قناة أذكار المساء',
          channelDescription: 'تنبيهات يومية لأذكار المساء',
        )).called(1);
  });

  test('updateMorningTime reschedules reminder when enabled', () async {
    await cubit.toggleMorning(true);
    emittedStates.clear();

    const newTime = TimeOfDay(hour: 7, minute: 30);
    await cubit.updateMorningTime(newTime);

    expect(emittedStates.length, 2);

    final updatedState = emittedStates.first;
    expect(updatedState.morningTime, newTime);
    expect(updatedState.statusMessage, isNull);

    final statusState = emittedStates.last;
    expect(statusState.morningTime, newTime);
    expect(statusState.statusMessage, 'تم تحديث وقت تذكير أذكار الصباح');
    expect(statusState.errorMessage, isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('morningHour'), newTime.hour);
    expect(prefs.getInt('morningMinute'), newTime.minute);

    verify(() => service.scheduleDailyReminder(
          id: 100,
          timeOfDay: newTime,
          title: any(named: 'title'),
          body: any(named: 'body'),
          sound: any(named: 'sound'),
          channelId: 'adhkar_morning_channel',
          channelName: 'قناة أذكار الصباح',
          channelDescription: 'تنبيهات يومية لأذكار الصباح',
        )).called(1);
  });
}
