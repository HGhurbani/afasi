import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/services/storage_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadFavorites();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final features = <_HomeFeatureCardData>[
      _HomeFeatureCardData(
        title: 'مكتبة الصوتيات',
        description: 'استمع للقرآن الكريم والأناشيد والأدعية.',
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
        description: 'مجموعة من الخلفيات الإسلامية المميزة.',
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
        description: 'تعرف على أوقات الصلاة وفق مدينتك الحالية.',
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
                child: GridView.builder(
                  itemCount: features.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    return _FeatureCard(feature: feature);
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

class _FeatureCard extends StatelessWidget {
  final _HomeFeatureCardData feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: feature.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: feature.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: feature.color.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  backgroundColor: feature.color,
                  child: Icon(feature.icon, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                feature.title,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Tajawal',
                      ) ??
                      const TextStyle(
                        fontFamily: 'Tajawal',
                      ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: TextButton(
                  onPressed: feature.onTap,
                  child: const Text('فتح'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
