// lib/managers/app_open_ad_manager.dart

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AppOpenAdManager {
  AppOpenAd? appOpenAd;
  bool isAdAvailable = false;
  bool isShowingAd = false;

  void loadAd() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-7223999276472548/1510060234',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print("تم تحميل إعلان App Open بنجاح.");
          appOpenAd = ad;
          isAdAvailable = true;
        },
        onAdFailedToLoad: (error) {
          print("فشل تحميل إعلان App Open: $error");
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

/// يراقب تغييرات حالة التطبيق (مغلق، بالخلفية، عاد إلى المقدمة، ...)
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
