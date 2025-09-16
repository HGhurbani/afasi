import 'dart:async';

import 'package:afasi/features/tasbih/presentation/cubit/tasbih_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = SystemChannels.platform;
  late List<String?> hapticInvocations;

  setUp(() {
    hapticInvocations = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (methodCall) async {
      if (methodCall.method == 'HapticFeedback.vibrate') {
        hapticInvocations.add(methodCall.arguments as String?);
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test('increment increases counter and triggers light haptic feedback', () async {
    final cubit = TasbihCubit();
    final states = <TasbihState>[];
    final StreamSubscription<TasbihState> subscription =
        cubit.stream.listen(states.add);

    await cubit.increment();

    expect(states.single.counter, 1);
    expect(hapticInvocations.single, 'HapticFeedbackType.lightImpact');

    await subscription.cancel();
    await cubit.close();
  });

  test('reset sets counter to zero and triggers medium haptic feedback',
      () async {
    final cubit = TasbihCubit();
    final states = <TasbihState>[];
    final StreamSubscription<TasbihState> subscription =
        cubit.stream.listen(states.add);

    await cubit.increment();
    states.clear();
    hapticInvocations.clear();

    await cubit.reset();

    expect(states.single.counter, 0);
    expect(hapticInvocations.single, 'HapticFeedbackType.mediumImpact');

    await subscription.cancel();
    await cubit.close();
  });
}
