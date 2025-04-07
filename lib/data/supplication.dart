// lib/data/supplication.dart

class Supplication {
  final String title;
  final String audioUrl;
  final String textAssetPath;
  final bool isLocalAudio;
  bool isDownloaded;

  Supplication({
    required this.title,
    required this.audioUrl,
    required this.textAssetPath,
    this.isLocalAudio = false,
    this.isDownloaded = false,
  });
}
