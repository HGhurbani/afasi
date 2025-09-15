import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';

import 'package:azkar/core/services/audio_service.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  test('dispose cancels subscriptions', () async {
    final mockPlayer = MockAudioPlayer();
    final processingController = StreamController<ProcessingState>.broadcast();
    final playingController = StreamController<bool>.broadcast();

    when(() => mockPlayer.processingStateStream)
        .thenAnswer((_) => processingController.stream);
    when(() => mockPlayer.playingStream)
        .thenAnswer((_) => playingController.stream);
    when(() => mockPlayer.dispose()).thenAnswer((_) async {});

    final service = AudioService(audioPlayer: mockPlayer);

    int processingCalls = 0;
    int playingCalls = 0;

    service.initialize(
      onProcessingStateChanged: (_) => processingCalls++,
      onPlayingChanged: (_) => playingCalls++,
    );

    processingController.add(ProcessingState.ready);
    playingController.add(true);
    await Future<void>.delayed(Duration.zero);

    expect(processingCalls, 1);
    expect(playingCalls, 1);

    service.dispose();

    expect(processingController.hasListener, isFalse);
    expect(playingController.hasListener, isFalse);

    await processingController.close();
    await playingController.close();
  });
}
