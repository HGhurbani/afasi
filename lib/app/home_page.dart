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

    final features = <_HomeFeatureCardData>[
      _HomeFeatureCardData(
        title: 'مكتبة الصوتيات',
        description: 'استمع للأذكار والقرآن الكريم والأناشيد والأدعية والرقية الشرعية وغيره.',
        icon: Icons.library_music,
        color: theme.primaryColor,
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
        color: Colors.purple,
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
        color: Colors.orange,
        onTap: () {
          Navigator.pushNamed(context, AdhkarReminderPage.routeName);
        },
      ),
      _HomeFeatureCardData(
        title: 'أوقات الصلاة',
        description: 'تعرف على أوقات الصلاة وفق مدينتك الحالية وتفعيل إشعارات الأذان.',
        icon: Icons.mosque,
        color: Colors.teal,
        onTap: () {
          Navigator.pushNamed(context, PrayerTimesPage.routeName);
        },
      ),
      _HomeFeatureCardData(
        title: 'المسبحة الإلكترونية',
        description: 'تابع أذكارك اليومية بسهولة.',
        icon: Icons.fingerprint,
        color: Colors.indigo,
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
        color: Colors.redAccent,
        onTap: _confirmAndShowRewardedAd,
      ),
      _HomeFeatureCardData(
        title: 'تطبيق القرآن الكريم',
        description: 'انتقل إلى متجر Play لتحميل التطبيق.',
        icon: Icons.shop,
        color: Colors.green,
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
        body: Padding(
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
                    return Material(
                      color: feature.color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: feature.onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: feature.color,
                              child: Icon(feature.icon, color: Colors.white),
                            ),
                            title: Text(
                              feature.title,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              feature.description,
                              style: const TextStyle(fontFamily: 'Tajawal'),
                            ),
                            trailing: const Icon(Icons.chevron_left),
                            onTap: feature.onTap,
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'المفضلات الصوتية',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onClearFavorites,
                  child: const Text('مسح الكل'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: favorites
                  .map(
                    (favorite) => InputChip(
                      label: Text(
                        favorite,
                        style: const TextStyle(fontFamily: 'Tajawal'),
                      ),
                      onDeleted: () => onRemoveFavorite(favorite),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
