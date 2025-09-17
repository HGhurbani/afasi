import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/di/injection.dart';
import '../core/services/storage_service.dart';
import '../core/constants/app_constants.dart';
import '../features/adhkar_reminder/presentation/pages/adhkar_reminder_page.dart';
import '../features/audio/presentation/pages/audio_page.dart';
import '../features/prayer_times/presentation/pages/prayer_times_page.dart';
import '../features/tasbih/presentation/pages/tasbih_page.dart';
import '../features/wallpapers/cubit/wallpapers_cubit.dart';
import '../features/wallpapers/presentation/pages/wallpapers_page.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _audioFavorites = const <String>[];
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadRewardedAd();
  }

  void _loadFavorites() {
    final favorites = StorageService.getFavorites();
    if (!mounted) {
      return;
    }
    setState(() {
      _audioFavorites = List<String>.from(favorites);
    });
  }

  Future<void> _removeFavorite(String title) async {
    if (!_audioFavorites.contains(title)) {
      return;
    }
    final updatedFavorites = List<String>.from(_audioFavorites)..remove(title);
    setState(() {
      _audioFavorites = updatedFavorites;
    });
    await StorageService.saveFavorites(updatedFavorites);
  }

  Future<void> _clearFavorites() async {
    if (_audioFavorites.isEmpty) {
      return;
    }
    setState(() {
      _audioFavorites = const <String>[];
    });
    await StorageService.saveFavorites(const <String>[]);
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AppConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
        onAdFailedToLoad: (error) => setState(() => _rewardedAd = null),
      ),
    );
  }

  Future<void> _confirmAndShowRewardedAd() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text(
          'يرجى التأكيد بأنك ستشاهد الإعلان لدعم التطبيق والمساعدة في تطويره. هل أنت متأكد؟',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _showRewardedAd();
    }
  }

  void _showRewardedAd() {
    final ad = _rewardedAd;
    if (ad != null) {
      ad.show(onUserEarnedReward: (ad, reward) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('شكراً لدعمك!')));
        _loadRewardedAd();
      });
      _rewardedAd = null;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('الإعلان غير متوفر حالياً.')));
      _loadRewardedAd();
    }
  }

  Future<void> _openQuranAppStore() async {
    final Uri uri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.quran.kareem.islamic');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح الرابط.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final features = <_HomeFeatureCardData>[
      _HomeFeatureCardData(
        title: 'مكتبة الصوتيات',
        description: 'استمع للأذكار والقرآن الكريم والأناشيد والأدعية والرقية الشرعية وغيره.',
        icon: Icons.library_music,
        color: colorScheme.primary,
        onTap: () {
          Navigator.pushNamed(
            context,
            AudioPage.routeName,
            arguments: AudioPageArguments(
              isDarkMode: widget.isDarkMode,
              onToggleTheme: widget.onToggleTheme,
            ),
          ).then((_) => _loadFavorites());
        },
      ),
      _HomeFeatureCardData(
        title: 'الصور والخلفيات',
        description: 'مجموعة من الخلفيات الإسلامية المميزة والمتجددة , تابعها كل يوم.',
        icon: Icons.image,
        color: colorScheme.secondary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => getIt<WallpapersCubit>()..initialize(),
                child: const WallpapersPage(),
              ),
            ),
          );
        },
      ),
      _HomeFeatureCardData(
        title: 'منبه الأذكار',
        description: 'ذكّر نفسك بالأذكار اليومية في الوقت المناسب.',
        icon: Icons.alarm_on,
        color: const Color(0xFFFF9800),
        onTap: () {
          Navigator.pushNamed(context, AdhkarReminderPage.routeName);
        },
      ),
      _HomeFeatureCardData(
        title: 'أوقات الصلاة',
        description: 'تعرف على أوقات الصلاة وفق مدينتك الحالية وتفعيل إشعارات الأذان.',
        icon: Icons.mosque,
        color: const Color(0xFF009688),
        onTap: () {
          Navigator.pushNamed(context, PrayerTimesPage.routeName);
        },
      ),
      _HomeFeatureCardData(
        title: 'المسبحة الإلكترونية',
        description: 'تابع أذكارك اليومية بسهولة.',
        icon: Icons.fingerprint,
        color: const Color(0xFF3F51B5),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TasbihPage()),
          );
        },
      ),
      _HomeFeatureCardData(
        title: 'ادعم التطبيق',
        description: 'ساهم في تطوير التطبيق بمشاهدة إعلان مكافآت , ولا تنسى من عمل هذا بشكل يومي للإستمرار في تطوير التطبيق.',
        icon: Icons.volunteer_activism,
        color: const Color(0xFFE91E63),
        onTap: _confirmAndShowRewardedAd,
      ),
      _HomeFeatureCardData(
        title: 'تطبيق القرآن الكريم',
        description: 'انتقل إلى متجر Play لتحميل التطبيق.',
        icon: Icons.shop,
        color: const Color(0xFF4CAF50),
        onTap: _openQuranAppStore,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تطبيق مشاري العفاسي',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          actions: [
            IconButton(
              onPressed: widget.onToggleTheme,
              tooltip: 'تغيير الوضع',
              icon: Icon(
                widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.white,
              ),
            ),
          ],
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_audioFavorites.isNotEmpty)
                  _FavoritesSection(
                    favorites: _audioFavorites,
                    onRemoveFavorite: _removeFavorite,
                    onClearFavorites: _clearFavorites,
                  ),
                if (_audioFavorites.isNotEmpty) const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: features.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final feature = features[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                feature.color.withOpacity(0.1),
                                feature.color.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: feature.onTap,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: feature.color,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: feature.color.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      feature.icon,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          feature.title,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          feature.description,
                                          style: TextStyle(
                                            fontFamily: 'Tajawal',
                                            fontSize: 14,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_left,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeFeatureCardData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeFeatureCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _FavoritesSection extends StatelessWidget {
  final List<String> favorites;
  final ValueChanged<String> onRemoveFavorite;
  final VoidCallback onClearFavorites;

  const _FavoritesSection({
    required this.favorites,
    required this.onRemoveFavorite,
    required this.onClearFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE91E63).withOpacity(0.1),
              const Color(0xFFE91E63).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'المفضلات الصوتية',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onClearFavorites,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text(
                      'مسح الكل',
                      style: TextStyle(fontFamily: 'Tajawal'),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE91E63),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: favorites
                    .map(
                      (favorite) => Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => onRemoveFavorite(favorite),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    favorite,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 13,
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.close,
                                  size: 16,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
