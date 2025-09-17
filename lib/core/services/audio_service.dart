
import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import '../models/supplication.dart';

class AudioService {
  AudioService({AudioPlayer? audioPlayer}) : _audioPlayer = audioPlayer ?? AudioPlayer();

  final AudioPlayer _audioPlayer;
  final Map<String, String> _youtubeCache = {};

  StreamSubscription<ProcessingState>? _processingStateSubscription;
  StreamSubscription<bool>? _playingStreamSubscription;

  AudioPlayer get audioPlayer => _audioPlayer;
  Map<String, String> get youtubeCache => _youtubeCache;

  void initialize({
    void Function(ProcessingState state)? onProcessingStateChanged,
    void Function(bool playing)? onPlayingChanged,
  }) {
    _processingStateSubscription = onProcessingStateChanged == null
        ? null
        : _audioPlayer.processingStateStream.listen(onProcessingStateChanged);
    _playingStreamSubscription = onPlayingChanged == null
        ? null
        : _audioPlayer.playingStream.listen(onPlayingChanged);
  }

  Future<void> setAudioSource(Supplication supplication) async {
    String source = supplication.audioUrl;
    
    if (supplication.isLocalAudio) {
      await _audioPlayer.setAudioSource(
        AudioSource.asset(
          source,
          tag: MediaItem(
            id: source,
            title: supplication.title,
            album: 'Audio',
          ),
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
          tag: MediaItem(
            id: filePath,
            title: supplication.title,
            album: 'Audio',
          ),
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
        tag: MediaItem(
          id: source,
          title: supplication.title,
          album: 'Audio',
        ),
      ),
    );
  }

  Future<void> setPlaylist({
    required List<Supplication> supplications,
    required int initialIndex,
    String? album,
  }) async {
    final List<AudioSource> audioSources = [];
    for (final supp in supplications) {
      final AudioSource src = await _buildAudioSourceForSupplication(
        supp,
        album: album,
      );
      audioSources.add(src);
    }

    final ConcatenatingAudioSource playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: audioSources,
    );

    await _audioPlayer.setAudioSource(
      playlist,
      initialIndex: initialIndex.clamp(0, audioSources.length - 1),
      initialPosition: Duration.zero,
    );
  }

  Future<AudioSource> _buildAudioSourceForSupplication(
    Supplication supplication, {
    String? album,
  }) async {
    String source = supplication.audioUrl;

    if (supplication.isLocalAudio) {
      return AudioSource.asset(
        source,
        tag: MediaItem(
          id: source,
          title: supplication.title,
          album: album ?? 'Audio',
        ),
      );
    }

    final Directory dir = await getApplicationSupportDirectory();
    final String filePath = '${dir.path}/${supplication.title}.mp3';
    if (await File(filePath).exists()) {
      return AudioSource.file(
        filePath,
        tag: MediaItem(
          id: filePath,
          title: supplication.title,
          album: album ?? 'Audio',
        ),
      );
    }

    if (source.contains('youtube.com') || source.contains('youtu.be')) {
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

    return AudioSource.uri(
      Uri.parse(source),
      tag: MediaItem(
        id: source,
        title: supplication.title,
        album: album ?? 'Audio',
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

  Future<void> play() => _audioPlayer.play();
  Future<void> pause() => _audioPlayer.pause();
  Future<void> stop() => _audioPlayer.stop();
  
  Future<void> seek(Duration position) => _audioPlayer.seek(position);
  
  Future<void> setLoopMode(LoopMode loopMode) => _audioPlayer.setLoopMode(loopMode);

  void dispose() {
    _processingStateSubscription?.cancel();
    _playingStreamSubscription?.cancel();
    _audioPlayer.dispose();
  }
}
