import 'dart:async';

import 'package:afasi/core/di/injection.dart';
import 'package:afasi/features/tasbih/presentation/cubit/tasbih_cubit.dart';
import 'package:afasi/features/tasbih/presentation/pages/tasbih_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTasbihCubit extends Mock implements TasbihCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('TasbihPage triggers increment and reset actions', (tester) async {
    final mockCubit = MockTasbihCubit();

    when(() => mockCubit.state).thenReturn(const TasbihState(counter: 5));
    when(() => mockCubit.stream)
        .thenAnswer((_) => Stream<TasbihState>.fromIterable(const <TasbihState>[]));
    when(() => mockCubit.increment()).thenAnswer((_) async {});
    when(() => mockCubit.reset()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});

    getIt.registerFactory<TasbihCubit>(() => mockCubit);

    await tester.pumpWidget(const MaterialApp(home: TasbihPage()));
    await tester.pump();

    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    verify(() => mockCubit.increment()).called(1);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    verify(() => mockCubit.reset()).called(1);
  });
}
