import 'dart:async';

import 'package:afasi/core/models/audio_category.dart';
import 'package:afasi/core/models/supplication.dart';
import 'package:afasi/core/services/audio_service.dart';
import 'package:afasi/data/repositories/audio_repository.dart';
import 'package:afasi/features/audio/bloc/audio_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioRepository extends Mock implements AudioRepository {}

class MockAudioService extends Mock implements AudioService {}

Future<void> pumpEventQueue() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  late MockAudioRepository audioRepository;
  late MockAudioService audioService;
  late AudioBloc audioBloc;
  late List<AudioCategory> categories;
  late Supplication morningSupplication;
  late Supplication eveningSupplication;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(
      const Supplication(
        title: 'fallback',
        audioUrl: 'fallback',
        textAssetPath: 'fallback',
        icon: Icons.ac_unit,
      ),
    );
    registerFallbackValue(Duration.zero);
    registerFallbackValue(LoopMode.off);
  });

  setUp(() {
    audioRepository = MockAudioRepository();
    audioService = MockAudioService();

    morningSupplication = const Supplication(
      title: 'Morning Supplication',
      audioUrl: 'morning.mp3',
      textAssetPath: 'morning.txt',
      icon: Icons.wb_sunny,
    );
    eveningSupplication = const Supplication(
      title: 'Evening Supplication',
      audioUrl: 'evening.mp3',
      textAssetPath: 'evening.txt',
      icon: Icons.nightlight_round,
    );

    categories = [
      AudioCategory(
        name: 'Category 1',
        supplications: [morningSupplication, eveningSupplication],
      ),
      AudioCategory(
        name: 'Category 2',
        supplications: [eveningSupplication],
      ),
    ];

    when(
      () => audioService.initialize(
        onProcessingStateChanged: any(named: 'onProcessingStateChanged'),
        onPlayingChanged: any(named: 'onPlayingChanged'),
      ),
    ).thenAnswer((_) {});
    when(() => audioService.dispose()).thenAnswer((_) {});
    when(() => audioRepository.getAudioCategories()).thenReturn(categories);
    when(() => audioRepository.getSupplicationsByCategory(any())).thenAnswer(
      (invocation) {
        final category = invocation.positionalArguments.first as String;
        return categories
            .firstWhere(
              (cat) => cat.name == category,
              orElse: () => categories.first,
            )
            .supplications;
      },
    );
    when(() => audioService.setAudioSource(any())).thenAnswer((_) async {});
    when(() => audioService.play()).thenAnswer((_) {});
    when(() => audioService.stop()).thenAnswer((_) {});
    when(() => audioService.seek(any())).thenAnswer((_) async {});
    when(() => audioService.pause()).thenAnswer((_) {});
    when(() => audioService.setLoopMode(any())).thenAnswer((_) {});

    audioBloc = AudioBloc(
      audioRepository: audioRepository,
      audioService: audioService,
    );
  });

  tearDown(() async {
    await audioBloc.close();
  });

  test('PlayAudio sets current supplication and triggers playback', () async {
    final states = <AudioState>[];
    final subscription = audioBloc.stream.listen(states.add);

    audioBloc.add(LoadAudioCategories());
    await pumpEventQueue();
    audioBloc.add(PlayAudio(morningSupplication));
    await pumpEventQueue();

    expect(states.length, 2);

    final loaded = states.firstWhere((state) => state is AudioLoaded) as AudioLoaded;
    expect(loaded.selectedCategory, 'Category 1');
    expect(loaded.currentSupplication, isNull);
    expect(loaded.isPlaying, isFalse);

    final playing = states.last as AudioLoaded;
    expect(playing.currentSupplication, morningSupplication);
    expect(playing.isPlaying, isTrue);

    verify(() => audioService.setAudioSource(morningSupplication)).called(1);
    verify(() => audioService.play()).called(1);

    await subscription.cancel();
  });

  test('StopAudio clears current supplication and stops playback', () async {
    final states = <AudioState>[];
    final subscription = audioBloc.stream.listen(states.add);

    audioBloc.add(LoadAudioCategories());
    await pumpEventQueue();
    audioBloc.add(PlayAudio(morningSupplication));
    await pumpEventQueue();
    audioBloc.add(StopAudio());
    await pumpEventQueue();

    expect(states.length, 3);
    final stopped = states.last as AudioLoaded;
    expect(stopped.currentSupplication, isNull);
    expect(stopped.isPlaying, isFalse);

    verify(() => audioService.stop()).called(1);

    await subscription.cancel();
  });

  test('SearchSupplications filters supplications by query', () async {
    final states = <AudioState>[];
    final subscription = audioBloc.stream.listen(states.add);

    audioBloc.add(LoadAudioCategories());
    await pumpEventQueue();
    audioBloc.add(const SearchSupplications('Morning'));
    await pumpEventQueue();

    expect(states.length, 2);
    final filtered = states.last as AudioLoaded;
    expect(filtered.filteredSupplications.length, 1);
    expect(filtered.filteredSupplications.first, morningSupplication);

    await subscription.cancel();
  });

  test('SeekAudio delegates to audio service without emitting new state', () async {
    final states = <AudioState>[];
    final subscription = audioBloc.stream.listen(states.add);

    audioBloc.add(LoadAudioCategories());
    await pumpEventQueue();
    audioBloc.add(SeekAudio(const Duration(seconds: 30)));
    await pumpEventQueue();

    verify(() => audioService.seek(const Duration(seconds: 30))).called(1);
    expect(states.length, 1);

    await subscription.cancel();
  });
}
