import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final String _appVersion = '1.0.0';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح الرابط')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الإعدادات',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.background,
                colorScheme.surface,
              ],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // App info section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.settings,
                        size: 48,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'تطبيق مشاري العفاسي',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الإصدار $_appVersion',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Settings sections
              _buildSettingsSection(
                context,
                title: 'الحساب والتطبيق',
                items: [
                  _SettingsItem(
                    icon: Icons.star,
                    title: 'قيّم التطبيق',
                    subtitle: 'شاركنا رأيك في متجر Google Play',
                    onTap: () => _launchUrl('https://play.google.com/store/apps/details?id=com.azkar.doaa.alafasi'),
                  ),
                  _SettingsItem(
                    icon: Icons.share,
                    title: 'مشاركة التطبيق',
                    subtitle: 'شارك التطبيق مع الأصدقاء والعائلة',
                    onTap: () {
                      // Implement share functionality
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.volunteer_activism,
                    title: 'دعم التطبيق',
                    subtitle: 'ساعدنا في تطوير التطبيق',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to support section
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildSettingsSection(
                context,
                title: 'الخصوصية والأمان',
                items: [
                  _SettingsItem(
                    icon: Icons.privacy_tip,
                    title: 'سياسة الخصوصية',
                    subtitle: 'اطلع على سياسة حماية بياناتك',
                    onTap: () {
                      // Show privacy policy
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.security,
                    title: 'شروط الاستخدام',
                    subtitle: 'اقرأ شروط وأحكام الاستخدام',
                    onTap: () {
                      // Show terms of service
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildSettingsSection(
                context,
                title: 'حول التطبيق',
                items: [
                  _SettingsItem(
                    icon: Icons.info,
                    title: 'معلومات التطبيق',
                    subtitle: 'الإصدار $_appVersion',
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.help,
                    title: 'تعليمات الاستخدام',
                    subtitle: 'تعلم كيفية استخدام التطبيق',
                    onTap: () {
                      // Show help
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Footer
              Center(
                child: Text(
                  'تم تطويره بعناية وحب للمجتمع الإسلامي',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items.map((item) => _buildSettingsItem(context, item)).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSettingsItem(BuildContext context, _SettingsItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'تطبيق أذكار وأدعية العفاسي',
      applicationVersion: _appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.mosque,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'تطبيق إسلامي شامل يحتوي على مجموعة من الميزات المفيدة للمسلمين',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
