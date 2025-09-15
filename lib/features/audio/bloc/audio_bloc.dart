
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/models/supplication.dart';
import '../../../core/services/audio_service.dart';
import '../../../data/repositories/audio_repository.dart';

// Events
abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

class LoadAudioCategories extends AudioEvent {}

class SelectCategory extends AudioEvent {
  final String category;
  const SelectCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class PlayAudio extends AudioEvent {
  final Supplication supplication;
  const PlayAudio(this.supplication);

  @override
  List<Object?> get props => [supplication];
}

class PauseAudio extends AudioEvent {}

class StopAudio extends AudioEvent {}

class SeekAudio extends AudioEvent {
  final Duration position;
  const SeekAudio(this.position);

  @override
  List<Object?> get props => [position];
}

class ToggleRepeat extends AudioEvent {}

class ToggleAutoNext extends AudioEvent {}

class SearchSupplications extends AudioEvent {
  final String query;
  const SearchSupplications(this.query);

  @override
  List<Object?> get props => [query];
}

class _AudioPlayerProcessingStateChanged extends AudioEvent {
  final ProcessingState state;
  const _AudioPlayerProcessingStateChanged(this.state);

  @override
  List<Object?> get props => [state];
}

class _AudioPlayerPlayingStateChanged extends AudioEvent {
  final bool isPlaying;
  const _AudioPlayerPlayingStateChanged(this.isPlaying);

  @override
  List<Object?> get props => [isPlaying];
}

// States
abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class AudioLoading extends AudioState {}

class AudioLoaded extends AudioState {
  final String selectedCategory;
  final List<Supplication> supplications;
  final List<Supplication> filteredSupplications;
  final Supplication? currentSupplication;
  final bool isPlaying;
  final bool isRepeat;
  final bool isAutoNext;
  final Duration position;
  final Duration duration;

  const AudioLoaded({
    required this.selectedCategory,
    required this.supplications,
    required this.filteredSupplications,
    this.currentSupplication,
    this.isPlaying = false,
    this.isRepeat = false,
    this.isAutoNext = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioLoaded copyWith({
    String? selectedCategory,
    List<Supplication>? supplications,
    List<Supplication>? filteredSupplications,
    Supplication? currentSupplication,
    bool? isPlaying,
    bool? isRepeat,
    bool? isAutoNext,
    Duration? position,
    Duration? duration,
  }) {
    return AudioLoaded(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      supplications: supplications ?? this.supplications,
      filteredSupplications: filteredSupplications ?? this.filteredSupplications,
      currentSupplication: currentSupplication ?? this.currentSupplication,
      isPlaying: isPlaying ?? this.isPlaying,
      isRepeat: isRepeat ?? this.isRepeat,
      isAutoNext: isAutoNext ?? this.isAutoNext,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [
        selectedCategory,
        supplications,
        filteredSupplications,
        currentSupplication,
        isPlaying,
        isRepeat,
        isAutoNext,
        position,
        duration,
      ];
}

class AudioError extends AudioState {
  final String message;
  const AudioError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository _audioRepository;
  final AudioService _audioService;

  AudioBloc({
    required AudioRepository audioRepository,
    required AudioService audioService,
  })  : _audioRepository = audioRepository,
        _audioService = audioService,
        super(AudioInitial()) {
    
    on<LoadAudioCategories>(_onLoadAudioCategories);
    on<SelectCategory>(_onSelectCategory);
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<StopAudio>(_onStopAudio);
    on<SeekAudio>(_onSeekAudio);
    on<ToggleRepeat>(_onToggleRepeat);
    on<ToggleAutoNext>(_onToggleAutoNext);
    on<SearchSupplications>(_onSearchSupplications);
    on<_AudioPlayerProcessingStateChanged>(_onAudioPlayerProcessingStateChanged);
    on<_AudioPlayerPlayingStateChanged>(_onAudioPlayerPlayingStateChanged);

    _audioService.initialize(
      onProcessingStateChanged: (state) {
        add(_AudioPlayerProcessingStateChanged(state));
      },
      onPlayingChanged: (playing) {
        add(_AudioPlayerPlayingStateChanged(playing));
      },
    );
  }

  void _onLoadAudioCategories(LoadAudioCategories event, Emitter<AudioState> emit) {
    try {
      final categories = _audioRepository.getAudioCategories();
      final defaultCategory = categories.first;
      
      emit(AudioLoaded(
        selectedCategory: defaultCategory.name,
        supplications: defaultCategory.supplications,
        filteredSupplications: defaultCategory.supplications,
      ));
    } catch (e) {
      emit(AudioError('Failed to load audio categories: $e'));
    }
  }

  void _onSelectCategory(SelectCategory event, Emitter<AudioState> emit) {
    if (state is AudioLoaded) {
      final currentState = state as AudioLoaded;
      final supplications = _audioRepository.getSupplicationsByCategory(event.category);
      
      emit(currentState.copyWith(
        selectedCategory: event.category,
        supplications: supplications,
        filteredSupplications: supplications,
      ));
    }
  }

  Future<void> _onPlayAudio(PlayAudio event, Emitter<AudioState> emit) async {
    if (state is AudioLoaded) {
      final currentState = state as AudioLoaded;
      
      try {
        await _audioService.setAudioSource(event.supplication);
        _audioService.play();
        
        emit(currentState.copyWith(
          currentSupplication: event.supplication,
          isPlaying: true,
        ));
      } catch (e) {
        emit(AudioError('Failed to play audio: $e'));
      }
    }
  }

  void _onPauseAudio(PauseAudio event, Emitter<AudioState> emit) {
    if (state is AudioLoaded) {
      final currentState = state as AudioLoaded;
      _audioService.pause();
      
      emit(currentState.copyWith(isPlaying: false));
    }
  }

  void _onStopAudio(StopAudio event, Emitter<AudioState> emit) {
    if (state is AudioLoaded) {
      final currentState = state as AudioLoaded;
      _audioService.stop();
      
      emit(currentState.copyWith(
        currentSupplication: null,
        isPlaying: false,
      ));
    }
  }

  Future<void> _onSeekAudio(SeekAudio event, Emitter<AudioState> emit) async {
    await _audioService.seek(event.position);
  }

  void _onToggleRepeat(ToggleRepeat event, Emitter<AudioState> emit) {
    if (state is AudioLoaded) {
      final currentState = state as AudioLoaded;
      final newRepeatState = !currentState.isRepeat;
      
      _audioService.setLoopMode(newRepeatState ? LoopMode.one : LoopMode.off);
      
      emit(currentState.copyWith(isRepeat: newRepeatState));
    }
  }

  void _onToggleAutoNext(ToggleAutoNext event, Emitter<AudioState> emit) {
    if (state is AudioLoaded) {
      final currentState = state as AudioLoaded;

      emit(currentState.copyWith(isAutoNext: !currentState.isAutoNext));
    }
  }

  void _onAudioPlayerProcessingStateChanged(
      _AudioPlayerProcessingStateChanged event, Emitter<AudioState> emit) {
    if (state is AudioLoaded) {
      final currentState = state as AudioLoaded;
      if (event.state == ProcessingState.completed) {
        emit(currentState.copyWith(
          currentSupplication: null,
          isPlaying: false,
        ));
      }
    }
  }

  void _onAudioPlayerPlayingStateChanged(
      _AudioPlayerPlayingStateChanged event, Emitter<AudioState> emit) {
    if (state is AudioLoaded) {
      final currentState = state as AudioLoaded;
      emit(currentState.copyWith(isPlaying: event.isPlaying));
    }
  }

  void _onSearchSupplications(SearchSupplications event, Emitter<AudioState> emit) {
    if (state is AudioLoaded) {
      final currentState = state as AudioLoaded;
      
      final filteredSupplications = event.query.isEmpty
          ? currentState.supplications
          : currentState.supplications
              .where((supp) => supp.title.contains(event.query))
              .toList();
      
      emit(currentState.copyWith(filteredSupplications: filteredSupplications));
    }
  }

  @override
  Future<void> close() {
    _audioService.dispose();
    return super.close();
  }
}
