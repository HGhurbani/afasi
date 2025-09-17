
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Enhanced styling system with improved Material 3 support
class AppStyles {
  static const String fontFamily = 'Tajawal';
  
  // Typography styles
  static TextStyle getAppBarTitle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle getHeadlineLarge(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
  );
  
  static TextStyle getHeadlineMedium(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
  );
  
  static TextStyle getTitleLarge(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
  );
  
  static TextStyle getTitleMedium(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurface,
  );
  
  static TextStyle getBodyLarge(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Theme.of(context).colorScheme.onSurface,
  );
  
  static TextStyle getBodyMedium(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
  
  static TextStyle getLabelLarge(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurface,
  );
  
  // Card styles
  static TextStyle getCardTitle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Theme.of(context).colorScheme.onSurface,
  );
  
  static TextStyle getCardSubtitle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
  
  // Player styles
  static const TextStyle playerTitle = TextStyle(
    fontFamily: fontFamily,
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );
  
  static const TextStyle playerSubtitle = TextStyle(
    fontFamily: fontFamily,
    color: Colors.white70,
    fontSize: 14,
  );
  
  // Button styles
  static TextStyle getButtonText(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onPrimary,
  );
  
  // Decorations
  static BoxDecoration getCardDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: colorScheme.outline.withOpacity(0.1),
        width: 1,
      ),
    );
  }
  
  static BoxDecoration getElevatedCardDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withOpacity(0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: colorScheme.shadow.withOpacity(0.08),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  static BoxDecoration getGradientDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        colors: [
          colorScheme.primary,
          colorScheme.primary.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  static BoxDecoration getPlayerDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primaryDark,
          AppColors.primaryDark.withOpacity(0.9),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }
  
  // Input decorations
  static InputDecoration getSearchInputDecoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: 'ابحث هنا...',
      hintStyle: TextStyle(
        fontFamily: fontFamily,
        color: colorScheme.onSurfaceVariant,
      ),
      prefixIcon: Icon(
        Icons.search,
        color: colorScheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
  
  // Spacing constants
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 24.0;
}
