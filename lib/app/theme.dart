import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF3498DB);
  static const Color darkPrimaryColor = Color(0xFF2C3E50);

  static ThemeData get lightTheme => ThemeData(
        fontFamily: 'Tajawal',
        primaryColor: primaryColor,
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Tajawal'),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: createMaterialColor(primaryColor),
        ).copyWith(
          secondary: primaryColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: primaryColor,
            backgroundColor: Colors.white,
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData.dark().copyWith(
        primaryColor: darkPrimaryColor,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Tajawal'),
        appBarTheme: AppBarTheme(
          backgroundColor: darkPrimaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: createMaterialColor(darkPrimaryColor),
        ).copyWith(
          secondary: darkPrimaryColor,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
          prefixIconColor: Colors.white,
          border: OutlineInputBorder(),
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Colors.black87,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Tajawal',
            fontSize: 20,
          ),
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Tajawal',
            fontSize: 16,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade300,
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
