import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RamadanPage.dart';
import 'TasbihPage.dart';
import 'AdhkarReminderPage.dart';
import 'getCurrentLocation.dart';
import 'AdhkarReminderManager.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:user_messaging_platform/user_messaging_platform.dart' as UMP;
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();

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
  FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);
  MobileAds.instance.initialize();

  runApp(MyApp(key: myAppKey));
}

/// دالة تهيئة مكتبة UMP لعرض نافذة الموافقة (Consent Form) للمستخدمين في الدول التي تتطلب ذلك
Future<void> _initConsentForAds() async {
  // إعدادات الموافقة (مثال: إذا كان التطبيق غير موجه للأطفال)
  final UMP.ConsentRequestParameters params = UMP.ConsentRequestParameters();

  try {
    // طلب أحدث معلومات الموافقة
    var consentInfo = await UMP.UserMessagingPlatform.instance
        .requestConsentInfoUpdate(params);

    // التحقق ما إذا كانت الموافقة مطلوبة
    if (consentInfo.consentStatus == UMP.ConsentStatus.required) {
      // عرض نموذج الموافقة
      consentInfo = await UMP.UserMessagingPlatform.instance.showConsentForm();

      // بعد إغلاق النموذج، يمكن التحقق من النتيجة:
      if (consentInfo.consentStatus == UMP.ConsentStatus.obtained) {
        print("حصلنا على موافقة مخصصة (Personalized Ads).");
      } else {
        print("المستخدم لم يمنح موافقة مخصصة.");
      }
    } else if (consentInfo.consentStatus == UMP.ConsentStatus.obtained) {
      // إذا كانت الموافقة موجودة مسبقًا
      print("موافقة مخصصة موجودة مسبقًا.");
    } else if (consentInfo.consentStatus == UMP.ConsentStatus.notRequired) {
      // إذا كانت الموافقة غير مطلوبة (على سبيل المثال في بعض الدول أو الإعدادات)
      print("لا حاجة لعرض نموذج الموافقة.");
    } else {
      // أي حالة أخرى مثل unknown أو denied
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
    _loadTheme(); // تحميل الثيم المحفوظ عند بدء التطبيق
  }

  /// دالة لتحميل الحالة المحفوظة للوضع الليلي/الفاتح
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // إذا لم يكن هناك قيمة محفوظة سيتم افتراض الوضع الفاتح (false)
    final savedTheme = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _isDarkMode = savedTheme;
    });
  }

  /// دالة لتبديل الثيم وحفظ الحالة الجديدة
  void toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  /// Getter للوصول إلى حالة الوضع الليلي
  bool get isDarkMode => _isDarkMode;

  final Color primaryColorValue = const Color(0xFF3498DB);
  final Color darkPrimaryColorValue = const Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق مشاري العفاسي',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        fontFamily: 'Tajawal',
        primaryColor: primaryColorValue,
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Tajawal'),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: createMaterialColor(primaryColorValue),
        ).copyWith(
          secondary: primaryColorValue,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColorValue,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: primaryColorValue,
            backgroundColor: Colors.white,
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: darkPrimaryColorValue,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Tajawal'),
        appBarTheme: AppBarTheme(
          backgroundColor: darkPrimaryColorValue,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            fontFamily: 'Tajawal',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: createMaterialColor(darkPrimaryColorValue),
        ).copyWith(
          secondary: darkPrimaryColorValue,
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
            foregroundColor: Colors.grey[300],
          ),
        ),
      ),
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [Locale('ar', 'AE')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: HomePage(),
    );
  }

  /// دالة مساعدة لتحويل لون ثابت إلى MaterialColor
  MaterialColor createMaterialColor(Color color) {
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

/// نموذج بيانات الصوت (الدعاء/الذكر/القرآن... إلخ)
class Supplication {
  final String title;
  final String audioUrl;
  final String textAssetPath;
  final bool isLocalAudio;
  final IconData icon; // ← تمت الإضافة هنا
  bool isDownloaded;

  Supplication({
    required this.title,
    required this.audioUrl,
    required this.textAssetPath,
    required this.icon, // ← تمت الإضافة هنا
    this.isLocalAudio = false,
    this.isDownloaded = false,
  });
}


class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isAutoNext = false;

  // حفظ قائمة المفضلة باستخدام shared_preferences
  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favTitles = favorites.map((fav) => fav.title).toList();
    await prefs.setStringList('favorites', favTitles);
  }

  // تحميل قائمة المفضلة عند بدء تشغيل التطبيق
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? favTitles = prefs.getStringList('favorites');
    if (favTitles != null) {
      favorites.clear();
      audioCategories.forEach((category, suppList) {
        for (var supp in suppList) {
          if (favTitles.contains(supp.title)) {
            favorites.add(supp);
          }
        }
      });
      if (_selectedCategory == "المفضلة") {
        setState(() {
          filteredSupplications = List<Supplication>.from(favorites);
        });
      }
    }
  }

  /// تعريف أقسام الصوتيات مع عينات لكل قسم
  final Map<String, List<Supplication>> audioCategories = {
    "القرآن الكريم": [
      Supplication(
        title: "آيات الشفاء في القرآن الكريم",
        audioUrl: "assets/audio/mishary13.mp3",
        textAssetPath: "assets/texts/شفاء.txt",
        icon: FontAwesomeIcons.quran,
        isLocalAudio: true,
      ),
      Supplication(
        title: "سورة الكهف",
        audioUrl: "https://www.youtube.com/watch?v=-FxEYa8joK8",
        textAssetPath: "assets/texts/كهف.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "سورة طه",
        audioUrl:
            "https://www.youtube.com/watch?v=XMPNjBEw4vc&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq",
        textAssetPath: "assets/texts/طه.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "سورة الأنفال",
        audioUrl:
            "https://www.youtube.com/watch?v=3JaXe2h563c&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=2",
        textAssetPath: "assets/texts/الأنفال.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "تلاوة مؤثرة من سورة المدثر",
        audioUrl:
            "https://www.youtube.com/watch?v=h4PKhfXmKgk&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=3",
        textAssetPath: "assets/texts/المدثر.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "هذان خصمان اختصموا في ربهم | من صلاة التراويح",
        audioUrl:
            "https://www.youtube.com/watch?v=QHuxUGq4CCk&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=4",
        textAssetPath: "assets/texts/الحج.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "سورة القيامة ليلة 27 رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=7Iszt7GFN5Q&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=5",
        textAssetPath: "assets/texts/القيامة.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "سورة الحاقة ليلة 27 رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=mm5J6AoN4MM&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=6",
        textAssetPath: "assets/texts/الحاقة.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "سورة ق ليلة 27 رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=bdnhDm58fcQ&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=7",
        textAssetPath: "assets/texts/قاف.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "سورة المدثر",
        audioUrl:
            "https://www.youtube.com/watch?v=LOOGmSCndUo&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=8",
        textAssetPath: "assets/texts/المدثر.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "سورة المزمل ليلة 27 رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=rOf_tzIlknI&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=9",
        textAssetPath: "assets/texts/المزمل.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "صلاة الشفع - سورة الفلق",
        audioUrl:
            "https://www.youtube.com/watch?v=2Lv3cw-1TXA&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=10",
        textAssetPath: "assets/texts/الفلق.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "صلاة الشفع - سورة الإخلاص",
        audioUrl:
            "https://www.youtube.com/watch?v=qHK8B3d-aQQ&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=11",
        textAssetPath: "assets/texts/الأخلاص.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "سورة مريم",
        audioUrl:
            "https://www.youtube.com/watch?v=y1bHdFHCKQs&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=12",
        textAssetPath: "assets/texts/مريم.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "استجيبوا لله وللرسول",
        audioUrl:
            "https://www.youtube.com/watch?v=iLjDxArvVgQ&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=13",
        textAssetPath: "assets/texts/الأنفالل.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "من سورة إبراهيم",
        audioUrl:
            "https://www.youtube.com/watch?v=SUFPYER88fs&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=14",
        textAssetPath: "assets/texts/ابراهيم.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "وَلَقَدْ أَرْسَلْنَا مُوسَى - من سورة هود",
        audioUrl:
            "https://www.youtube.com/watch?v=USc1YU_uic0&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=15",
        textAssetPath: "assets/texts/هود.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "وإلى مدين أخاهم شعيبا - من سورة هود",
        audioUrl:
            "https://www.youtube.com/watch?v=Z3unvO35RzE&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=16",
        textAssetPath: "assets/texts/هودد.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "والله يدعو إلى دار السلام - من سورة يونس",
        audioUrl:
            "https://www.youtube.com/watch?v=-f8E0Cg5uhs&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=17",
        textAssetPath: "assets/texts/يونس.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "للذين أحسنوا الحسنى وزيادة",
        audioUrl:
            "https://www.youtube.com/watch?v=bpMeNhKxMAE&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=18",
        textAssetPath: "assets/texts/يونسس.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "من سورة يوسف",
        audioUrl:
            "https://www.youtube.com/watch?v=9OCsN7A2Dnc&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=19",
        textAssetPath: "assets/texts/يوسف.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "واضرب لهم مثلا رجلين",
        audioUrl:
            "https://www.youtube.com/watch?v=KxpcLKM9jp0&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=20",
        textAssetPath: "assets/texts/الكهف.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "وَما مُحَمَّدٌ إِلّا رَسولٌ قَد خَلَت مِن قَبلِهِ الرُّسُلُ",
        audioUrl:
            "https://www.youtube.com/watch?v=NklF4awiEeI&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=21",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "لِكَيلا تَحزَنوا عَلىٰ ما فاتَكُم وَلا ما أَصٰابَكُم",
        audioUrl:
            "https://www.youtube.com/watch?v=R9SGnvBr0Gs&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=22",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "ولو كنت فظا غليظ القلب لانفضوا من حولك",
        audioUrl:
            "https://www.youtube.com/watch?v=DwdDmjSue_w&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=23",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "لا تأكلوا الربا - سورة آل عمران",
        audioUrl:
            "https://www.youtube.com/watch?v=PPf4nwQP-Yc&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=24",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "فأصلحوا بين أخويكم",
        audioUrl:
            "https://www.youtube.com/watch?v=Xn6kPxSRMek&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=25",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "سعيهم مشكوراً",
        audioUrl:
            "https://www.youtube.com/watch?v=A8vMGTn2s5I&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=26",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "وكان الإنسان عجولا",
        audioUrl:
            "https://www.youtube.com/watch?v=cDIHuNpTit8&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=27",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "ولا تقربوا مال اليتيم",
        audioUrl:
            "https://www.youtube.com/watch?v=eAvOL3Ck8Kc&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=28",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.quran,
      ),
      Supplication(
        title: "شهر رمضان الذي أنزل فيه القرآن",
        audioUrl:
            "https://www.youtube.com/watch?v=6QkmTaUUotA&list=PL2hoGhz2jBSqXQUzpLwVrGOjUxEA3YpTq&index=29",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.quran,

      ),
    ],
    "الأناشيد": [
      Supplication(
        title: "عمر الفاروق",
        audioUrl:
            "https://www.youtube.com/watch?v=Gkflvn9v8Os&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR",
        textAssetPath: "assets/texts/عمر-الفاروق.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "غردي يا روح",
        audioUrl:
            "https://www.youtube.com/watch?v=t_9-WdMqUi0&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=2",
        textAssetPath: "assets/texts/غردقي.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "علي رضي الله عنه",
        audioUrl:
            "https://www.youtube.com/watch?v=5xJkdp_3cDA&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=3",
        textAssetPath: "assets/texts/علي.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "يا شايل الهم",
        audioUrl:
            "https://www.youtube.com/watch?v=du7vFCvH7gA&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=4",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "يسعد فؤادي",
        audioUrl:
            "https://www.youtube.com/watch?v=lU279ZXlmqk&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=5",
        textAssetPath: "assets/texts/فؤادي.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "أضفيت",
        audioUrl:
            "https://www.youtube.com/watch?v=Q94Kkb4tesc&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=6",
        textAssetPath: "assets/texts/اضفيت.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "صلوا عليه وسلموا",
        audioUrl:
            "https://www.youtube.com/watch?v=Qm0_ioxhHvc&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=7",
        textAssetPath: "assets/texts/صلوا.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "حبيبي محمد",
        audioUrl:
            "https://www.youtube.com/watch?v=rgIHozrtqXI&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=8",
        textAssetPath: "assets/texts/حبيبي.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "آية وحكاية",
        audioUrl:
            "https://www.youtube.com/watch?v=J6q_5S_Ddj4&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=9",
        textAssetPath: "assets/texts/حكايات.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "سيبقى اشتياقي",
        audioUrl:
            "https://www.youtube.com/watch?v=YmOWf3p1Qtg&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=10",
        textAssetPath: "assets/texts/اشتياقي.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "سيد الأخلاق",
        audioUrl:
            "https://www.youtube.com/watch?v=gmwgiqFEEpA&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=11",
        textAssetPath: "assets/texts/سيد.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "هل لك سر عند الله",
        audioUrl:
            "https://www.youtube.com/watch?v=lRNHaFAZqhc&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=12",
        textAssetPath: "assets/texts/سر.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "سيمر هذا الوقت",
        audioUrl:
            "https://www.youtube.com/watch?v=mJhGGPOTgeU&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=13",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.music,
      ),
      Supplication(
        title: "طلع البدر علينا",
        audioUrl:
            "https://www.youtube.com/watch?v=XjZ1gTvbaIA&list=PL2hoGhz2jBSrwCr022cxnFHIKj4NoLLGR&index=14",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.music,
      ),
    ],
    "الأذكار": [
      Supplication(
        title: "أذكار الصباح",
        audioUrl: "assets/audio/mishary1.mp3",
        textAssetPath: "assets/texts/صباح.txt",
        icon: FontAwesomeIcons.solidSun,
        isLocalAudio: true,
      ),
      Supplication(
        title: "أذكار المساء",
        audioUrl: "assets/audio/mishary2.mp3",
        textAssetPath: "assets/texts/مساء.txt",
        icon: FontAwesomeIcons.moon,
        isLocalAudio: true,
      ),
      Supplication(
        title: "اذكار النوم ",
        audioUrl: "https://www.youtube.com/watch?v=Qm6QI0so0e0",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.bed,
      ),
      Supplication(
        title: "أذكار النوم + خواتيم سورة البقره، والملك، والسجده",
        audioUrl: "https://www.youtube.com/watch?v=lqMpe4lmTpg&t=2s",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.bed,
      ),
      Supplication(
        title: "صيغ الصلاة على النبي ﷺ",
        audioUrl:
            "https://www.youtube.com/watch?v=PCyw3ASbwZI&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=33",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.handsPraying,
      ),
      Supplication(
        title: "يا ذا العزة والجبروت",
        audioUrl:
            "https://www.youtube.com/watch?v=rCbnJUqXLgM&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=43",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.prayingHands,
      ),
      Supplication(
        title: "اللهم اغفر لي",
        audioUrl:
            "https://www.youtube.com/watch?v=hwEGKh97qM4&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=47",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.handsPraying, // 👐
      ),
      Supplication(
        title: "أنت ملاذنا .. يا أنيس المحجورين",
        audioUrl:
            "https://www.youtube.com/watch?v=NHx_E7CsIUE&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=68",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.shieldHalved, // 🛡️
      ),
      Supplication(
        title: "أصبحنا وأصبح الملك لله",
        audioUrl:
            "https://www.youtube.com/watch?v=yssu6YenZCU&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=22",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.solidSun, // ☀️
      ),
      Supplication(
        title: "تكبيرات العيد ",
        audioUrl:
            "https://www.youtube.com/watch?v=_RxP8WQOhqU&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=24",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.mosque, // 🕌
      ),
      Supplication(
        title: "حبي كله لك",
        audioUrl:
            "https://www.youtube.com/watch?v=foXVsEAExoU&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=31",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.heart, // ❤️
      ),
      Supplication(
        title: "لبيك",
        audioUrl:
            "https://www.youtube.com/watch?v=yzZ7iMS492c&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=56",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.kaaba, // 🕋
      ),
    ],
    "الأدعية": [
      Supplication(
        title: "دعاء السفر",
        audioUrl: "assets/audio/mishary3.mp3",
        textAssetPath: "assets/texts/سفر.txt",
        icon: FontAwesomeIcons.planeDeparture,
        isLocalAudio: true,
      ),
      Supplication(
        title: "ركوب الدابه",
        audioUrl: "assets/audio/mishary4.mp3",
        textAssetPath: "assets/texts/الركوب.txt",
        icon: FontAwesomeIcons.car, // 🚗 أو 🐪 (رمزي)
        isLocalAudio: true,
      ),
      Supplication(
        title: "دخول السوق",
        audioUrl: "assets/audio/mishary5.mp3",
        textAssetPath: "assets/texts/سوق.txt",
        icon: FontAwesomeIcons.store, // 🏬
        isLocalAudio: true,
      ),
      Supplication(
        title: "دخول المسجد",
        audioUrl: "assets/audio/mishary6.mp3",
        textAssetPath: "assets/texts/المسجد.txt",
        icon: FontAwesomeIcons.mosque, // 🕌
        isLocalAudio: true,
      ),
      Supplication(
        title: "الاستيقاظ من النوم",
        audioUrl: "assets/audio/mishary7.mp3",
        textAssetPath: "assets/texts/بعد النوم.txt",
        icon: FontAwesomeIcons.solidClock, // ⏰
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء للمتوفي",
        audioUrl: "assets/audio/mishary9.mp3",
        textAssetPath: "assets/texts/المتوفي.txt",
        icon: FontAwesomeIcons.dove, // 🕊
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء نزول المطر",
        audioUrl: "assets/audio/mishary11.mp3",
        textAssetPath: "assets/texts/المطر.txt",
        icon: FontAwesomeIcons.cloudRain,
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء للأولاد",
        audioUrl: "assets/audio/mishary13.mp3",
        textAssetPath: "assets/texts/اولاد.txt",
        icon: FontAwesomeIcons.child, // 👶
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء كسوف الشمس",
        audioUrl: "assets/audio/mishary14.mp3",
        textAssetPath: "assets/texts/كسوف.txt",
        icon: FontAwesomeIcons.solarPanel, // ☀️ رمز للظاهرة الشمسية
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء ختم القران",
        audioUrl: "assets/audio/mishary15.mp3",
        textAssetPath: "assets/texts/ختم.txt",
        icon: FontAwesomeIcons.bookQuran, // 📖
        isLocalAudio: true,
      ),
      Supplication(
        title: "اللهم اشف مرضانا",
        audioUrl:
            "https://www.youtube.com/watch?v=k7hOmZ71nws&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=67",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.heart // ❤️ أبسط ومباشر
      ),
      Supplication(
        title: "دعاء الجنة",
        audioUrl:
            "https://www.youtube.com/watch?v=-aL2HrBEpLE&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=128",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.starAndCrescent, // 🌴 جنة/نخيل (أو use: FontAwesomeIcons.treePalm)
      ),
      Supplication(
        title: "يا من كفانا .. سيء الأسقام",
        audioUrl:
            "https://www.youtube.com/watch?v=HdQcXgTv2aw&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=10",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.handHoldingHeart, // 🤲❤️
      ),
      Supplication(
        title: "دعاء لأهل غزة",
        audioUrl:
            "https://www.youtube.com/watch?v=ngJ88El_w3Q&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=28",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.handHoldingMedical, // ✋ رمز للنجدة والدعم
      ),
      Supplication(
        title: "الدعاء الجامع",
        audioUrl:
            "https://www.youtube.com/watch?v=Baz7RSA1jJ0&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=29",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.handsPraying, // 🙏 عام وشامل
      ),
      Supplication(
        title: "دعاء رؤية الهلال",
        audioUrl:
            "https://www.youtube.com/watch?v=bi_P137Xv2g&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=86",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon, // 🌙
      ),
      Supplication(
        title: "اللهم فرج هم المهمومين",
        audioUrl:
            "https://www.youtube.com/watch?v=4Yts6nga0mg&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=173",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.faceSmileBeam, // 😊 للتفريج والفرح
      ),
      Supplication(
        title: "دعاء - إصدار الرحمن و الواقعة و الحديد",
        audioUrl:
            "https://www.youtube.com/watch?v=fcG_HrPe4GQ&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=170",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.quran, // 📖 لإصدار جامع من السور
      ),
    ],
    "رمضانيات": [
      Supplication(
        title: "دعاء بلوغ رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=mGYScZSGNMY&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=80",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon,
      ),
      Supplication(
        title: "دعاء ليالي رمضان",
        audioUrl: "assets/audio/mishary10.mp3",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon,
        isLocalAudio: true,
      ),
      Supplication(
        title: "دعاء ليلة 18 رمضان من جامع الشيخ زايد",
        audioUrl:
            "https://www.youtube.com/watch?v=hg8msa2AUcg&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=188",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon,
      ),
      Supplication(
        title: "دعاء ليلة 27 رمضان من المسجد الكبير",
        audioUrl:
            "https://www.youtube.com/watch?v=NRKsCrj5iNI&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=11",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon,
      ),
      Supplication(
        title: "دعاء ليلة 20 الراشدية بدبي",
        audioUrl:
            "https://www.youtube.com/watch?v=wpTT4onWips&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=187",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon,
      ),
      Supplication(
        title: "دعاء ليلة 21 رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=rDExXcV1AJQ&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=163",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon,
      ),
      Supplication(
        title: "دعاء ليلة 27",
        audioUrl:
            "https://www.youtube.com/watch?v=_8eX9qACLbE&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=160",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon,
      ),
      Supplication(
        title: "دعاء ليلة 29 رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=TZb0KvDu2wE&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=18",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon,
      ),
      Supplication(
        title: "دعاء القنوت ليلة 27",
        audioUrl:
            "https://www.youtube.com/watch?v=iTFXS5DhSBk&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=19",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon,
      ),
      Supplication(
        title: "الشفع والوتر ودعاء ٢٧ رمضان",
        audioUrl:
            "https://www.youtube.com/watch?v=_faw3Mq09NM&list=PL2hoGhz2jBSqosLJN5ECy3KsgT_Pu8kNX&index=69",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.moon,
      ),
    ],
    "الرقية الشرعية": [
      Supplication(
        title: "الرقية الشرعية",
        audioUrl: "assets/audio/mishary8.mp3",
        textAssetPath: "assets/texts/الرقية.txt",
        icon: FontAwesomeIcons.shieldHalved,
        isLocalAudio: true,
      ),
      Supplication(
        title: "علاج السحر والعين والحسد",
        audioUrl: "https://www.youtube.com/watch?v=D32QyEZJg4c",
        textAssetPath: "assets/texts/sleep.txt",
        icon: FontAwesomeIcons.shieldHalved,
      ),
    ],
  };

  // قائمة المفضلة (تُعرض عند اختيار قسم "المفضلة")
  final List<Supplication> favorites = [];

  // القسم الحالي المُختار؛ افتراضيًا "الأذكار"
  String _selectedCategory = "الأذكار";
  // قائمة الصوتيات المعروضة بناءً على القسم والبحث
  List<Supplication> filteredSupplications = [];

  // مشغل الصوت
  final AudioPlayer _audioPlayer = AudioPlayer();
  // لتتبع الصوت الجاري تشغيله
  Supplication? _currentSupplication;
  // كاش لتخزين روابط الصوت المستخرجة من يوتيوب لتسريع التحميل
  final Map<String, String> _youtubeCache = {};
  // إعلانات AdMob
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _usageCounter = 0;
  late AppLifecycleReactor _appLifecycleReactor;
  // حقل البحث
  final TextEditingController _searchController = TextEditingController();
  // حالة التكرار
  bool _isRepeat = false;

  // بدلًا من ثابت، نعتمد على getter لاختيار اللون المناسب وفقاً للوضع
  Color get accentBlue => Theme.of(context).brightness == Brightness.dark
      ? Colors.blueGrey
      : const Color(0xFF3498DB);

  @override
  void initState() {
    super.initState();
    filteredSupplications =
        List<Supplication>.from(audioCategories[_selectedCategory] ?? []);
    _appLifecycleReactor = AppLifecycleReactor(appOpenAdManager);
    WidgetsBinding.instance.addObserver(_appLifecycleReactor);

    _audioPlayer.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        if (_isAutoNext) {
          _playNext();
        }
      }
    });
    loadLastCategory();
    _audioPlayer.playingStream.listen((isPlaying) {
      setState(() {});
    });
    _audioPlayer.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        if (_isAutoNext) {
          _playNext();
        }
      }
    });
    loadFavorites();
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
    checkDownloadedStatus();

    FirebaseMessaging.instance
        .requestPermission(
      alert: true,
      badge: true,
      sound: true,
    )
        .then((settings) {
      print('User granted permission: ${settings.authorizationStatus}');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground!');
      if (message.notification != null) {
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_appLifecycleReactor);
    _audioPlayer.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadLastCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCategory = prefs.getString('lastCategory');
    if (lastCategory != null && audioCategories.containsKey(lastCategory)) {
      setState(() {
        _selectedCategory = lastCategory;
        filteredSupplications = lastCategory == "المفضلة"
            ? List<Supplication>.from(favorites)
            : List<Supplication>.from(audioCategories[lastCategory] ?? []);
      });
    }
  }

  /// تحديث القسم المُختار والقائمة المعروضة
  void updateCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCategory', category); // حفظ القسم الأخير
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      filteredSupplications = category == "المفضلة"
          ? List<Supplication>.from(favorites)
          : List<Supplication>.from(audioCategories[category] ?? []);
    });
    Navigator.pop(context);
  }

  /// عرض مؤشر الانتظار مع رسالة
  void showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message, textDirection: TextDirection.rtl)),
          ],
        ),
      ),
    );
  }

  /// تحميل إعلان البانر
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-7223999276472548/9615774793',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  /// تحميل إعلان انتقالي (Interstitial)
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-7223999276472548/6569146925',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  /// تحميل إعلان مكافآت (Rewarded)
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-7223999276472548/7762749023',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  /// دالة تأكيد مشاهدة الإعلان لدعم التطبيق
  Future<void> confirmAndShowRewardedAd() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text(
          'يرجى التأكيد بأنك ستشاهدت الإعلان لدعم التطبيق والمساعدة في تطويره. هل أنت متأكد؟',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لا')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('نعم')),
        ],
      ),
    );
    if (confirm == true) {
      showRewardedAd();
    }
  }

  /// عرض إعلان المكافآت
  void showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('شكراً لدعمك!')));
        loadRewardedAd();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الإعلان غير متوفر حالياً.')));
    }
  }

  /// دالة تشغيل الصوت مع دعم روابط يوتيوب (وباستخدام الكاش لتسريع التحميل)
  Future<void> playAudio(Supplication supp) async {
    setState(() {
      _currentSupplication = supp;
    });

    if (supp.isLocalAudio) {
      try {
        await _audioPlayer.setAsset(supp.audioUrl);
        _audioPlayer.play();
        return;
      } catch (e) {
        print("Error playing local audio: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطأ في تشغيل الصوت المحلي.')));
        return;
      }
    }

    final Directory dir = await getApplicationSupportDirectory();
    final String filePath = '${dir.path}/${supp.title}.mp3';
    if (await File(filePath).exists()) {
      supp.isDownloaded = true;
      try {
        await _audioPlayer.setFilePath(filePath);
        _audioPlayer.play();
        return;
      } catch (e) {
        print("Error playing downloaded audio: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطأ في تشغيل الملف الصوتي المحمل.')));
        return;
      }
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('لا يوجد إنترنت.')));
      return;
    }

    String source;
    if (supp.audioUrl.contains("youtube.com") ||
        supp.audioUrl.contains("youtu.be")) {
      final String? videoId = extractYoutubeVideoId(supp.audioUrl);
      if (videoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('رابط تحميل غير صالح.')));
        return;
      }
      if (_youtubeCache.containsKey(videoId)) {
        source = _youtubeCache[videoId]!;
      } else {
        showLoadingDialog("جاري تجهيز الصوت ...");
        final yt = YoutubeExplode();
        try {
          final manifest = await yt.videos.streamsClient.getManifest(videoId);
          final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
          source = audioStreamInfo.url.toString();
          _youtubeCache[videoId] = source;
        } catch (e) {
          print("Error extracting YouTube audio: $e");
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('خطأ في استخراج الصوت حاول مرة آخرى.')));
          yt.close();
          Navigator.pop(context);
          return;
        }
        yt.close();
        Navigator.pop(context);
      }
    } else {
      source = supp.audioUrl;
    }
    try {
      await _audioPlayer.setUrl(source);
      _audioPlayer.play();
    } catch (e) {
      print("Error playing audio: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('خطأ في تشغيل الصوت.')));
    }
  }

  /// إيقاف الصوت
  void pauseAudio() {
    _audioPlayer.pause();
    setState(() {});
  }

  /// دالة تنزيل الصوت مع مؤشر تقدم وزر إيقاف/استئناف التحميل
  Future<void> downloadAudio(Supplication supp) async {
    if (supp.isLocalAudio) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الصوت متاح بالفعل دون إنترنت.')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(
                child: Text("يرجى الانتظار حتى يبدأ التحميل",
                    textDirection: TextDirection.rtl)),
          ],
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context);

    String urlToDownload = supp.audioUrl;
    try {
      if (supp.audioUrl.contains("youtube.com") ||
          supp.audioUrl.contains("youtu.be")) {
        final yt = YoutubeExplode();
        final String? videoId = extractYoutubeVideoId(supp.audioUrl);
        if (videoId == null) throw Exception("الصوت غير صالح");
        final manifest = await yt.videos.streamsClient.getManifest(videoId);
        final audioStreamInfo = manifest.audioOnly.withHighestBitrate();
        urlToDownload = audioStreamInfo.url.toString();
        yt.close();
      }
      final client = http.Client();
      final request = http.Request("GET", Uri.parse(urlToDownload));
      final response = await client.send(request);
      final int contentLength = response.contentLength ?? 0;
      final DateTime startTime = DateTime.now();
      int downloadedBytes = 0;
      final progressNotifier = ValueNotifier<double>(0.0);
      final downloadedBytesNotifier = ValueNotifier<int>(0);
      final pausedNotifier = ValueNotifier<bool>(false);
      StreamSubscription<List<int>>? subscription;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return ValueListenableBuilder<double>(
            valueListenable: progressNotifier,
            builder: (context, progress, _) {
              int estimatedSeconds = 0;
              final int elapsed =
                  DateTime.now().difference(startTime).inSeconds;
              if (downloadedBytesNotifier.value > 0 && elapsed > 0) {
                final double speed = downloadedBytesNotifier.value / elapsed;
                estimatedSeconds =
                    ((contentLength - downloadedBytesNotifier.value) / speed)
                        .round();
              }
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(value: progress),
                    const SizedBox(height: 20),
                    Text(
                        "جاري تحميل الصوت... ${(progress * 100).toStringAsFixed(0)}%",
                        textDirection: TextDirection.rtl),
                    if (estimatedSeconds > 0)
                      Text("الوقت المتبقي: ${estimatedSeconds}s"),
                  ],
                ),
                actions: [
                  ValueListenableBuilder<bool>(
                    valueListenable: pausedNotifier,
                    builder: (context, paused, _) {
                      return TextButton(
                        onPressed: () {
                          if (subscription != null) {
                            if (!paused) {
                              subscription!.pause();
                              pausedNotifier.value = true;
                            } else {
                              subscription!.resume();
                              pausedNotifier.value = false;
                            }
                          }
                        },
                        child: Text(paused ? "استئناف" : "إيقاف مؤقت"),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      );

      final List<int> bytes = [];
      subscription = response.stream.listen((newBytes) {
        bytes.addAll(newBytes);
        downloadedBytes += newBytes.length;
        downloadedBytesNotifier.value = downloadedBytes;
        if (contentLength > 0) {
          progressNotifier.value = downloadedBytes / contentLength;
        }
      });
      await subscription.asFuture();
      Navigator.pop(context);
      client.close();
      final Directory dir = await getApplicationSupportDirectory();
      final File file = File('${dir.path}/${supp.title}.mp3');
      await file.writeAsBytes(bytes);
      setState(() {
        supp.isDownloaded = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحميل ${supp.title} بنجاح!')));
    } catch (e) {
      Navigator.pop(context);
      print("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء التحميل أعد المحاولة.')));
    }
  }

  /// الانتقال إلى صفحة قراءة النص مع إمكانية تكبير وتصغير حجم الخط
  Future<void> readText(Supplication supp) async {
    try {
      final String content = await rootBundle.loadString(supp.textAssetPath);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TextReaderPage(title: supp.title, content: content)),
      );
    } catch (e) {
      print("Error loading text: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('حدث خطأ أثناء قراءة النص أو لا يوجد نص.')));
    }
  }

  /// التحقق من عدد الاستخدامات وعرض إعلان انتقالي عند الحاجة
  void checkAndShowInterstitialAd() {
    _usageCounter++;
    if (_usageCounter >= 5 && _interstitialAd != null) {
      _interstitialAd!.show();
      _usageCounter = 0;
      loadInterstitialAd();
    }
  }

  void _playNext() {
    if (_currentSupplication == null) return;
    final int currentIndex = filteredSupplications
        .indexWhere((s) => s.title == _currentSupplication!.title);
    if (currentIndex < filteredSupplications.length - 1) {
      playAudio(filteredSupplications[currentIndex + 1]);
    }
  }

  void _playPrevious() {
    if (_currentSupplication == null) return;
    final int currentIndex = filteredSupplications
        .indexWhere((s) => s.title == _currentSupplication!.title);
    if (currentIndex > 0) {
      playAudio(filteredSupplications[currentIndex - 1]);
    }
  }

  void _rewind10() {
    final Duration current = _audioPlayer.position;
    final Duration newPosition = current - const Duration(seconds: 10);
    _audioPlayer
        .seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _forward10() {
    final Duration current = _audioPlayer.position;
    final Duration duration = _audioPlayer.duration ?? Duration.zero;
    final Duration newPosition = current + const Duration(seconds: 10);
    _audioPlayer.seek(newPosition > duration ? duration : newPosition);
  }

  void _togglePlayPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() {});
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void filterSearchResults(String query) {
    final List<Supplication> currentList = _selectedCategory == "المفضلة"
        ? favorites
        : audioCategories[_selectedCategory] ?? [];
    setState(() {
      filteredSupplications = query.isNotEmpty
          ? currentList.where((item) => item.title.contains(query)).toList()
          : List<Supplication>.from(currentList);
    });
  }

  final String privacyPolicyText = '''
سياسة الخصوصية لتطبيق مشاري العفاسي

نحن في تطبيق مشاري العفاسي نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. تُستخدم المعلومات التي يتم جمعها لتحسين تجربة المستخدم وتقديم إعلانات مناسبة، ويتم ذلك وفق الشروط التالية:

1. جمع المعلومات:  
   - لا نقوم بجمع معلومات شخصية عن المستخدمين بدون موافقتهم.
   - نستخدم خدمات مثل Firebase Analytics و Google Mobile Ads لجمع بيانات تحليلية وإحصائية تُستخدم لتحسين أداء التطبيق وتقديم المحتوى المناسب.

2. استخدام المعلومات:  
   - تُستخدم البيانات فقط لأغراض تحليلية وتطوير التطبيق.
   - لا يتم بيع أو مشاركة المعلومات مع أطراف خارجية بدون إذن المستخدم.

3. الأمان:  
   - نتخذ إجراءات تقنية وتنظيمية مناسبة لحماية بيانات المستخدمين.
   - يتم تخزين المعلومات على خوادم آمنة وفق أعلى معايير الحماية.

4. التغييرات على سياسة الخصوصية:  
   - قد نقوم بتحديث سياسة الخصوصية من وقت لآخر.
   - سيتم نشر أي تغييرات على هذه السياسة داخل التطبيق وفي صفحة سياسة الخصوصية.

5. الاتصال:  
   - إذا كانت لديك أي أسئلة أو استفسارات حول سياسة الخصوصية، يمكنك التواصل معنا عبر البريد الإلكتروني: hazemhataki@gmail.com

باستخدامك لهذا التطبيق، فإنك توافق على جمع واستخدام المعلومات وفقاً لهذه السياسة.
''';

  void showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("سياسة الخصوصية"),
        content: SingleChildScrollView(
          child: Text(
            privacyPolicyText,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("حسناً")),
        ],
      ),
    );
  }

  void showInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تعليمات الاستخدام'),
        content: SingleChildScrollView(
          child: const Text(
            'مرحباً بك في تطبيق مشاري العفاسي.\n\n'
            'كيفية الاستخدام:\n'
            '1. استخدم القائمة الجانبية لتحديد قسم الصوتيات (مثل القرآن الكريم، الأناشيد، الأذكار، الأدعية، الرقية الشرعية).\n'
            '2. استخدم حقل البحث لتصفية قائمة الصوتيات ضمن القسم المحدد.\n'
            '3. اضغط على زر التشغيل لتشغيل الصوت، وفي حال كان الصوت غير محمّل يتم استخراج الصوت أو تشغيل الصوت المحلي بدون إنترنت.\n'
            '4. يمكنك تنزيل الصوت للاستماع دون إنترنت عبر زر التنزيل (إذا لم يكن الصوت محلياً)، وإذا كان الصوت متاحاً بالفعل سيظهر زر التحميل باللون الرمادي.\n'
            '5. عند تشغيل الصوت يظهر مشغل في أسفل الشاشة يحتوي على شريط تمرير للتحكم بموقع التشغيل وأزرار للتحكم (السابق، إعادة 10 ثوانٍ، تشغيل/إيقاف، تقديم 10 ثوانٍ، التالي) مع زر (×) لإغلاق المشغل.\n'
            '6. اضغط على زر "قراءة" لفتح صفحة قراءة النص مع إمكانية تكبير وتصغير الخط.\n'
            '7. لإضافة الصوتيات إلى المفضلة، استخدم أيقونة القلب في قائمة الصوتيات. ولعرض قائمة المفضلة، اختر "المفضلة" من القائمة الجانبية.\n'
            '8. لدعم التطبيق، يمكنك مشاهدة إعلان المكافآت عبر الضغط على أيقونة القلب في شريط التطبيق.\n',
            textDirection: TextDirection.rtl,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً')),
        ],
      ),
    );
  }

  Future<void> checkDownloadedStatus() async {
    final Directory dir = await getApplicationSupportDirectory();
    for (var category in audioCategories.keys) {
      for (var supp in audioCategories[category]!) {
        if (!supp.isLocalAudio) {
          final String filePath = '${dir.path}/${supp.title}.mp3';
          if (await File(filePath).exists()) {
            supp.isDownloaded = true;
          }
        }
      }
    }
    setState(() {});
  }

  /// دالة مساعدة لاستخراج معرف الفيديو من رابط يوتيوب
  String? extractYoutubeVideoId(String url) {
    final RegExp regExp = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*',
        caseSensitive: false, multiLine: false);
    final Match? match = regExp.firstMatch(url);
    return match != null ? match.group(1) : null;
  }

  Widget _buildAudioPlayer() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // صف يحتوي على عنوان الصوت وزر الإغلاق
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _currentSupplication?.title ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _currentSupplication = null;
                    });
                  },
                  tooltip: 'إغلاق المشغل',
                ),
              ],
            ),
            // شريط تمرير للتحكم في موقع التشغيل
            StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final Duration position = snapshot.data ?? Duration.zero;
                final Duration duration =
                    _audioPlayer.duration ?? Duration.zero;
                return Column(
                  children: [
                    Slider(
                      min: 0.0,
                      max: duration.inSeconds.toDouble() > 0
                          ? duration.inSeconds.toDouble()
                          : 1.0,
                      value: position.inSeconds
                          .toDouble()
                          .clamp(0.0, duration.inSeconds.toDouble()),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white70,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatDuration(position),
                            style: const TextStyle(color: Colors.white)),
                        Text(formatDuration(duration),
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_currentSupplication != null) {
                  readText(_currentSupplication!);
                }
              },
              icon: const Icon(Icons.menu_book),
              label: const Text("قراءة"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            // صف أزرار التحكم في التشغيل (السابق، إعادة 10 ثوانٍ، تشغيل/إيقاف، تقديم 10 ثوانٍ، التالي)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: _playPrevious,
                  tooltip: 'السابق',
                ),
                IconButton(
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                  onPressed: _rewind10,
                  tooltip: 'إعادة 10 ثوانٍ',
                ),
                IconButton(
                  icon: Icon(
                    _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: _togglePlayPause,
                  tooltip: _audioPlayer.playing ? 'إيقاف' : 'تشغيل',
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                  onPressed: _forward10,
                  tooltip: 'تقديم 10 ثوانٍ',
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: _playNext,
                  tooltip: 'التالي',
                ),
              ],
            ),
            const SizedBox(height: 4),
            // صف يحتوي على مفاتيح التبديل للخصائص الإضافية (التكرار وتشغيل التالي تلقائي)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  value: _isRepeat,
                  onChanged: (bool value) {
                    setState(() {
                      _isRepeat = value;
                      _audioPlayer
                          .setLoopMode(_isRepeat ? LoopMode.one : LoopMode.off);
                    });
                  },
                  activeColor: accentBlue,
                  activeTrackColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: accentBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'تكرار',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: _isAutoNext,
                  onChanged: (bool value) {
                    setState(() {
                      _isAutoNext = value;
                    });
                  },
                  activeColor: accentBlue,
                  activeTrackColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: accentBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'تشغيل التالي تلقائي',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle = _selectedCategory;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle,
              style:
                  const TextStyle(fontFamily: 'Tajawal', color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: showInstructions,
              tooltip: 'تعليمات الاستخدام',
            ),
            IconButton(
              icon: const Icon(Icons.volunteer_activism, color: Colors.white),
              onPressed: () {
                confirmAndShowRewardedAd();
              },
              tooltip: 'تبرع بمشاهدة إعلان',
            ),
            // زر تبديل الوضع الليلي في الواجهة الرئيسية
            IconButton(
              icon: Icon(
                myAppKey.currentState?.isDarkMode ?? false
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Colors.white,
              ),
              tooltip: 'تغيير الوضع',
              onPressed: () {
                myAppKey.currentState?.toggleTheme();
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                child: const Center(
                  child: Text('الشيخ مشاري العفاسي',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
              ),
              ListTile(
                leading:
                    Icon(Icons.book, color: Theme.of(context).primaryColor),
                title: const Text("القرآن الكريم"),
                onTap: () {
                  updateCategory("القرآن الكريم");
                },
              ),
              ListTile(
                leading: Icon(Icons.music_note,
                    color: Theme.of(context).primaryColor),
                title: const Text("الأناشيد"),
                onTap: () {
                  updateCategory("الأناشيد");
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.personPraying,
                    color: Theme.of(context).primaryColor),
                title: const Text("الأذكار"),
                onTap: () {
                  updateCategory("الأذكار");
                },
              ),
              ListTile(
                leading: Icon(Icons.front_hand,
                    color: Theme.of(context).primaryColor),
                title: const Text("الأدعية"),
                onTap: () {
                  updateCategory("الأدعية");
                },
              ),
              ListTile(
                leading: Icon(Icons.dark_mode,
                    color: Theme.of(context).primaryColor),
                title: const Text("رمضانيات"),
                onTap: () {
                  updateCategory("رمضانيات");
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.healing, color: Theme.of(context).primaryColor),
                title: const Text("الرقية الشرعية"),
                onTap: () {
                  updateCategory("الرقية الشرعية");
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.favorite, color: Theme.of(context).primaryColor),
                title: const Text("المفضلة"),
                onTap: () {
                  updateCategory("المفضلة");
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.volunteer_activism, color: Theme.of(context).primaryColor),
                title: const Text("ادعم التطبيق"),
                onTap: () {
                  Navigator.pop(context); // إغلاق القائمة الجانبية
                  confirmAndShowRewardedAd(); // دالة موجودة عندك لعرض الإعلان
                },
              ),

              ListTile(
                leading:
                    Icon(Icons.alarm_on, color: Theme.of(context).primaryColor),
                title: const Text("منبة الأذكار"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdhkarReminderPage()),
                  );
                },
              ),
              // ListTile(
              //   leading:
              //       Icon(Icons.task, color: Theme.of(context).primaryColor),
              //   title: const Text("تذكيرات رمضان"),
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => RamadanTasksPage()),
              //     );
              //   },
              // ),
              ListTile(
                leading:
                    Icon(Icons.mosque, color: Theme.of(context).primaryColor),
                title: const Text("أوقات الصلاة"),
                onTap: () {
                  Navigator.pop(context); // إغلاق القائمة الجانبية
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrayerTimesPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.spa, color: Theme.of(context).primaryColor),
                title: const Text("المسبحة الإلكترونية"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TasbihPage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading:
                    Icon(Icons.shop, color: Theme.of(context).primaryColor),
                title: const Text("تطبيق القرآن الكريم"),
                onTap: () async {
                  Navigator.pop(context);
                  final Uri url = Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.quran.kareem.islamic');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('لا يمكن فتح الرابط.')),
                    );
                  }
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.help, color: Theme.of(context).primaryColor),
                title: const Text("تعليمات الاستخدام"),
                onTap: () {
                  Navigator.pop(context);
                  showInstructions();
                },
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip,
                    color: Theme.of(context).primaryColor),
                title: const Text("سياسة الخصوصية"),
                onTap: () {
                  Navigator.pop(context);
                  showPrivacyPolicyDialog();
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'ابحث هنا',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: filterSearchResults,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSupplications.length,
                itemBuilder: (context, index) {
                  final Supplication supp = filteredSupplications[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () {
                        if (_currentSupplication != null &&
                            _currentSupplication!.title == supp.title &&
                            _audioPlayer.playing) {
                          pauseAudio();
                        } else {
                          playAudio(supp);
                          checkAndShowInterstitialAd();
                        }
                      },
                      // ← أيقونة على يمين العنوان داخل دائرة
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(
                          supp.icon,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        supp.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        (supp.isLocalAudio || supp.isDownloaded)
                            ? 'متاح بدون إنترنت'
                            : 'قم بالتحميل لإستماع بدون إنترنت',
                        style: TextStyle(
                          color: (supp.isLocalAudio || supp.isDownloaded)
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 12,
                        children: [
                          IconButton(
                            icon: Icon(
                              _currentSupplication != null &&
                                  _currentSupplication!.title == supp.title &&
                                  _audioPlayer.playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              if (_currentSupplication != null &&
                                  _currentSupplication!.title == supp.title &&
                                  _audioPlayer.playing) {
                                pauseAudio();
                              } else {
                                playAudio(supp);
                                checkAndShowInterstitialAd();
                              }
                            },
                            tooltip: 'تشغيل/إيقاف',
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.download,
                              color: (supp.isLocalAudio || supp.isDownloaded)
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                            ),
                            onPressed: (supp.isLocalAudio || supp.isDownloaded)
                                ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                    Text('الصوت متاح بالفعل دون إنترنت.')),
                              );
                            }
                                : () {
                              downloadAudio(supp);
                            },
                            tooltip: 'تحميل الصوت',
                          ),
                          IconButton(
                            icon: Icon(
                              favorites.any((fav) => fav.title == supp.title)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                if (favorites.any((fav) => fav.title == supp.title)) {
                                  favorites.removeWhere((fav) => fav.title == supp.title);
                                } else {
                                  favorites.add(supp);
                                }
                                if (_selectedCategory == "المفضلة") {
                                  filteredSupplications = List<Supplication>.from(favorites);
                                }
                              });
                              saveFavorites();
                            },
                            tooltip: 'إضافة إلى المفضلة',
                          ),
                        ],
                      ),
                    ),
                  );
                },

              ),
            ),
            if (_bannerAd != null)
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
        bottomNavigationBar:
            _currentSupplication != null ? _buildAudioPlayer() : null,
      ),
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
        title: Text(widget.title,
            style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(widget.content,
                  style: TextStyle(fontSize: _fontSize, fontFamily: 'Tajawal')),
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
                          Text("تصغير",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
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
                          Text("تكبير",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
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

/////////////////////////////////////////////////////
////////////////////////////////////////////////////
///////////////////////////////////////////////////
// lib/main.dart

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'theme/app_theme.dart';
// import 'managers/notifications_manager.dart';
// import 'managers/ad_manager.dart';
// import 'managers/app_open_ad_manager.dart';
// import 'pages/home_page.dart';

// final GlobalKey<MyAppState> myAppKey = GlobalKey<MyAppState>();
// final AppOpenAdManager appOpenAdManager = AppOpenAdManager();
// late AppLifecycleReactor _appLifecycleReactor;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // تهيئة Firebase
//   await Firebase.initializeApp();
//   await NotificationsManager.initialize();

//   // تهيئة الإعلانات
//   await AdManager.initConsentForAds();
//   await AdManager.initializeAds();
//   appOpenAdManager.loadAd(); // تحميل إعلان الفتح (App Open)

//   // ربط مراقبة دورة حياة التطبيق بإعلان الفتح
//   _appLifecycleReactor = AppLifecycleReactor(appOpenAdManager);
//   WidgetsBinding.instance.addObserver(_appLifecycleReactor);

//   runApp(MyApp(key: myAppKey));
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   MyAppState createState() => MyAppState();
// }

// class MyAppState extends State<MyApp> {
//   bool _isDarkMode = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadTheme();
//   }

//   Future<void> _loadTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedTheme = prefs.getBool('isDarkMode') ?? false;
//     setState(() {
//       _isDarkMode = savedTheme;
//     });
//   }

//   void toggleTheme() async {
//     setState(() {
//       _isDarkMode = !_isDarkMode;
//     });
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isDarkMode', _isDarkMode);
//   }

//   bool get isDarkMode => _isDarkMode;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'تطبيق مشاري العفاسي',
//       debugShowCheckedModeBanner: false,
//       themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       locale: const Locale('ar', 'AE'),
//       supportedLocales: const [Locale('ar', 'AE')],
//       localizationsDelegates: GlobalMaterialLocalizations.delegates,
//       home: HomePage(isDarkMode: _isDarkMode),
//     );
//   }
// }
