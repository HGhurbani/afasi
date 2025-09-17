
import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/supplication.dart';

const Duration _youtubeCacheValidity = Duration(hours: 1);
const Duration _youtubeRequestTimeout = Duration(seconds: 10);

class AudioService {
  AudioService({AudioPlayer? audioPlayer}) : _audioPlayer = audioPlayer ?? AudioPlayer();

  final AudioPlayer _audioPlayer;
  final Map<String, YoutubeAudioCacheEntry> _youtubeCache = {};

  StreamSubscription<ProcessingState>? _processingStateSubscription;
  StreamSubscription<bool>? _playingStreamSubscription;
  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;

  AudioPlayer get audioPlayer => _audioPlayer;
  Map<String, YoutubeAudioCacheEntry> get youtubeCache => _youtubeCache;

  void initialize({
    void Function(ProcessingState state)? onProcessingStateChanged,
    void Function(bool playing)? onPlayingChanged,
    void Function(Object error, StackTrace stackTrace)? onPlaybackError,
  }) {
    _playbackEventSubscription?.cancel();
    _processingStateSubscription = onProcessingStateChanged == null
        ? null
        : _audioPlayer.processingStateStream.listen(onProcessingStateChanged);
    _playingStreamSubscription = onPlayingChanged == null
        ? null
        : _audioPlayer.playingStream.listen(onPlayingChanged);
    _playbackEventSubscription = _audioPlayer.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace stackTrace) async {
        await _handlePlaybackError(error);
        if (onPlaybackError != null) {
          onPlaybackError(error, stackTrace);
        }
      },
    );
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
        if (cachedEntry != null && cachedEntry.isExpired) {
          _youtubeCache.remove(videoId);
        }
        return LazyYoutubeAudioSource(
          videoId: videoId,
          initialEntry:
              cachedEntry != null && !cachedEntry.isExpired ? cachedEntry : null,
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
        fetchedAt: DateTime.now(),
        validity: _youtubeCacheValidity,
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
    _playbackEventSubscription?.cancel();
    _audioPlayer.dispose();
  }

  Future<void> _handlePlaybackError(Object error) async {
    if (!_shouldRetryError(error)) {
      return;
    }

    final sequenceState = _audioPlayer.sequenceState;
    final currentSource = sequenceState?.currentSource;
    if (currentSource is LazyYoutubeAudioSource) {
      try {
        await currentSource.refreshEntry();
        final int? currentIndex = _audioPlayer.currentIndex;
        final Duration position = _audioPlayer.position;
        if (currentIndex != null) {
          await _audioPlayer.seek(position, index: currentIndex);
        } else {
          await _audioPlayer.seek(position);
        }
        await _audioPlayer.play();
      } catch (_) {
        // Swallow exceptions to avoid cascading failures while retrying.
      }
    }
  }

  bool _shouldRetryError(Object error) {
    final String message = error.toString().toLowerCase();
    return message.contains('403') ||
        message.contains('forbidden') ||
        message.contains('timeout');
  }
}

class YoutubeAudioCacheEntry {
  YoutubeAudioCacheEntry({
    required this.url,
    this.mimeType,
    this.contentLength,
    DateTime? fetchedAt,
    Duration? validity,
  })  : fetchedAt = fetchedAt ?? DateTime.now(),
        validity = validity ?? _youtubeCacheValidity;

  final String url;
  final String? mimeType;
  final int? contentLength;
  final DateTime fetchedAt;
  final Duration validity;

  DateTime get expiresAt => fetchedAt.add(validity);
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  YoutubeAudioCacheEntry copyWith({
    String? url,
    String? mimeType,
    int? contentLength,
    DateTime? fetchedAt,
    Duration? validity,
  }) {
    return YoutubeAudioCacheEntry(
      url: url ?? this.url,
      mimeType: mimeType ?? this.mimeType,
      contentLength: contentLength ?? this.contentLength,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      validity: validity ?? this.validity,
    );
  }
}

class LazyYoutubeAudioSource extends StreamAudioSource {
  LazyYoutubeAudioSource({
    required this.videoId,
    required this.cache,
    required this.extractor,
    required MediaItem mediaItem,
    YoutubeAudioCacheEntry? initialEntry,
    HttpClient? httpClient,
  })  : _cachedEntry =
            initialEntry != null && !initialEntry.isExpired ? initialEntry : null,
        _httpClient = httpClient ?? _defaultHttpClient,
        super(tag: mediaItem);

  static HttpClient _defaultHttpClient = HttpClient();

  final String videoId;
  final Map<String, YoutubeAudioCacheEntry> cache;
  final Future<YoutubeAudioCacheEntry> Function(String videoId) extractor;
  final HttpClient _httpClient;

  YoutubeAudioCacheEntry? _cachedEntry;
  Future<YoutubeAudioCacheEntry>? _pendingExtraction;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    YoutubeAudioCacheEntry entry = await _ensureEntry();
    try {
      return await _createResponse(entry, start, end);
    } on _RetryableStreamException {
      entry = await _ensureEntry(forceRefresh: true);
      try {
        return await _createResponse(entry, start, end);
      } on _RetryableStreamException {
        throw HttpException(
          'Failed to load refreshed YouTube audio stream for $videoId',
          uri: Uri.parse(entry.url),
        );
      }
    }
  }

  Future<StreamAudioResponse> _createResponse(
    YoutubeAudioCacheEntry entry,
    int? start,
    int? end,
  ) async {
    final Uri uri = Uri.parse(entry.url);
    try {
      final HttpClientRequest request = await _httpClient.getUrl(uri);
      _applyRangeHeaders(request, start: start, end: end);

      final HttpClientResponse response =
          await request.close().timeout(_youtubeRequestTimeout);

      if (_shouldRetryStatus(response.statusCode)) {
        await response.drain<void>();
        throw const _RetryableStreamException();
      }

      final int? sourceLength = entry.contentLength ?? _parseContentRange(
          response.headers.value(HttpHeaders.contentRangeHeader));
      final int contentLength = response.contentLength;

      return StreamAudioResponse(
        sourceLength: sourceLength ?? (contentLength >= 0 ? contentLength : null),
        contentLength: contentLength >= 0 ? contentLength : null,
        offset: start ?? 0,
        stream: response,
        contentType: entry.mimeType ??
            response.headers.contentType?.mimeType ??
            'audio/mp4',
      );
    } on TimeoutException {
      throw const _RetryableStreamException();
    } on SocketException {
      throw const _RetryableStreamException();
    }
  }

  bool _shouldRetryStatus(int statusCode) {
    return statusCode == HttpStatus.forbidden ||
        statusCode == HttpStatus.unauthorized ||
        statusCode == HttpStatus.requestTimeout;
  }

  Future<YoutubeAudioCacheEntry> _ensureEntry({bool forceRefresh = false}) async {
    if (forceRefresh) {
      cache.remove(videoId);
      _cachedEntry = null;
      return _refreshEntry(force: true);
    }

    if (_cachedEntry != null) {
      if (!_cachedEntry!.isExpired) {
        return _cachedEntry!;
      }
      _cachedEntry = null;
    }

    final YoutubeAudioCacheEntry? cached = cache[videoId];
    if (cached != null) {
      if (!cached.isExpired) {
        _cachedEntry = cached;
        return cached;
      }
      cache.remove(videoId);
    }

    return _refreshEntry();
  }

  Future<YoutubeAudioCacheEntry> _refreshEntry({bool force = false}) async {
    if (force || _pendingExtraction == null) {
      _pendingExtraction = extractor(videoId);
    }
    try {
      final YoutubeAudioCacheEntry resolved = await _pendingExtraction!;
      cache[videoId] = resolved;
      _cachedEntry = resolved;
      return resolved;
    } finally {
      _pendingExtraction = null;
    }
  }

  Future<YoutubeAudioCacheEntry> refreshEntry() {
    return _ensureEntry(forceRefresh: true);
  }

  @visibleForTesting
  Future<YoutubeAudioCacheEntry> debugEnsureEntry({
    bool forceRefresh = false,
  }) {
    return _ensureEntry(forceRefresh: forceRefresh);
  }

  @visibleForTesting
  void debugCacheEntry(YoutubeAudioCacheEntry? entry) {
    _cachedEntry = entry;
    if (entry == null) {
      cache.remove(videoId);
    } else {
      cache[videoId] = entry;
    }
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

class _RetryableStreamException implements Exception {
  const _RetryableStreamException();
}
