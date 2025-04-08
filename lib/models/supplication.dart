
import 'package:flutter/material.dart';

class Supplication {
  final int id;
  final String title;
  final String audioUrl;
  final String textAssetPath;
  final IconData icon;
  final bool isLocalAudio;
  bool isDownloaded;

  Supplication({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.textAssetPath,
    required this.icon,
    this.isLocalAudio = false,
    this.isDownloaded = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'audioUrl': audioUrl,
      'textAssetPath': textAssetPath,
      'isLocalAudio': isLocalAudio,
      'isDownloaded': isDownloaded,
    };
  }

  factory Supplication.fromJson(Map<String, dynamic> json) {
    return Supplication(
      id: json['id'],
      title: json['title'],
      audioUrl: json['audioUrl'],
      textAssetPath: json['textAssetPath'],
      icon: json['icon'] ?? Icons.music_note,
      isLocalAudio: json['isLocalAudio'] ?? false,
      isDownloaded: json['isDownloaded'] ?? false,
    );
  }
}
