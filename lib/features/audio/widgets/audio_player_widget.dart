
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/models/supplication.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_styles.dart';
import '../bloc/audio_bloc.dart';

class AudioPlayerWidget extends StatelessWidget {
  final Supplication supplication;
  final bool isPlaying;
  final bool isRepeat;
  final bool isAutoNext;
  final Duration position;
  final Duration duration;

  const AudioPlayerWidget({
    Key? key,
    required this.supplication,
    required this.isPlaying,
    required this.isRepeat,
    required this.isAutoNext,
    required this.position,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            supplication.title,
            style: AppStyles.cardTitle.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: duration.inMilliseconds > 0
                      ? position.inMilliseconds / duration.inMilliseconds
                      : 0.0,
                  onChanged: (value) {
                    final newPosition = Duration(
                      milliseconds: (duration.inMilliseconds * value).round(),
                    );
                    context.read<AudioBloc>().add(SeekAudio(newPosition));
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.white30,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  context.read<AudioBloc>().add(ToggleRepeat());
                },
                icon: FaIcon(
                  FontAwesomeIcons.repeat,
                  color: isRepeat ? Colors.white : Colors.white54,
                ),
              ),
              IconButton(
                onPressed: () {
                  final newPosition = position - const Duration(seconds: 15);
                  context.read<AudioBloc>().add(SeekAudio(
                    newPosition < Duration.zero ? Duration.zero : newPosition,
                  ));
                },
                icon: const FaIcon(
                  FontAwesomeIcons.backwardStep,
                  color: Colors.white,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    if (isPlaying) {
                      context.read<AudioBloc>().add(PauseAudio());
                    } else {
                      context.read<AudioBloc>().add(PlayAudio(supplication));
                    }
                  },
                  icon: FaIcon(
                    isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final newPosition = position + const Duration(seconds: 15);
                  context.read<AudioBloc>().add(SeekAudio(
                    newPosition > duration ? duration : newPosition,
                  ));
                },
                icon: const FaIcon(
                  FontAwesomeIcons.forwardStep,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<AudioBloc>().add(ToggleAutoNext());
                },
                icon: FaIcon(
                  FontAwesomeIcons.listOl,
                  color: isAutoNext ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
