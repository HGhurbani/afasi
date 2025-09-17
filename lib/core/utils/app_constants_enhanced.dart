import 'package:flutter/material.dart';

/// Enhanced constants for improved app experience
class AppConstantsEnhanced {
  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  
  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  
  // Elevation
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 12.0;
  
  // Icon sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  
  // Typography sizes
  static const double textXS = 12.0;
  static const double textSM = 14.0;
  static const double textMD = 16.0;
  static const double textLG = 18.0;
  static const double textXL = 20.0;
  static const double textXXL = 24.0;
  static const double textXXXL = 32.0;
  
  // Islamic colors palette
  static const Color islamicGreen = Color(0xFF2E7D32);
  static const Color islamicGold = Color(0xFFFFB300);
  static const Color islamicBlue = Color(0xFF1565C0);
  static const Color islamicTeal = Color(0xFF00695C);
  static const Color islamicBrown = Color(0xFF5D4037);
  
  // Prayer times colors
  static const Map<String, Color> prayerColors = {
    'الفجر': Color(0xFF1976D2),
    'الشروق': Color(0xFFFFB300),
    'الظهر': Color(0xFFFF9800),
    'العصر': Color(0xFFFF5722),
    'المغرب': Color(0xFF9C27B0),
    'العشاء': Color(0xFF3F51B5),
  };
  
  // Feature colors
  static const Map<String, Color> featureColors = {
    'القرآن الكريم': Color(0xFF2E7D32),
    'الأذكار': Color(0xFF1565C0),
    'الأدعية': Color(0xFF00695C),
    'الأناشيد': Color(0xFF7B1FA2),
    'رمضانيات': Color(0xFFFFB300),
    'الرقية الشرعية': Color(0xFF5D4037),
    'المفضلة': Color(0xFFE91E63),
  };
  
  // Status colors with semantic meaning
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Accessibility
  static const double minimumTouchTarget = 48.0;
  static const double accessibleTextSize = 16.0;
  
  // Performance
  static const int maxCacheSize = 100;
  static const Duration cacheExpiration = Duration(hours: 24);
  
  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  // Arabic typography weights (optimized for Tajawal font)
  static const FontWeight arabicLight = FontWeight.w300;
  static const FontWeight arabicRegular = FontWeight.w400;
  static const FontWeight arabicMedium = FontWeight.w500;
  static const FontWeight arabicSemiBold = FontWeight.w600;
  static const FontWeight arabicBold = FontWeight.w700;
  static const FontWeight arabicExtraBold = FontWeight.w800;
  
  // RTL-specific constants
  static const TextDirection appTextDirection = TextDirection.rtl;
  static const String appLocale = 'ar';
  static const String appCountryCode = 'AE';
  
  // Islamic app specific
  static const List<String> dhikrCategories = [
    'أذكار الصباح',
    'أذكار المساء',
    'أذكار النوم',
    'أذكار الصلاة',
    'أذكار متنوعة',
  ];
  
  static const List<String> duaCategories = [
    'أدعية من القرآن',
    'أدعية من السنة',
    'أدعية المناسبات',
    'أدعية الأنبياء',
  ];
  
  // Audio player constants
  static const Duration seekDuration = Duration(seconds: 10);
  static const double defaultVolume = 0.8;
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  
  // Notification constants
  static const String notificationChannelId = 'afasi_notifications';
  static const String notificationChannelName = 'تنبيهات التطبيق';
  static const String notificationChannelDescription = 'تنبيهات الأذكار وأوقات الصلاة';
  
  // App metadata
  static const String appName = 'تطبيق العفاسي';
  static const String appDescription = 'تطبيق إسلامي شامل للأذكار والأدعية والقرآن الكريم';
  static const String developerName = 'فريق التطوير';
  static const String supportEmail = 'support@afasi.app';
  static const String privacyPolicyUrl = 'https://afasi.app/privacy';
  static const String termsOfServiceUrl = 'https://afasi.app/terms';
}
