import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'adhkar_reminder_manager.dart';

class AdhkarReminderPage extends StatefulWidget {
  static const routeName = '/adhkar-reminder';

  const AdhkarReminderPage({Key? key}) : super(key: key);

  @override
  _AdhkarReminderPageState createState() => _AdhkarReminderPageState();
}

class _AdhkarReminderPageState extends State<AdhkarReminderPage> {
  bool morningEnabled = false;
  bool eveningEnabled = false;
  TimeOfDay morningTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay eveningTime = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    _requestPermissions(); // طلب صلاحيات الإشعارات
    AdhkarReminderManager.initialize(); // تهيئة الإشعارات
    loadSettings();
  }

  /// دالة لطلب صلاحية الإشعارات باستخدام permission_handler
  Future<void> _requestPermissions() async {
    // تأكد من طلب إذن الإشعارات على أجهزة Android 13 وما فوق
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      debugPrint("Notification permission status: $status");
    }

    // اطلب الإذن أيضاً من flutter_local_notifications في حال كان مطلوباً
    final androidPlugin =
        AdhkarReminderManager.flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      try {
        // Some versions of flutter_local_notifications may not expose
        // `requestPermission`, so call it dynamically if available.
        // ignore: avoid_dynamic_calls
        await (androidPlugin as dynamic).requestPermission();
      } catch (e) {
        debugPrint('requestPermission not available: $e');
      }
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      morningEnabled = prefs.getBool('morningEnabled') ?? false;
      eveningEnabled = prefs.getBool('eveningEnabled') ?? false;
      final int? morningHour = prefs.getInt('morningHour');
      final int? morningMinute = prefs.getInt('morningMinute');
      final int? eveningHour = prefs.getInt('eveningHour');
      final int? eveningMinute = prefs.getInt('eveningMinute');

      if (morningHour != null && morningMinute != null) {
        morningTime = TimeOfDay(hour: morningHour, minute: morningMinute);
      }
      if (eveningHour != null && eveningMinute != null) {
        eveningTime = TimeOfDay(hour: eveningHour, minute: eveningMinute);
      }
    });

    if (morningEnabled) scheduleMorningReminder();
    if (eveningEnabled) scheduleEveningReminder();
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('morningEnabled', morningEnabled);
    await prefs.setBool('eveningEnabled', eveningEnabled);
    await prefs.setInt('morningHour', morningTime.hour);
    await prefs.setInt('morningMinute', morningTime.minute);
    await prefs.setInt('eveningHour', eveningTime.hour);
    await prefs.setInt('eveningMinute', eveningTime.minute);
  }

  Future<void> selectTime(bool isMorning) async {
    final TimeOfDay initialTime = isMorning ? morningTime : eveningTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.black, // يجعل أزرار "موافق" و "إلغاء" سوداء
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              helpTextStyle:
                  const TextStyle(color: Colors.black), // يجعل العنوان أسود
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isMorning) {
          morningTime = picked;
          if (morningEnabled) scheduleMorningReminder();
        } else {
          eveningTime = picked;
          if (eveningEnabled) scheduleEveningReminder();
        }
      });
      saveSettings();
    }
  }

  Future<void> scheduleMorningReminder() async {
    debugPrint("🔔 جدولة تذكير الصباح: ${morningTime.format(context)}");
    await AdhkarReminderManager.cancelReminder(100);
    await AdhkarReminderManager.scheduleDailyReminder(
      id: 100,
      timeOfDay: morningTime,
      title: 'أذكار الصباح',
      body: 'حان وقت أذكار الصباح',
      sound: 'mishary1.mp3',
    );
  }

  Future<void> scheduleEveningReminder() async {
    debugPrint("🔔 جدولة تذكير المساء: ${eveningTime.format(context)}");
    await AdhkarReminderManager.cancelReminder(101);
    await AdhkarReminderManager.scheduleDailyReminder(
      id: 101,
      timeOfDay: eveningTime,
      title: 'أذكار المساء',
      body: 'حان وقت أذكار المساء',
      sound: 'mishary2.mp3',
    );
  }

  Future<void> toggleMorning(bool enabled) async {
    setState(() {
      morningEnabled = enabled;
    });
    saveSettings();

    if (enabled) {
      await scheduleMorningReminder();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تفعيل تذكير أذكار الصباح")),
      );
    } else {
      debugPrint("⛔️ إلغاء تذكير الصباح");
      await AdhkarReminderManager.cancelReminder(100);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تعطيل تذكير أذكار الصباح")),
      );
    }
  }

  Future<void> toggleEvening(bool enabled) async {
    setState(() {
      eveningEnabled = enabled;
    });
    saveSettings();

    if (enabled) {
      await scheduleEveningReminder();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تفعيل تذكير أذكار المساء")),
      );
    } else {
      debugPrint("⛔️ إلغاء تذكير المساء");
      await AdhkarReminderManager.cancelReminder(101);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تعطيل تذكير أذكار المساء")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final switchActiveColor = theme.colorScheme.primary;
    final switchInactiveThumbColor = Colors.grey;
    final switchInactiveTrackColor = Colors.grey.withOpacity(0.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('منبة الأذكار'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('تذكير أذكار الصباح'),
                subtitle: Text('الوقت: ${morningTime.format(context)}'),
                trailing: Switch(
                  value: morningEnabled,
                  onChanged: toggleMorning,
                  activeColor: switchActiveColor,
                  inactiveThumbColor: switchInactiveThumbColor,
                  inactiveTrackColor: switchInactiveTrackColor,
                ),
                onTap: () => selectTime(true),
              ),
            ),
            const SizedBox(height: 8.0),
            Card(
              child: ListTile(
                title: const Text('تذكير أذكار المساء'),
                subtitle: Text('الوقت: ${eveningTime.format(context)}'),
                trailing: Switch(
                  value: eveningEnabled,
                  onChanged: toggleEvening,
                  activeColor: switchActiveColor,
                  inactiveThumbColor: switchInactiveThumbColor,
                  inactiveTrackColor: switchInactiveTrackColor,
                ),
                onTap: () => selectTime(false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
