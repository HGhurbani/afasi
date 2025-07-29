import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:user_messaging_platform/user_messaging_platform.dart' as UMP;
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';

import 'core/di/injection.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/app_colors.dart';
import 'core/utils/app_styles.dart';
import 'core/services/storage_service.dart';
import 'features/audio/bloc/audio_bloc.dart';
import 'features/audio/pages/home_page.dart';
import 'AdhkarReminderManager.dart';
import 'TasbihPage.dart';
import 'AdhkarReminderPage.dart';
import 'getCurrentLocation.dart';
import 'wallpapers_page.dart';

final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: AppConstants.audioChannelId,
    androidNotificationChannelName: AppConstants.audioChannelName,
    androidNotificationOngoing: true,
  );

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  tz.initializeTimeZones();
  await _initConsentForAds();
  await AdhkarReminderManager.initialize();
  FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);

  await MobileAds.instance.initialize();
  await setupDependencies();

  runApp(MyApp(key: myAppKey));
}

Future<void> _initConsentForAds() async {
  final UMP.ConsentRequestParameters params = UMP.ConsentRequestParameters();

  try {
    var consentInfo = await UMP.UserMessagingPlatform.instance.requestConsentInfoUpdate(params);

    if (consentInfo.consentStatus == UMP.ConsentStatus.required) {
      consentInfo = await UMP.UserMessagingPlatform.instance.showConsentForm();

      if (consentInfo.consentStatus == UMP.ConsentStatus.obtained) {
        print("حصلنا على موافقة مخصصة (Personalized Ads).");
      } else {
        print("المستخدم لم يمنح موافقة مخصصة.");
      }
    } else if (consentInfo.consentStatus == UMP.ConsentStatus.obtained) {
      print("موافقة مخصصة موجودة مسبقًا.");
    } else if (consentInfo.consentStatus == UMP.ConsentStatus.notRequired) {
      print("لا حاجة لعرض نموذج الموافقة.");
    } else {
      print("حالة الموافقة الحالية: ${consentInfo.consentStatus}");
    }
  } catch (e) {
    print("خطأ أثناء تهيئة موافقة الإعلانات: $e");
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
    final savedTheme = StorageService.getTheme();
    setState(() {
      _isDarkMode = savedTheme;
    });
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<AudioBloc>(
          create: (context) => getIt<AudioBloc>()..add(LoadAudioCategories()),
        ),
      ],
      child: MaterialApp(
        title: 'تطبيق مشاري العفاسي',
        debugShowCheckedModeBanner: false,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        locale: const Locale('ar', 'AE'),
        supportedLocales: const [Locale('ar', 'AE')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const HomePage(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      fontFamily: AppStyles.fontFamily,
      primaryColor: AppColors.primaryLight,
      textTheme: ThemeData.light().textTheme.apply(fontFamily: AppStyles.fontFamily),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _createMaterialColor(AppColors.primaryLight),
      ).copyWith(
        secondary: AppColors.primaryLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppStyles.appBarTitle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.primaryDark,
      textTheme: ThemeData.dark().textTheme.apply(fontFamily: AppStyles.fontFamily),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: AppStyles.appBarTitle,
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _createMaterialColor(AppColors.primaryDark),
      ).copyWith(
        secondary: AppColors.primaryDark,
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
          fontFamily: AppStyles.fontFamily,
          fontSize: 20,
        ),
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppStyles.fontFamily,
          fontSize: 16,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[300],
        ),
      ),
    );
  }

  MaterialColor _createMaterialColor(Color color) {
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

class NativeAdWidget extends StatefulWidget {
  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-7223999276472548/6597309308', // Production Ad Unit ID
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Native Ad failed to load: $error');
        },
      ),
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _nativeAd == null) {
      return Container();
    }
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}

class TextReaderPage extends StatefulWidget {
  final String title;
  final String content;

  const TextReaderPage({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  _TextReaderPageState createState() => _TextReaderPageState();
}

class _TextReaderPageState extends State<TextReaderPage> {
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.content,
                style:
                TextStyle(fontSize: _fontSize, fontFamily: 'Tajawal'),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (_fontSize > 10) _fontSize -= 2;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.zoom_out, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "تصغير",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _fontSize += 2;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.zoom_in, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "تكبير",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final AppOpenAdManager appOpenAdManager = AppOpenAdManager();

class AppOpenAdManager {
  AppOpenAd? appOpenAd;
  bool isAdAvailable = false;
  bool isShowingAd = false;

  void loadAd() {
    AppOpenAd.load(
      adUnitId: 'ca-app-pub-7223999276472548/1510060234',
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print("تم تحميل إعلان App Open بنجاح.");
          appOpenAd = ad;
          isAdAvailable = true;
        },
        onAdFailedToLoad: (error) {
          print("فشل تحميل إعلان App Open: $error");
        },
      ),
    );
  }

  void showAdIfAvailable() {
    if (!isAdAvailable || appOpenAd == null) {
      print("إعلان App Open غير متوفر حالياً، جاري التحميل...");
      loadAd();
      return;
    }
    if (isShowingAd) return;

    appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        isShowingAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        print("تم إغلاق إعلان App Open.");
        isShowingAd = false;
        appOpenAd = null;
        isAdAvailable = false;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print("فشل عرض إعلان App Open: $error");
        isShowingAd = false;
        appOpenAd = null;
        isAdAvailable = false;
        loadAd();
      },
    );
    appOpenAd!.show();
  }
}

class AppLifecycleReactor extends WidgetsBindingObserver {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor(this.appOpenAdManager);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      appOpenAdManager.showAdIfAvailable();
    }
  }
}