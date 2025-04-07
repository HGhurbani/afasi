import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class AdhkarReminderManager {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// تهيئة الإشعارات المحلية
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // تأكد من تعيين أيقونة صحيحة
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// جدولة تذكير يومي باستخدام TimeOfDay (للتذكير بصوت مُخصص)
  static Future<void> scheduleDailyReminder({
    required int id,
    required TimeOfDay timeOfDay,
    required String title,
    required String body,
    required String sound,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    debugPrint("Scheduled notification $id at: $scheduledDate");
    var androidDetails = AndroidNotificationDetails(
      'adhkar_channel',
      'أذكار',
      channelDescription: 'تذكيرات أذكار الصباح والمساء',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(sound.replaceAll('.mp3', '')),
      playSound: true,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// إلغاء تذكير محدد باستخدام الـ id
  static Future<void> cancelReminder(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
