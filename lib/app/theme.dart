import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const Color primaryColor = Color(0xFF3498DB); // Brand Blue
  static const Color primaryVariant = Color(0xFF2C81BA);
  static const Color secondaryColor = Color(0xFF1565C0); // Blue
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  
  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFF1F6391);
  static const Color darkPrimaryVariant = Color(0xFF3498DB);
  static const Color darkSecondaryColor = Color(0xFF64B5F6);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkBackgroundColor = Color(0xFF121212);
  
  // Accent colors for both themes
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentGold = Color(0xFFFFB300);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF388E3C);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Tajawal',
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          onPrimary: Colors.white,
          primaryContainer: primaryColor.withOpacity(0.1),
          onPrimaryContainer: primaryVariant,
          secondary: secondaryColor,
          onSecondary: Colors.white,
          secondaryContainer: secondaryColor.withOpacity(0.1),
          onSecondaryContainer: secondaryColor,
          surface: surfaceColor,
          onSurface: const Color(0xFF1C1B1F),
          background: backgroundColor,
          onBackground: const Color(0xFF1C1B1F),
          error: errorColor,
          onError: Colors.white,
          outline: const Color(0xFF79747E),
          surfaceVariant: const Color(0xFFE7E0EC),
          onSurfaceVariant: const Color(0xFF49454F),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: surfaceColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1B1F),
          ),
          contentTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            color: Color(0xFF49454F),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: primaryVariant,
          contentTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Tajawal',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: darkPrimaryVariant,
          onPrimary: Colors.white,
          primaryContainer: darkPrimaryColor,
          onPrimaryContainer: const Color(0xFF81C784),
          secondary: darkSecondaryColor,
          onSecondary: const Color(0xFF1A1C1E),
          secondaryContainer: const Color(0xFF1976D2),
          onSecondaryContainer: const Color(0xFFBBDEFB),
          surface: darkSurfaceColor,
          onSurface: const Color(0xFFE6E1E5),
          background: darkBackgroundColor,
          onBackground: const Color(0xFFE6E1E5),
          error: const Color(0xFFFFB4AB),
          onError: const Color(0xFF690005),
          outline: const Color(0xFF938F99),
          surfaceVariant: const Color(0xFF49454F),
          onSurfaceVariant: const Color(0xFFCAC4D0),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: darkSurfaceColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkPrimaryVariant,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: darkSecondaryColor,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurfaceColor,
          labelStyle: const TextStyle(color: Color(0xFFCAC4D0)),
          prefixIconColor: const Color(0xFFCAC4D0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF938F99)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF938F99)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: darkPrimaryVariant, width: 2),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: darkSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE6E1E5),
          ),
          contentTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            color: Color(0xFFCAC4D0),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: darkPrimaryVariant,
          contentTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  static MaterialColor createMaterialColor(Color color) {
    final List<double> strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

