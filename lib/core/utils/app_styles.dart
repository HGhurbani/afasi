
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  static const String fontFamily = 'Tajawal';
  
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: fontFamily,
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle cardTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle playerTitle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  
  static const TextStyle playerSubtitle = TextStyle(
    color: Colors.white70,
    fontSize: 12,
  );
  
  static const TextStyle buttonText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  
  static BoxDecoration getCardDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [
          Theme.of(context).cardColor,
          Theme.of(context).cardColor.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  static BoxDecoration getGradientDecoration(Color primaryColor) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          primaryColor,
          primaryColor.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }
}
