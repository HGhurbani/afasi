
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_styles.dart';
import '../bloc/audio_bloc.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accentBlue,
                  AppColors.accentBlue.withOpacity(0.8),
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: FaIcon(
                      FontAwesomeIcons.quran,
                      size: 40,
                      color: AppColors.accentBlue,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'تطبيق مشاري العفاسي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.quran,
                  title: 'القرآن الكريم',
                  onTap: () => _selectCategory(context, 'القرآن الكريم'),
                ),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.music,
                  title: 'الأناشيد',
                  onTap: () => _selectCategory(context, 'الأناشيد'),
                ),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.pray,
                  title: 'الأذكار',
                  onTap: () => _selectCategory(context, 'الأذكار'),
                ),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.handsPraying,
                  title: 'الأدعية',
                  onTap: () => _selectCategory(context, 'الأدعية'),
                ),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.moon,
                  title: 'رمضانيات',
                  onTap: () => _selectCategory(context, 'رمضانيات'),
                ),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.shieldHalved,
                  title: 'الرقية الشرعية',
                  onTap: () => _selectCategory(context, 'الرقية الشرعية'),
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.gear,
                  title: 'الإعدادات',
                  onTap: () => _showSettings(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.info,
                  title: 'حول التطبيق',
                  onTap: () => _showAbout(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.star,
                  title: 'تقييم التطبيق',
                  onTap: () => _rateApp(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: FaIcon(icon, color: AppColors.accentBlue),
      title: Text(title, style: AppStyles.cardSubtitle),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  void _selectCategory(BuildContext context, String category) {
    context.read<AudioBloc>().add(SelectCategory(category));
  }

  void _showSettings(BuildContext context) {
    // Navigate to settings page
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حول التطبيق'),
        content: const Text(
          'تطبيق مشاري العفاسي\n'
          'تطبيق إسلامي شامل يحتوي على القرآن الكريم والأناشيد والأذكار والأدعية\n'
          'الإصدار: 1.0.0\n'
          'المطور: فريق التطوير',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _rateApp(BuildContext context) {
    // Implement app rating functionality
  }
}
