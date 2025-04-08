
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/supplication.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, String> _youtubeCache = {};

  AudioPlayer get player => _audioPlayer;

  Future<void> playAudio(Supplication supp) async {
    if (supp.isLocalAudio) {
      await _playLocalAudio(supp);
      return;
    }

    final String? downloadedPath = await _getDownloadedPath(supp);
    if (downloadedPath != null) {
      await _playDownloadedAudio(downloadedPath);
      return;
    }

    await _playStreamingAudio(supp);
  }

  Future<void> _playLocalAudio(Supplication supp) async {
    try {
      await _audioPlayer.setAsset(supp.audioUrl);
      _audioPlayer.play();
    } catch (e) {
      throw Exception('Error playing local audio: $e');
    }
  }

  Future<String?> _getDownloadedPath(Supplication supp) async {
    final Directory dir = await getApplicationSupportDirectory();
    final String filePath = '${dir.path}/${supp.title}.mp3';
    if (await File(filePath).exists()) {
      return filePath;
    }
    return null;
  }

  Future<void> _playDownloadedAudio(String filePath) async {
    try {
      await _audioPlayer.setFilePath(filePath);
      _audioPlayer.play();
    } catch (e) {
      throw Exception('Error playing downloaded audio: $e');
    }
  }

  Future<void> _playStreamingAudio(Supplication supp) async {
    String source;
    if (supp.audioUrl.contains("youtube.com") || supp.audioUrl.contains("youtu.be")) {
      source = await _getYoutubeAudioUrl(supp.audioUrl);
    } else {
      source = supp.audioUrl;
    }

    try {
      await _audioPlayer.setUrl(source);
      _audioPlayer.play();
    } catch (e) {
      throw Exception('Error playing streaming audio: $e');
    }
  }

  Future<String> _getYoutubeAudioUrl(String videoUrl) async {
    final String? videoId = _extractYoutubeVideoId(videoUrl);
    if (videoId == null) {
      throw Exception('Invalid YouTube URL');
    }

    if (_youtubeCache.containsKey(videoId)) {
      return _youtubeCache[videoId]!;
    }

    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
      final audioUrl = audioStreamInfo.url.toString();
      _youtubeCache[videoId] = audioUrl;
      return audioUrl;
    } finally {
      yt.close();
    }
  }

  String? _extractYoutubeVideoId(String url) {
    final RegExp regExp = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*',
        caseSensitive: false, multiLine: false);
    final Match? match = regExp.firstMatch(url);
    return match?.group(1);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
