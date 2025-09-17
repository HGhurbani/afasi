import 'package:cached_network_image/cached_network_image.dart';
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
            final colorScheme = Theme.of(context).colorScheme;
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
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: colorScheme.onSurface,
                        ),
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

            return Container(
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
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: state.images.length,
                itemBuilder: (context, index) {
                  final img = state.images[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
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
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: img.imageUrl,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) {
                              return Container(
                                color: colorScheme.surfaceVariant,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'جاري التحميل...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Container(
                                color: colorScheme.surfaceVariant,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      color: colorScheme.onSurfaceVariant,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'خطأ في التحميل',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Gradient overlay for better text visibility
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      img.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Tajawal',
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final RoundedRectangleBorder actionButtonShape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final ButtonStyle actionButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: colorScheme.surfaceVariant,
      foregroundColor: colorScheme.onSurfaceVariant,
      elevation: 0,
      shape: actionButtonShape,
      minimumSize: const Size.fromHeight(48),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.img.title)),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.img.imageUrl,
                  fit: BoxFit.contain,
                  progressIndicatorBuilder:
                      (context, url, downloadProgress) => SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  ),
                  errorWidget: (context, url, error) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 64,
                      ),
                      SizedBox(height: 8),
                      Text('تعذر تحميل الصورة'),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.img.title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Tooltip(
                            message: 'تحميل',
                            child: ElevatedButton.icon(
                              onPressed: () => _handleDownload(context),
                              icon: const Icon(Icons.download, size: 22),
                              label: const Text(
                                'تحميل',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: actionButtonStyle.copyWith(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Tooltip(
                            message: 'مشاركة',
                            child: ElevatedButton.icon(
                              onPressed: () => _handleShare(context),
                              icon: const Icon(Icons.share, size: 22),
                              label: const Text(
                                'مشاركة',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: actionButtonStyle.copyWith(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Tooltip(
                            message: 'تعيين كخلفية',
                            child: ElevatedButton.icon(
                              onPressed: () => _showWallpaperOptions(context),
                              icon: const Icon(Icons.wallpaper, size: 22),
                              label: const Text(
                                'خلفية',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: actionButtonStyle.copyWith(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
