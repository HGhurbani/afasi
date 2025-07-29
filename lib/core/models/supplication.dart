
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Supplication extends Equatable {
  final String title;
  final String audioUrl;
  final String textAssetPath;
  final IconData icon;
  final bool isLocalAudio;
  final bool isDownloaded;

  const Supplication({
    required this.title,
    required this.audioUrl,
    required this.textAssetPath,
    required this.icon,
    this.isLocalAudio = false,
    this.isDownloaded = false,
  });

  Supplication copyWith({
    String? title,
    String? audioUrl,
    String? textAssetPath,
    IconData? icon,
    bool? isLocalAudio,
    bool? isDownloaded,
  }) {
    return Supplication(
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      textAssetPath: textAssetPath ?? this.textAssetPath,
      icon: icon ?? this.icon,
      isLocalAudio: isLocalAudio ?? this.isLocalAudio,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  @override
  List<Object?> get props => [
        title,
        audioUrl,
        textAssetPath,
        icon,
        isLocalAudio,
        isDownloaded,
      ];
}
