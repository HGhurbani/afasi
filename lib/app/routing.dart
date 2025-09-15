import 'package:flutter/material.dart';
import '../features/adhkar_reminder/presentation/pages/adhkar_reminder_page.dart';
import '../features/prayer_times/presentation/pages/prayer_times_page.dart';
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
