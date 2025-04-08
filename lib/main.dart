import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:user_messaging_platform/user_messaging_platform.dart' as UMP;
import 'screens/home_screen.dart';
import 'screens/tasbih_screen.dart';
import 'screens/adhkar_reminder_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'models/supplication.dart';
import 'services/audio_service.dart';
import 'utils/constants.dart';
import 'managers/adhkar_reminder_manager.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  tz.initializeTimeZones();
  await _initConsentForAds();
  await AdhkarReminderManager.initialize();
  MobileAds.instance.initialize();

  runApp(MyApp(key: myAppKey));
}

final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _isDarkMode = savedTheme;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق مشاري العفاسي',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        fontFamily: 'Tajawal',
        primaryColor: const Color(0xFF3498DB),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        fontFamily: 'Tajawal',
        primaryColor: const Color(0xFF2C3E50),
        brightness: Brightness.dark,
      ),
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [Locale('ar', 'AE')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/tasbih': (context) => const TasbihScreen(),
        '/adhkar-reminder': (context) => const AdhkarReminderScreen(),
        '/prayer-times': (context) => const PrayerTimesScreen(),
      },
    );
  }
}

Future<void> _initConsentForAds() async {
  final UMP.ConsentRequestParameters params = UMP.ConsentRequestParameters();
  try {
    var consentInfo = await UMP.UserMessagingPlatform.instance.requestConsentInfoUpdate(params);
    if (consentInfo.consentStatus == UMP.ConsentStatus.required) {
      consentInfo = await UMP.UserMessagingPlatform.instance.showConsentForm();
    }
  } catch (e) {
    print("Error initializing ads consent: $e");
  }
}