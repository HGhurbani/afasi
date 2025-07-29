
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryLight = Color(0xFF3498DB);
  static const Color primaryDark = Color(0xFF2C3E50);
  static const Color accentBlue = Color(0xFF3498DB);
  static const Color accentBlueDark = Colors.blueGrey;
  
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color infoColor = Colors.blue;
  
  static const Color transparentWhite = Colors.white30;
  static const Color transparentBlack = Colors.black87;
  
  static Color getAccentColor(bool isDarkMode) =>
      isDarkMode ? accentBlueDark : accentBlue;
      
  static Color getPrimaryColor(bool isDarkMode) =>
      isDarkMode ? primaryDark : primaryLight;
}
