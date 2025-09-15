
class AppConstants {
  // Ad Unit IDs
  static const String bannerAdUnitId = 'ca-app-pub-7223999276472548/9615774793';
  static const String interstitialAdUnitId = 'ca-app-pub-7223999276472548/6569146925';
  static const String rewardedAdUnitId = 'ca-app-pub-7223999276472548/7762749023';
  static const String nativeAdUnitId = 'ca-app-pub-7223999276472548/6597309308';
  static const String appOpenAdUnitId = 'ca-app-pub-7223999276472548/1510060234';
  
  // Audio Constants
  static const String audioChannelId = 'com.afasi.audio';
  static const String audioChannelName = 'Audio Playback';
  
  // Preferences Keys
  static const String lastCategoryKey = 'lastCategory';
  static const String favoritesKey = 'favorites';
  static const String isDarkModeKey = 'isDarkMode';
  
  // Default Values
  static const String defaultCategory = "الأذكار";
  static const int interstitialAdFrequency = 5;
  static const int autoScaleInstances = 80;
  
  // Timing
  static const Duration seekDuration = Duration(seconds: 10);
  static const Duration loadingDelay = Duration(seconds: 1);
  
  // File Paths
  static const String assetsAudioPath = 'assets/audio/';
  static const String assetsTextsPath = 'assets/texts/';
  static const String assetsFontsPath = 'assets/fonts/';
}
