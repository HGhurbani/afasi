
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/models/supplication.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_styles.dart';

class SupplicationCard extends StatelessWidget {
  final Supplication supplication;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onDownload;
  final VoidCallback onToggleFavorite;

  const SupplicationCard({
    Key? key,
    required this.supplication,
    required this.isPlaying,
    required this.onPlay,
    required this.onDownload,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(
                    supplication.icon,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    supplication.title,
                    style: AppStyles.cardTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: isPlaying ? FontAwesomeIcons.pause : FontAwesomeIcons.play,
                  label: isPlaying ? 'إيقاف' : 'تشغيل',
                  onPressed: onPlay,
                  isPrimary: true,
                ),
                _buildActionButton(
                  icon: FontAwesomeIcons.download,
                  label: 'تحميل',
                  onPressed: onDownload,
                ),
                _buildActionButton(
                  icon: FontAwesomeIcons.heart,
                  label: 'مفضلة',
                  onPressed: onToggleFavorite,
                ),
                _buildActionButton(
                  icon: FontAwesomeIcons.shareAlt,
                  label: 'مشاركة',
                  onPressed: () => _shareSupplication(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primaryColor : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: FaIcon(
              icon,
              color: isPrimary ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _shareSupplication(BuildContext context) {
    // Implement share functionality
  }
}
