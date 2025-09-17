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
import '../core/constants/app_constants.dart';
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
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    _loadRewardedAd();
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

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AppConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
        onAdFailedToLoad: (error) => setState(() => _rewardedAd = null),
      ),
    );
  }

  void _showRewardedAd() {
    final ad = _rewardedAd;
    if (ad != null) {
      ad.show(onUserEarnedReward: (ad, reward) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('شكراً لدعمك!')));
        _loadRewardedAd();
      });
      _rewardedAd = null;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('الإعلان غير متوفر حالياً.')));
      _loadRewardedAd();
    }
  }

  Future<void> confirmAndShowRewardedAd() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text(
          'يرجى التأكيد بأنك ستشاهد الإعلان لدعم التطبيق والمساعدة في تطويره. هل أنت متأكد؟',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _showRewardedAd();
    }
  }

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
