
import 'package:flutter/material.dart';

/// Enhanced color system with improved dark/light mode support
class AppColors {
  // Primary colors - Brand Blue theme
  static const Color primaryLight = Color(0xFF3498DB);
  static const Color primaryDark = Color(0xFF1F6391);
  static const Color primaryVariantLight = Color(0xFF2C81BA);
  static const Color primaryVariantDark = Color(0xFF3498DB);
  
  // Secondary colors - Blue accents
  static const Color secondaryLight = Color(0xFF1565C0);
  static const Color secondaryDark = Color(0xFF64B5F6);
  
  // Surface and background colors
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Semantic colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Special accent colors
  static const Color accentGold = Color(0xFFFFB300);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF2196F3);
  
  // Text colors
  static const Color textPrimaryLight = Color(0xFF1C1B1F);
  static const Color textPrimaryDark = Color(0xFFE6E1E5);
  static const Color textSecondaryLight = Color(0xFF49454F);
  static const Color textSecondaryDark = Color(0xFFCAC4D0);
  
  // Utility colors
  static const Color transparentWhite = Colors.white30;
  static const Color transparentBlack = Colors.black87;
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  
  // Helper methods for theme-aware colors
  static Color getThemePrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
  
  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }
  
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
  
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }
  
  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
  
  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
  
  // Legacy support methods (deprecated - use Theme.of(context).colorScheme instead)
  @Deprecated('Use Theme.of(context).colorScheme.secondary instead')
  static Color getAccentColor(bool isDarkMode) =>
      isDarkMode ? secondaryDark : secondaryLight;
      
  @Deprecated('Use Theme.of(context).colorScheme.primary instead')
  static Color getPrimaryColor(bool isDarkMode) =>
      isDarkMode ? primaryDark : primaryLight;
}
