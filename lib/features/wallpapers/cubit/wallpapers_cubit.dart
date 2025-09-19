import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

import 'package:afasi/core/constants/app_constants.dart';
import 'package:afasi/features/wallpapers/data/models/blog_image.dart';
import 'package:afasi/features/wallpapers/data/services/wallpapers_service.dart';

part 'wallpapers_state.dart';

class WallpapersCubit extends Cubit<WallpapersState> {
  WallpapersCubit({required WallpapersService service})
      : _service = service,
        super(const WallpapersState());

  final WallpapersService _service;
  InterstitialAd? _interstitialAd;
  int _actionCounter = 0;

  void initialize() {
    loadWallpapers();
    loadListBannerAd();
  }

  Future<void> loadWallpapers() async {
    emit(state.copyWith(status: WallpapersStatus.loading, errorMessage: null));
    try {
      final cachedImages = await _service.loadCachedWallpapers();
      if (cachedImages.isNotEmpty) {
        emit(state.copyWith(
          status: WallpapersStatus.success,
          images: cachedImages,
          errorMessage: null,
        ));
      }

      final images = await _service.fetchWallpapers();
      emit(state.copyWith(
        status: WallpapersStatus.success,
        images: images,
        errorMessage: null,
      ));
    } on WallpapersException catch (error) {
      if (state.images.isNotEmpty) {
        emit(state.copyWith(
          status: WallpapersStatus.success,
          errorMessage: error.message,
        ));
      } else {
        emit(state.copyWith(
          status: WallpapersStatus.failure,
          errorMessage: error.message,
        ));
      }
    } catch (error) {
      const fallbackMessage = 'تعذر تحميل الخلفيات. الرجاء المحاولة لاحقاً.';
      if (state.images.isNotEmpty) {
        emit(state.copyWith(
          status: WallpapersStatus.success,
          errorMessage: fallbackMessage,
        ));
      } else {
        emit(state.copyWith(
          status: WallpapersStatus.failure,
          errorMessage: fallbackMessage,
        ));
      }
    }
  }

  void loadListBannerAd() {
    state.listBannerAd?.dispose();
    // Clear current banner from state immediately to avoid rendering a disposed/unloaded Ad
    emit(state.copyWith(listBannerAd: null));
    BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (isClosed) {
            ad.dispose();
            return;
          }
          emit(state.copyWith(listBannerAd: ad as BannerAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!isClosed) {
            emit(state.copyWith(listBannerAd: null));
          }
        },
      ),
    )..load();
  }

  void loadDetailBannerAd() {
    state.detailBannerAd?.dispose();
    // Clear current detail banner from state immediately to avoid rendering a disposed/unloaded Ad
    emit(state.copyWith(detailBannerAd: null));
    BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (isClosed) {
            ad.dispose();
            return;
          }
          emit(state.copyWith(detailBannerAd: ad as BannerAd));
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!isClosed) {
            emit(state.copyWith(detailBannerAd: null));
          }
        },
      ),
    )..load();
  }

  void clearDetailBanner() {
    state.detailBannerAd?.dispose();
    emit(state.copyWith(detailBannerAd: null));
  }

  void loadInterstitialAd() {
    _interstitialAd?.dispose();
    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void resetActionCounter() {
    _actionCounter = 0;
  }

  Future<WallpapersActionResult> downloadImage(String url) async {
    _maybeShowInterstitialAd();

    final hasPermission = await _requestExtendedStoragePermission();
    if (!hasPermission) {
      return const WallpapersActionResult.failure('📛 يجب منح إذن التخزين أولاً');
    }

    try {
      final cachedFile = await _service.getCachedImageFile(url);
      final sourceFile =
          cachedFile ?? await _service.ensureImageFile(url);
      final directory = Directory('/storage/emulated/0/Pictures/Alafasi');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      await sourceFile.copy(
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      return const WallpapersActionResult.success(
        '✅ تم حفظ الصورة في المعرض (مجلد Alafasi)',
      );
    } on WallpapersException catch (error) {
      return WallpapersActionResult.failure('❌ فشل حفظ الصورة: ${error.message}');
    } catch (error) {
      return WallpapersActionResult.failure('❌ فشل حفظ الصورة: $error');
    }
  }

  Future<WallpapersActionResult> shareImage(BlogImage image) async {
    _maybeShowInterstitialAd();

    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      return const WallpapersActionResult.failure('📛 يجب منح إذن التخزين أولاً');
    }

    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        return const WallpapersActionResult.failure('❌ تعذر الوصول إلى مجلد التخزين');
      }
      final cachedFile = await _service.getCachedImageFile(image.imageUrl);
      final sourceFile =
          cachedFile ?? await _service.ensureImageFile(image.imageUrl);
      final file = await sourceFile.copy(
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        text: image.title.trim().isNotEmpty
            ? image.title
            : 'صورة رائعة من التطبيق',
      );
      return const WallpapersActionResult.success('');
    } on WallpapersException catch (error) {
      return WallpapersActionResult.failure('❌ فشل مشاركة الصورة: ${error.message}');
    } catch (error) {
      return WallpapersActionResult.failure('❌ فشل مشاركة الصورة: $error');
    }
  }

  Future<WallpapersActionResult> setHomeWallpaper(String url) =>
      _setWallpaper(url, WallpaperManagerFlutter.HOME_SCREEN);

  Future<WallpapersActionResult> setLockWallpaper(String url) =>
      _setWallpaper(url, WallpaperManagerFlutter.LOCK_SCREEN);

  Future<WallpapersActionResult> setBothWallpaper(String url) =>
      _setWallpaper(url, WallpaperManagerFlutter.BOTH_SCREENS);

  Future<WallpapersActionResult> _setWallpaper(
      String url, int location) async {
    _maybeShowInterstitialAd();

    final hasPermission = await _requestImagePermission();
    if (!hasPermission) {
      return const WallpapersActionResult.failure('يجب منح إذن الصور أولاً');
    }

    try {
      final cachedFile = await _service.getCachedImageFile(url);
      final file = cachedFile ?? await _service.ensureImageFile(url);

      await WallpaperManagerFlutter().setwallpaperfromFile(file, location);
      return const WallpapersActionResult.success('✅ تم تعيين الخلفية بنجاح');
    } on WallpapersException catch (error) {
      return WallpapersActionResult.failure(
        '❌ فشل تعيين الخلفية: ${error.message}',
      );
    } catch (error) {
      return WallpapersActionResult.failure('❌ فشل تعيين الخلفية: $error');
    }
  }

  Future<bool> _requestExtendedStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    if (await Permission.manageExternalStorage.isGranted ||
        await Permission.photos.isGranted ||
        await Permission.mediaLibrary.isGranted) {
      return true;
    }

    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) {
      return true;
    }

    if (await Permission.photos.request().isGranted) {
      return true;
    }

    if (await Permission.mediaLibrary.request().isGranted) {
      return true;
    }

    if (await Permission.storage.request().isGranted) {
      return true;
    }

    return false;
  }

  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    if (await Permission.photos.isGranted) {
      return true;
    }

    final status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<bool> _requestImagePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    if (await Permission.photos.isGranted ||
        await Permission.mediaLibrary.isGranted) {
      return true;
    }

    if (await Permission.photos.request().isGranted) {
      return true;
    }

    if (await Permission.mediaLibrary.request().isGranted) {
      return true;
    }

    if (await Permission.storage.request().isGranted) {
      return true;
    }

    return false;
  }

  void _maybeShowInterstitialAd() {
    _actionCounter++;
    if (_actionCounter >= 3 && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd!.dispose();
      _interstitialAd = null;
      _actionCounter = 0;
      loadInterstitialAd();
    }
  }

  @override
  Future<void> close() {
    state.listBannerAd?.dispose();
    state.detailBannerAd?.dispose();
    _interstitialAd?.dispose();
    return super.close();
  }
}
