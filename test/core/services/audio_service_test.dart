import 'dart:async';

import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';

import 'package:afasi/core/services/audio_service.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  test('dispose cancels subscriptions', () async {
    final mockPlayer = MockAudioPlayer();
    final processingController = StreamController<ProcessingState>.broadcast();
    final playingController = StreamController<bool>.broadcast();
    final playbackController = StreamController<PlaybackEvent>.broadcast();

    when(() => mockPlayer.processingStateStream)
        .thenAnswer((_) => processingController.stream);
    when(() => mockPlayer.playingStream)
        .thenAnswer((_) => playingController.stream);
    when(() => mockPlayer.playbackEventStream)
        .thenAnswer((_) => playbackController.stream);
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
    expect(playbackController.hasListener, isFalse);

    await processingController.close();
    await playingController.close();
    await playbackController.close();
  });

  test('refreshes YouTube cache entry when expired', () async {
    final cache = <String, YoutubeAudioCacheEntry>{};
    int extractionCount = 0;

    Future<YoutubeAudioCacheEntry> extractor(String videoId) async {
      extractionCount++;
      return YoutubeAudioCacheEntry(
        url: 'https://example.com/audio$extractionCount',
        fetchedAt: DateTime.now(),
        validity: const Duration(milliseconds: 10),
      );
    }

    final source = LazyYoutubeAudioSource(
      videoId: 'abc123',
      cache: cache,
      extractor: extractor,
      mediaItem: const MediaItem(id: 'abc123', title: 'Test', album: 'Album'),
    );

    final YoutubeAudioCacheEntry initial = await source.debugEnsureEntry();
    expect(initial.url, 'https://example.com/audio1');
    expect(extractionCount, 1);

    final YoutubeAudioCacheEntry expired = initial.copyWith(
      fetchedAt: initial.fetchedAt.subtract(const Duration(hours: 2)),
    );
    source.debugCacheEntry(expired);

    final YoutubeAudioCacheEntry refreshed = await source.debugEnsureEntry();
    expect(refreshed.url, 'https://example.com/audio2');
    expect(extractionCount, 2);
    expect(cache['abc123']?.url, refreshed.url);
  });
}
