
import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import '../models/supplication.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, String> _youtubeCache = {};
  
  StreamSubscription<ProcessingState>? _processingStateSubscription;
  StreamSubscription<bool>? _playingStreamSubscription;

  AudioPlayer get audioPlayer => _audioPlayer;
  Map<String, String> get youtubeCache => _youtubeCache;

  void initialize() {
    _processingStateSubscription = _audioPlayer.processingStateStream.listen(null);
    _playingStreamSubscription = _audioPlayer.playingStream.listen(null);
  }

  Future<void> setAudioSource(Supplication supplication) async {
    String source = supplication.audioUrl;
    
    if (supplication.isLocalAudio) {
      await _audioPlayer.setAudioSource(
        AudioSource.asset(
          source,
          tag: MediaItem(id: source, title: supplication.title),
        ),
      );
      return;
    }

    // Check if downloaded
    final Directory dir = await getApplicationSupportDirectory();
    final String filePath = '${dir.path}/${supplication.title}.mp3';
    if (await File(filePath).exists()) {
      await _audioPlayer.setAudioSource(
        AudioSource.file(
          filePath,
          tag: MediaItem(id: filePath, title: supplication.title),
        ),
      );
      return;
    }

    // Handle YouTube URLs
    if (source.contains("youtube.com") || source.contains("youtu.be")) {
      final String? videoId = _extractYoutubeVideoId(source);
      if (videoId != null) {
        if (_youtubeCache.containsKey(videoId)) {
          source = _youtubeCache[videoId]!;
        } else {
          source = await _extractYoutubeAudioUrl(videoId);
          _youtubeCache[videoId] = source;
        }
      }
    }

    await _audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(source),
        tag: MediaItem(id: source, title: supplication.title),
      ),
    );
  }

  Future<String> _extractYoutubeAudioUrl(String videoId) async {
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
      return audioStreamInfo.url.toString();
    } finally {
      yt.close();
    }
  }

  String? _extractYoutubeVideoId(String url) {
    final RegExp regExp = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*');
    final Match? match = regExp.firstMatch(url);
    return match?.group(1);
  }

  void play() => _audioPlayer.play();
  void pause() => _audioPlayer.pause();
  void stop() => _audioPlayer.stop();
  
  Future<void> seek(Duration position) => _audioPlayer.seek(position);
  
  void setLoopMode(LoopMode loopMode) => _audioPlayer.setLoopMode(loopMode);

  void dispose() {
    _processingStateSubscription?.cancel();
    _playingStreamSubscription?.cancel();
    _audioPlayer.dispose();
  }
}
