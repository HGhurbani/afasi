import 'package:flutter/material.dart';
import '../features/adhkar_reminder/presentation/pages/adhkar_reminder_page.dart';
import '../features/audio/presentation/pages/audio_page.dart';
import '../features/audio/presentation/pages/privacy_policy_page.dart';
import 'usage_instructions_page.dart';
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
      case PrivacyPolicyPage.routeName:
        return MaterialPageRoute(
            builder: (_) => const PrivacyPolicyPage());
      case UsageInstructionsPage.routeName:
        return MaterialPageRoute(
            builder: (_) => const UsageInstructionsPage());
      case AudioPage.routeName:
        final args = settings.arguments;
        if (args is AudioPageArguments) {
          return MaterialPageRoute(
            builder: (_) => AudioPage(
              isDarkMode: args.isDarkMode,
              onToggleTheme: args.onToggleTheme,
            ),
          );
        }
        throw ArgumentError('AudioPage requires AudioPageArguments.');
      default:
        return null;
    }
  }
}
