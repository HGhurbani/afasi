// lib/managers/ad_manager.dart

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:user_messaging_platform/user_messaging_platform.dart' as UMP;
import 'package:flutter/material.dart';

class AdManager {
  static BannerAd? bannerAd;
  static InterstitialAd? interstitialAd;
  static RewardedAd? rewardedAd;
  static int usageCounter = 0; // لعدّ عدد مرات تشغيل الصوت لإظهار الإعلانات

  /// تهيئة موافقة المستخدم لإعلانات AdMob (UMP)
  static Future<void> initConsentForAds() async {
    final UMP.ConsentRequestParameters params = UMP.ConsentRequestParameters(
      // مثلاً إذا عندك إعدادات إضافية
    );
    try {
      // طلب أحدث معلومات الموافقة
      var consentInfo = await UMP.UserMessagingPlatform.instance
          .requestConsentInfoUpdate(params);

      // التحقق ما إذا كانت الموافقة مطلوبة
      if (consentInfo.consentStatus == UMP.ConsentStatus.required) {
        // عرض نموذج الموافقة
        consentInfo =
            await UMP.UserMessagingPlatform.instance.showConsentForm();

        // بعد إغلاق النموذج، يمكن التحقق من النتيجة
        if (consentInfo.consentStatus == UMP.ConsentStatus.obtained) {
          print("حصلنا على موافقة مخصصة (Personalized Ads).");
        } else {
          print("المستخدم لم يمنح موافقة مخصصة.");
        }
      } else if (consentInfo.consentStatus == UMP.ConsentStatus.obtained) {
        // إذا كانت الموافقة موجودة مسبقًا
        print("موافقة مخصصة موجودة مسبقًا.");
      } else if (consentInfo.consentStatus == UMP.ConsentStatus.notRequired) {
        // إذا كانت الموافقة غير مطلوبة
        print("لا حاجة لعرض نموذج الموافقة.");
      } else {
        // أي حالة أخرى مثل unknown أو denied
        print("حالة الموافقة الحالية: ${consentInfo.consentStatus}");
      }
    } catch (e) {
      print("خطأ أثناء تهيئة موافقة الإعلانات: $e");
    }
  }

  /// تهيئة مكتبة إعلانات Google Mobile Ads
  static Future<void> initializeAds() async {
    await MobileAds.instance.initialize();
  }

  /// تحميل إعلان البانر
  static void loadBannerAd({
    required void Function(void) onBannerLoaded,
    required void Function(Ad, LoadAdError) onBannerFailed,
  }) {
    bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-7223999276472548/9615774793',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onBannerLoaded.call(ad),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onBannerFailed.call(ad, error);
        },
      ),
    );
    bannerAd?.load();
  }

  /// تحميل إعلان انتقالي (Interstitial)
  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-7223999276472548/6569146925',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => interstitialAd = ad,
        onAdFailedToLoad: (error) => interstitialAd = null,
      ),
    );
  }

  static void showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
      interstitialAd = null;
      loadInterstitialAd(); // إعادة التحميل
    }
  }

  /// تحميل إعلان مكافآت
  static void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-7223999276472548/7762749023',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => rewardedAd = ad,
        onAdFailedToLoad: (error) => rewardedAd = null,
      ),
    );
  }

  static void showRewardedAd(BuildContext context) {
    if (rewardedAd != null) {
      rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('شكراً لدعمك!')),
          );
          loadRewardedAd(); // إعادة التحميل بعد العرض
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الإعلان غير متوفر حالياً.')),
      );
    }
  }

  /// التحقق من الاستخدام وإظهار الإعلان الانتقالي بعد عدد محدد من المرات
  static void checkAndShowInterstitialAd() {
    usageCounter++;
    if (usageCounter >= 5 && interstitialAd != null) {
      showInterstitialAd();
      usageCounter = 0;
    }
  }
}
