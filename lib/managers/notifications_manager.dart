// lib/managers/notifications_manager.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// الدالة التي يتم استدعاؤها عند استقبال إشعارات في الخلفية
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class NotificationsManager {
  static Future<void> initialize() async {
    // استدعاء دوال أو تهيئة إضافية إن لزم
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // طلب إذن الإشعارات
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // الاستماع للإشعارات في foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground!');
      if (message.notification != null) {
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');
      }
    });

    // الاستماع عند فتح التطبيق من الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
    });
  }
}
