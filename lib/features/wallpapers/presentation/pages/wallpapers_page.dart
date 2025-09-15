import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:afasi/features/wallpapers/cubit/wallpapers_cubit.dart';
import 'package:afasi/features/wallpapers/data/models/blog_image.dart';

class WallpapersPage extends StatelessWidget {
  const WallpapersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الصور والخلفيات',
            style: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
          ),
        ),
        body: BlocBuilder<WallpapersCubit, WallpapersState>(
          builder: (context, state) {
            if (state.status == WallpapersStatus.loading ||
                state.status == WallpapersStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == WallpapersStatus.failure) {
              final message = state.errorMessage ?? '❌ حدث خطأ غير متوقع';
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'Tajawal'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<WallpapersCubit>().loadWallpapers(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state.images.isEmpty) {
              return const Center(child: Text('لا توجد صور حالياً'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                final img = state.images[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<WallpapersCubit>(),
                          child: FullImageView(img: img),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(img.imageUrl, fit: BoxFit.cover),
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<WallpapersCubit, WallpapersState>(
          buildWhen: (previous, current) =>
              previous.listBannerAd != current.listBannerAd,
          builder: (context, state) {
            final ad = state.listBannerAd;
            if (ad == null) {
              return const SizedBox.shrink();
            }
            return SizedBox(
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            );
          },
        ),
      ),
    );
  }
}

class FullImageView extends StatefulWidget {
  const FullImageView({required this.img, super.key});

  final BlogImage img;

  @override
  State<FullImageView> createState() => _FullImageViewState();
}

class _FullImageViewState extends State<FullImageView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<WallpapersCubit>();
    cubit
      ..resetActionCounter()
      ..loadDetailBannerAd()
      ..loadInterstitialAd();
  }

  @override
  void dispose() {
    context.read<WallpapersCubit>().clearDetailBanner();
    super.dispose();
  }

  Future<void> _handleDownload(BuildContext context) async {
    final result =
        await context.read<WallpapersCubit>().downloadImage(widget.img.imageUrl);
    if (result.hasMessage) {
      _showSnack(context, result.message);
    }
  }

  Future<void> _handleShare(BuildContext context) async {
    final result = await context.read<WallpapersCubit>().shareImage(widget.img);
    if (!result.success && result.hasMessage) {
      _showSnack(context, result.message);
    }
  }

  Future<void> _handleSetWallpaper(
      BuildContext context, Future<WallpapersActionResult> future) async {
    final result = await future;
    if (result.hasMessage) {
      _showSnack(context, result.message);
    }
  }

  void _showSnack(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showWallpaperOptions(BuildContext context) {
    final cubit = context.read<WallpapersCubit>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('الشاشة الرئيسية'),
              onTap: () {
                Navigator.pop(sheetContext);
                _handleSetWallpaper(
                  context,
                  cubit.setHomeWallpaper(widget.img.imageUrl),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('شاشة القفل'),
              onTap: () {
                Navigator.pop(sheetContext);
                _handleSetWallpaper(
                  context,
                  cubit.setLockWallpaper(widget.img.imageUrl),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.smartphone),
              title: const Text('كلا الشاشتين'),
              onTap: () {
                Navigator.pop(sheetContext);
                _handleSetWallpaper(
                  context,
                  cubit.setBothWallpaper(widget.img.imageUrl),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.img.title)),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.network(widget.img.imageUrl),
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _handleDownload(context),
                    icon: const Icon(Icons.download),
                    label: const Text('تحميل'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _handleShare(context),
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showWallpaperOptions(context),
                    icon: const Icon(Icons.wallpaper),
                    label: const Text('تعيين خلفية'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<WallpapersCubit, WallpapersState>(
              buildWhen: (previous, current) =>
                  previous.detailBannerAd != current.detailBannerAd,
              builder: (context, state) {
                final ad = state.detailBannerAd;
                if (ad == null) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: ad.size.height.toDouble(),
                  child: AdWidget(ad: ad),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
