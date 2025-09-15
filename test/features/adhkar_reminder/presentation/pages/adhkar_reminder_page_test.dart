import 'dart:async';

import 'package:afasi/core/di/injection.dart';
import 'package:afasi/features/adhkar_reminder/presentation/cubit/adhkar_reminder_cubit.dart';
import 'package:afasi/features/adhkar_reminder/presentation/pages/adhkar_reminder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAdhkarReminderCubit extends Mock implements AdhkarReminderCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('AdhkarReminderPage toggles reminders and shows feedback messages',
      (tester) async {
    final mockCubit = MockAdhkarReminderCubit();
    final controller = StreamController<AdhkarReminderState>.broadcast();
    addTearDown(() async {
      await controller.close();
    });

    const initialState = AdhkarReminderState(
      morningEnabled: false,
      eveningEnabled: true,
      morningTime: TimeOfDay(hour: 6, minute: 0),
      eveningTime: TimeOfDay(hour: 18, minute: 0),
      isLoading: false,
    );

    when(() => mockCubit.state).thenReturn(initialState);
    when(() => mockCubit.stream).thenAnswer((_) => controller.stream);
    when(() => mockCubit.initialize()).thenAnswer((_) async {});
    when(() => mockCubit.toggleMorning(any())).thenAnswer((_) async {});
    when(() => mockCubit.toggleEvening(any())).thenAnswer((_) async {});
    when(() => mockCubit.clearMessages()).thenAnswer((_) {});
    when(() => mockCubit.close()).thenAnswer((_) async {});

    getIt.registerFactory<AdhkarReminderCubit>(() => mockCubit);

    await tester.pumpWidget(const MaterialApp(home: AdhkarReminderPage()));
    await tester.pump();

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));

    await tester.tap(switches.first);
    await tester.pump();
    verify(() => mockCubit.toggleMorning(true)).called(1);

    await tester.tap(switches.at(1));
    await tester.pump();
    verify(() => mockCubit.toggleEvening(false)).called(1);

    controller.add(initialState.copyWith(statusMessage: 'تم الحفظ'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('تم الحفظ'), findsOneWidget);
    verify(() => mockCubit.clearMessages()).called(1);
  });
}
