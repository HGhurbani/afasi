
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
  final Map<String, YoutubeAudioCacheEntry> _youtubeCache = {};

  StreamSubscription<ProcessingState>? _processingStateSubscription;
  StreamSubscription<bool>? _playingStreamSubscription;

  AudioPlayer get audioPlayer => _audioPlayer;
  Map<String, YoutubeAudioCacheEntry> get youtubeCache => _youtubeCache;

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
    final AudioSource audioSource = await _buildAudioSourceForSupplication(
      supplication,
      album: 'Audio',
    );

    await _audioPlayer.setAudioSource(audioSource);
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

    final String resolvedAlbum = album ?? 'Audio';
    final MediaItem mediaItem = MediaItem(
      id: source,
      title: supplication.title,
      album: resolvedAlbum,
    );

    if (supplication.isLocalAudio) {
      return AudioSource.asset(
        source,
        tag: mediaItem,
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
          album: resolvedAlbum,
        ),
      );
    }

    if (source.contains('youtube.com') || source.contains('youtu.be')) {
      final String? videoId = _extractYoutubeVideoId(source);
      if (videoId != null) {
        final YoutubeAudioCacheEntry? cachedEntry = _youtubeCache[videoId];
        return LazyYoutubeAudioSource(
          videoId: videoId,
          initialEntry: cachedEntry,
          cache: _youtubeCache,
          extractor: _extractYoutubeAudioUrl,
          mediaItem: MediaItem(
            id: videoId,
            title: supplication.title,
            album: resolvedAlbum,
          ),
        );
      }
    }

    return AudioSource.uri(
      Uri.parse(source),
      tag: mediaItem,
    );
  }

  Future<YoutubeAudioCacheEntry> _extractYoutubeAudioUrl(String videoId) async {
    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
      final String? mimeType = audioStreamInfo.codec.mimeType;
      final int? totalBytes = audioStreamInfo.size.totalBytes;
      return YoutubeAudioCacheEntry(
        url: audioStreamInfo.url.toString(),
        mimeType: mimeType,
        contentLength: totalBytes,
      );
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

class YoutubeAudioCacheEntry {
  YoutubeAudioCacheEntry({
    required this.url,
    this.mimeType,
    this.contentLength,
  });

  final String url;
  final String? mimeType;
  final int? contentLength;
}

class LazyYoutubeAudioSource extends StreamAudioSource {
  LazyYoutubeAudioSource({
    required this.videoId,
    required this.cache,
    required this.extractor,
    required MediaItem mediaItem,
    YoutubeAudioCacheEntry? initialEntry,
  })  : _cachedEntry = initialEntry,
        super(tag: mediaItem);

  static final HttpClient _httpClient = HttpClient();

  final String videoId;
  final Map<String, YoutubeAudioCacheEntry> cache;
  final Future<YoutubeAudioCacheEntry> Function(String videoId) extractor;

  YoutubeAudioCacheEntry? _cachedEntry;
  Future<YoutubeAudioCacheEntry>? _pendingExtraction;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final YoutubeAudioCacheEntry entry = await _ensureEntry();
    final Uri uri = Uri.parse(entry.url);

    final HttpClientRequest request = await _httpClient.getUrl(uri);
    _applyRangeHeaders(request, start: start, end: end);

    final HttpClientResponse response = await request.close();
    final int? sourceLength = entry.contentLength ??
        _parseContentRange(response.headers.value(HttpHeaders.contentRangeHeader));
    final int contentLength = response.contentLength;

    return StreamAudioResponse(
      sourceLength: sourceLength ?? (contentLength >= 0 ? contentLength : null),
      contentLength: contentLength >= 0 ? contentLength : null,
      offset: start ?? 0,
      stream: response,
      contentType:
          entry.mimeType ?? response.headers.contentType?.mimeType ?? 'audio/mp4',
    );
  }

  Future<YoutubeAudioCacheEntry> _ensureEntry() async {
    if (_cachedEntry != null) {
      return _cachedEntry!;
    }

    final YoutubeAudioCacheEntry? cached = cache[videoId];
    if (cached != null) {
      _cachedEntry = cached;
      return cached;
    }

    _pendingExtraction ??= extractor(videoId);
    final YoutubeAudioCacheEntry resolved = await _pendingExtraction!;
    cache[videoId] = resolved;
    _cachedEntry = resolved;
    _pendingExtraction = null;
    return resolved;
  }

  void _applyRangeHeaders(
    HttpClientRequest request, {
    int? start,
    int? end,
  }) {
    if (start == null && end == null) {
      return;
    }

    if (start == null && end != null) {
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=-${end - 1}');
      return;
    }

    final String endPart = end != null ? '${end - 1}' : '';
    request.headers.set(HttpHeaders.rangeHeader, 'bytes=$start-$endPart');
  }

  int? _parseContentRange(String? headerValue) {
    if (headerValue == null) {
      return null;
    }
    final RegExpMatch? match = RegExp(r'/(\d+|\*)$').firstMatch(headerValue.trim());
    if (match == null) {
      return null;
    }
    final String value = match.group(1)!;
    if (value == '*') {
      return null;
    }
    return int.tryParse(value);
  }
}
