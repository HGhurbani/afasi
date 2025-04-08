
import 'package:flutter/foundation.dart';
import '../models/supplication.dart';
import '../services/audio_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  Supplication? _currentSupplication;
  bool _isPlaying = false;
  bool _isAutoNext = false;
  bool _isRepeat = false;

  Supplication? get currentSupplication => _currentSupplication;
  bool get isPlaying => _isPlaying;
  bool get isAutoNext => _isAutoNext;
  bool get isRepeat => _isRepeat;
  AudioService get audioService => _audioService;

  void setCurrentSupplication(Supplication? supplication) {
    _currentSupplication = supplication;
    notifyListeners();
  }

  void setIsPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  void toggleAutoNext() {
    _isAutoNext = !_isAutoNext;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    _audioService.player.setLoopMode(_isRepeat ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
