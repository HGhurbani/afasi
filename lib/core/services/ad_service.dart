
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';

class AdService {
  static NativeAd? _nativeAd;
  static bool _isNativeAdLoaded = false;

  static bool get isNativeAdLoaded => _isNativeAdLoaded;
  static NativeAd? get nativeAd => _nativeAd;

  static void loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: AdConstants.nativeAdvancedAdUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isNativeAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isNativeAdLoaded = false;
        },
      ),
    );

    _nativeAd?.load();
  }

  static void disposeAd() {
    _nativeAd?.dispose();
    _isNativeAdLoaded = false;
  }
}
