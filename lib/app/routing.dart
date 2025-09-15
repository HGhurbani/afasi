import 'package:flutter/material.dart';
import '../features/adhkar/adhkar_reminder_page.dart';
import '../features/adhan/prayer_times_page.dart';
import '../features/settings/settings_page.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AdhkarReminderPage.routeName:
        return MaterialPageRoute(
            builder: (_) => const AdhkarReminderPage());
      case PrayerTimesPage.routeName:
        return MaterialPageRoute(
            builder: (_) => const PrayerTimesPage());
      case SettingsPage.routeName:
        return MaterialPageRoute(
            builder: (_) => const SettingsPage());
      default:
        return null;
    }
  }
}
