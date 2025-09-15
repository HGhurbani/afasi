import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart'; // لإضافة تنسيق الوقت
import 'package:shared_preferences/shared_preferences.dart';

// تهيئة مكتبة الإشعارات
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('يرجى تفعيل خدمة الموقع.');
  }
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('تم رفض إذن الموقع.');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('تم رفض إذن الموقع بشكل دائم.');
  }
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

Future<PrayerTimes> calculatePrayerTimes() async {
  Position position = await getCurrentLocation();
  final coordinates = Coordinates(position.latitude, position.longitude);
  final params = CalculationMethod.egyptian.getParameters();
  params.madhab = Madhab.hanafi;
  final now = DateTime.now();
  final dateComponents = DateComponents(now.year, now.month, now.day);
  return PrayerTimes(coordinates, dateComponents, params);
}

Future<void> schedulePrayerNotification(
    String prayerName, DateTime time) async {
  if (time.isAfter(DateTime.now())) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prayer_channel',
      'Prayer Times',
      channelDescription: 'تنبيهات مواعيد الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('custom_prayer'),
    );
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      sound: 'custom_prayer.mp3',
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(time, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      prayerName.hashCode,
      'موعد صلاة $prayerName',
      'حان الآن موعد صلاة $prayerName',
      scheduledDate,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}

Future<void> schedulePrayerNotifications() async {
  final prayerTimes = await calculatePrayerTimes();
  await schedulePrayerNotification("الفجر", prayerTimes.fajr);
  await schedulePrayerNotification("الشروق", prayerTimes.sunrise);
  await schedulePrayerNotification("الظهر", prayerTimes.dhuhr);
  await schedulePrayerNotification("العصر", prayerTimes.asr);
  await schedulePrayerNotification("المغرب", prayerTimes.maghrib);
  await schedulePrayerNotification("العشاء", prayerTimes.isha);
}

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({Key? key}) : super(key: key);

  @override
  _PrayerTimesPageState createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  PrayerTimes? _prayerTimes;
  bool _notificationsScheduled = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    initializeNotifications();
    _loadNotificationPreference();
    _loadPrayerTimes();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsScheduled =
          prefs.getBool('notificationsScheduled') ?? false;
    });

    // إذا كانت الإشعارات مفعّلة سابقًا، يمكنك إعادة جدولة التنبيهات تلقائيًا
    // أو تركها إلى أن يضغط المستخدم على الزر
    if (_notificationsScheduled) {
      try {
        await schedulePrayerNotifications();
      } catch (e) {
        // يمكن التعامل مع الخطأ إن حصل
      }
    }
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final times = await calculatePrayerTimes();
      setState(() {
        _prayerTimes = times;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // دالة لتبديل تفعيل / إلغاء تفعيل الإشعارات
  Future<void> _toggleNotifications() async {
    if (_notificationsScheduled) {
      // إذا كانت الإشعارات مفعّلة، ألغها
      await flutterLocalNotificationsPlugin.cancelAll();
      setState(() {
        _notificationsScheduled = false;
      });

      // حفظ القيمة في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsScheduled', false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إلغاء تنبيهات الصلاة.')),
      );
    } else {
      // إذا كانت الإشعارات غير مفعّلة، قم بجدولتها
      try {
        await schedulePrayerNotifications();
        setState(() {
          _notificationsScheduled = true;
        });

        // حفظ القيمة في SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notificationsScheduled', true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم جدولة تنبيهات الصلاة بنجاح.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء جدولة الإشعارات: $e')),
        );
      }
    }
  }

  // تعديل دالة تنسيق الوقت باستخدام intl لصيغة 12 ساعة
  String _formatTime(DateTime dt) {
    return DateFormat('h:mm a', 'ar').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كان التطبيق في الوضع الليلي أم لا
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDarkMode
        ? [Colors.black87, Colors.black54]
        : [const Color(0xFF3498DB), const Color(0xFF2980B9)];
    // تخصيص لون خلفية الأيقونات حسب الوضع
    final iconBackgroundColor =
        isDarkMode ? Colors.grey[800] : const Color(0xFF3498DB);

    final List<Map<String, dynamic>> prayers = _prayerTimes == null
        ? []
        : [
            {
              'name': 'الفجر',
              'time': _prayerTimes!.fajr,
              'icon': Icons.nightlight_round
            },
            {
              'name': 'الشروق',
              'time': _prayerTimes!.sunrise,
              'icon': Icons.wb_twilight
            },
            {
              'name': 'الظهر',
              'time': _prayerTimes!.dhuhr,
              'icon': Icons.wb_sunny
            },
            {
              'name': 'العصر',
              'time': _prayerTimes!.asr,
              'icon': Icons.access_time
            },
            {
              'name': 'المغرب',
              'time': _prayerTimes!.maghrib,
              'icon': Icons.nights_stay
            },
            {
              'name': 'العشاء',
              'time': _prayerTimes!.isha,
              'icon': Icons.brightness_3
            },
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("أوقات الصلاة"),
        centerTitle: true,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    "خطأ: $_error",
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...prayers.map((prayer) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: iconBackgroundColor,
                              child: Icon(prayer['icon'], color: Colors.white),
                            ),
                            title: Text(
                              prayer['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              _formatTime(prayer['time']),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _toggleNotifications,
                          icon: Icon(_notificationsScheduled
                              ? Icons.notifications_off
                              : Icons.notifications_active),
                          label: Text(_notificationsScheduled
                              ? "إلغاء تنبيهات الصلاة"
                              : "تفعيل تنبيهات الصلاة"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            textStyle: const TextStyle(
                                fontSize: 18, fontFamily: 'Tajawal'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
