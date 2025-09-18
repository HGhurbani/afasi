import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants/app_constants.dart';

class NativeAdWidget extends StatefulWidget {
  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AppConstants.nativeAdUnitId, // Production Ad Unit ID
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Native Ad failed to load: $error');
        },
      ),
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _nativeAd == null) {
      return Container();
    }
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}

final AppOpenAdManager appOpenAdManager = AppOpenAdManager();

class AppOpenAdManager {
  AppOpenAd? appOpenAd;
  bool isAdAvailable = false;
  bool isShowingAd = false;
  bool _isLoadingAd = false;

  void loadAd() {
    if (isAdAvailable || isShowingAd || _isLoadingAd) {
      print("تجاهل تحميل إعلان App Open لأن هناك حملة نشطة.");
      return;
    }
    _isLoadingAd = true;
    AppOpenAd.load(
      adUnitId: AppConstants.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print("تم تحميل إعلان App Open بنجاح.");
          appOpenAd = ad;
          isAdAvailable = true;
          _isLoadingAd = false;
        },
        onAdFailedToLoad: (error) {
          print("فشل تحميل إعلان App Open: $error");
          _isLoadingAd = false;
        },
      ),
    );
  }

  void showAdIfAvailable() {
    if (!isAdAvailable || appOpenAd == null) {
      print("إعلان App Open غير متوفر حالياً، جاري التحميل...");
      loadAd();
      return;
    }
    if (isShowingAd) return;

    appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        isShowingAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        print("تم إغلاق إعلان App Open.");
        isShowingAd = false;
        appOpenAd = null;
        isAdAvailable = false;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print("فشل عرض إعلان App Open: $error");
        isShowingAd = false;
        appOpenAd = null;
        isAdAvailable = false;
        loadAd();
      },
    );
    appOpenAd!.show();
  }
}

class AppLifecycleReactor extends WidgetsBindingObserver {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor(this.appOpenAdManager);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      appOpenAdManager.showAdIfAvailable();
    }
  }
}

