import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../core/di/injection.dart';
import '../core/services/storage_service.dart';
import '../features/adhkar_reminder/data/services/adhkar_reminder_service.dart';
import '../features/prayer_times/data/services/prayer_notification_service.dart';
import 'home_page.dart';
import 'routing.dart';
import 'theme.dart';

final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.afasi.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
  );
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await setupDependencies();
  tz.initializeTimeZones();
  await _initConsentForAds();
  await getIt<AdhkarReminderService>().initialize();
  await getIt<PrayerNotificationService>().initialize();
  FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);

  // Initialize Mobile Ads SDK
  await MobileAds.instance.initialize();
}

Future<void> _initConsentForAds() async {
  try {
    await MobileAds.instance.initialize();
    print("تم تهيئة Google Mobile Ads SDK بنجاح");
  } catch (e) {
    print("خطأ أثناء تهيئة Google Mobile Ads SDK: $e");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    await StorageService.init();
    final storedTheme = StorageService.getTheme();

    if (!mounted) {
      return;
    }

    if (storedTheme != null) {
      setState(() {
        _isDarkMode = storedTheme;
      });
      return;
    }

    final platformBrightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final inferredDarkMode = platformBrightness == Brightness.dark;

    setState(() {
      _isDarkMode = inferredDarkMode;
    });

    await StorageService.saveTheme(inferredDarkMode);
  }

  void toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await StorageService.saveTheme(_isDarkMode);
  }

  bool get isDarkMode => _isDarkMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق مشاري العفاسي',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [Locale('ar', 'AE')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: HomePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: toggleTheme,
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
