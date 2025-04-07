import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart'; // تأكد من إضافتها في pubspec.yaml

/// نموذج بيانات لمهمة رمضان
class RamadanTask {
  final int id;
  String title;
  TimeOfDay reminderTime;
  bool isDaily;
  bool isActive;
  bool isCompleted;

  RamadanTask({
    required this.id,
    required this.title,
    required this.reminderTime,
    this.isDaily = false,
    this.isActive = true,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hour': reminderTime.hour,
      'minute': reminderTime.minute,
      'isDaily': isDaily,
      'isActive': isActive,
      'isCompleted': isCompleted,
    };
  }

  factory RamadanTask.fromJson(Map<String, dynamic> json) {
    return RamadanTask(
      id: json['id'],
      title: json['title'],
      reminderTime: TimeOfDay(hour: json['hour'], minute: json['minute']),
      isDaily: json['isDaily'] ?? false,
      isActive: json['isActive'] ?? true,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

/// صفحة تذكيرات مهام رمضان
class RamadanTasksPage extends StatefulWidget {
  @override
  _RamadanTasksPageState createState() => _RamadanTasksPageState();
}

class _RamadanTasksPageState extends State<RamadanTasksPage> {
  List<RamadanTask> _tasks = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // تهيئة مكتبة timezone
    tz.initializeTimeZones();
    _initializeNotifications();
    _loadTasks();
  }

  /// تهيئة الإشعارات المحلية مع إعداد الصوت المخصص وطلب إذن الإشعارات لأندرويد 13 وما فوق
  Future<void> _initializeNotifications() async {
    final initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    // تأكد من وجود أيقونة التطبيق في مجلد drawable أو mipmap
    final initializationSettingsIOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // طلب إذن الإشعارات لأجهزة أندرويد (خاصة Android 13 وما فوق)
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        // يمكن إضافة معالجة في حال لم يتم منح الإذن
        print("Notification permission not granted");
      }
    }
  }

  /// تحميل المهام من SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('ramadan_tasks');
    if (tasksJson != null) {
      final List<dynamic> jsonList = json.decode(tasksJson);
      setState(() {
        _tasks = jsonList.map((e) => RamadanTask.fromJson(e)).toList();
      });
    }
    _scheduleAllNotifications();
  }

  /// حفظ المهام في SharedPreferences وإعادة جدولة الإشعارات
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson =
        json.encode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('ramadan_tasks', tasksJson);
    _scheduleAllNotifications();
  }

  /// دالة مساعدة لتحويل TimeOfDay إلى TZDateTime
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    print(
        'Scheduled notification at: ${scheduledDate.toString()} (Now: ${now.toString()})');
    return scheduledDate;
  }

  /// جدولة إشعار لمهمة واحدة
  Future<void> _scheduleNotification(RamadanTask task) async {
    final androidDetails = AndroidNotificationDetails(
      'ramadan_tasks_channel',
      'Ramadan Tasks',
      channelDescription: 'Reminder notifications for Ramadan tasks',
      importance: Importance.max,
      priority: Priority.high,
      // تأكد من وضع ملف الصوت (بدون امتداد) في مجلد res/raw على أندرويد
      sound: RawResourceAndroidNotificationSound('ramadan_reminder'),
    );
    final iOSDetails = DarwinNotificationDetails(
      sound: 'ramadan_reminder.mp3',
    );
    final notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(task.reminderTime);

    // في حال كانت المهمة لمرة واحدة، لا نحتاج إلى matchDateTimeComponents
    final DateTimeComponents? dateTimeComponents =
        task.isDaily ? DateTimeComponents.time : null;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id,
      'تذكير مهمة رمضان',
      task.title,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: dateTimeComponents,
    );
  }

  /// إلغاء إشعار لمهمة بناءً على معرّفها
  Future<void> _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// جدولة الإشعارات لجميع المهام النشطة
  Future<void> _scheduleAllNotifications() async {
    for (var task in _tasks) {
      await _cancelNotification(task.id);
      if (task.isActive) {
        await _scheduleNotification(task);
      }
    }
  }

  /// عرض مربع حوار لإضافة أو تعديل مهمة مع تعليمات خطوة بخطوة
  void _showTaskDialog({RamadanTask? task}) {
    final TextEditingController titleController =
        TextEditingController(text: task?.title ?? '');
    TimeOfDay selectedTime = task?.reminderTime ?? TimeOfDay.now();
    bool isDaily = task?.isDaily ?? false;
    bool isActive = task?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? 'إضافة مهمة جديدة' : 'تعديل المهمة'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "خطوات إضافة المهمة:\n"
                      "1. أدخل عنوان المهمة بوضوح.\n"
                      "2. اختر وقت التذكير المناسب.\n"
                      "3. اختر إذا كانت المهمة تكرارية يومياً.\n"
                      "4. فعّل التذكير لتلقي الإشعار.",
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'عنوان المهمة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'وقت التذكير: ${selectedTime.format(context)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black,
                                      ),
                                    ),
                                    timePickerTheme: TimePickerThemeData(
                                      helpTextStyle:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              setStateDialog(() {
                                selectedTime = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تكرار يومي', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: isDaily,
                          onChanged: (value) {
                            setStateDialog(() {
                              isDaily = value;
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey[400],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تفعيل التذكير', style: TextStyle(fontSize: 16)),
                        Switch(
                          value: isActive,
                          onChanged: (value) {
                            setStateDialog(() {
                              isActive = value;
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                if (task == null) {
                  final newTask = RamadanTask(
                    id: DateTime.now().millisecondsSinceEpoch % 100000,
                    title: titleController.text.trim(),
                    reminderTime: selectedTime,
                    isDaily: isDaily,
                    isActive: isActive,
                  );
                  setState(() {
                    _tasks.add(newTask);
                  });
                } else {
                  setState(() {
                    task.title = titleController.text.trim();
                    task.reminderTime = selectedTime;
                    task.isDaily = isDaily;
                    task.isActive = isActive;
                    task.isCompleted = false;
                  });
                }
                _saveTasks();
                Navigator.pop(context);
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  /// حذف مهمة مع إلغاء إشعارها
  void _deleteTask(RamadanTask task) async {
    await _cancelNotification(task.id);
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
    _saveTasks();
  }

  /// إعادة تعيين حالة "المكتملة" لجميع المهام (مثلاً مع بداية اليوم)
  void _resetCompleted() {
    setState(() {
      for (var task in _tasks) {
        task.isCompleted = false;
      }
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تذكيرات مهام رمضان'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetCompleted,
            tooltip: 'إعادة تعيين المهام المكتملة',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            color: Colors.teal[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.nightlight_round, color: Colors.teal, size: 30),
                SizedBox(width: 8),
                Text(
                  'شهر مبارك إن شاء الله',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "يمكنك إضافة مهام يومية لعملها في رمضان مثل قراءة القرآن أو الأذكار أو أي نشاط آخر.\n"
              "لإضافة مهمة جديدة، اضغط على الزر 'إضافة مهمة جديدة' في أسفل الصفحة واتبع التعليمات خطوة بخطوة.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                        'وقت: ${task.reminderTime.format(context)} - ${task.isDaily ? "يومي" : "مرة واحدة"}'),
                    trailing: Wrap(
                      spacing: 12,
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            if (value == true && !task.isCompleted) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('مبروك!'),
                                    content: Text(
                                        'لقد أكملت المهمة بنجاح، استمر في عملك الجيد!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('حسناً'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            setState(() {
                              task.isCompleted = value ?? false;
                            });
                            _saveTasks();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showTaskDialog(task: task);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteTask(task);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _showTaskDialog,
          child: Text(
            'إضافة مهمة جديدة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
