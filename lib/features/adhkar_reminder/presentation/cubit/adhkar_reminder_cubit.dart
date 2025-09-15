import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/adhkar_reminder_service.dart';

class AdhkarReminderState extends Equatable {
  final bool morningEnabled;
  final bool eveningEnabled;
  final TimeOfDay morningTime;
  final TimeOfDay eveningTime;
  final bool isLoading;
  final String? errorMessage;
  final String? statusMessage;

  const AdhkarReminderState({
    this.morningEnabled = false,
    this.eveningEnabled = false,
    this.morningTime = const TimeOfDay(hour: 6, minute: 0),
    this.eveningTime = const TimeOfDay(hour: 18, minute: 0),
    this.isLoading = false,
    this.errorMessage,
    this.statusMessage,
  });

  AdhkarReminderState copyWith({
    bool? morningEnabled,
    bool? eveningEnabled,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    bool? isLoading,
    String? errorMessage,
    String? statusMessage,
  }) {
    return AdhkarReminderState(
      morningEnabled: morningEnabled ?? this.morningEnabled,
      eveningEnabled: eveningEnabled ?? this.eveningEnabled,
      morningTime: morningTime ?? this.morningTime,
      eveningTime: eveningTime ?? this.eveningTime,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      statusMessage: statusMessage,
    );
  }

  @override
  List<Object?> get props => [
        morningEnabled,
        eveningEnabled,
        morningTime,
        eveningTime,
        isLoading,
        errorMessage,
        statusMessage,
      ];
}

class AdhkarReminderCubit extends Cubit<AdhkarReminderState> {
  AdhkarReminderCubit({required AdhkarReminderService service})
      : _service = service,
        super(const AdhkarReminderState());

  final AdhkarReminderService _service;
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true, errorMessage: null, statusMessage: null));
    try {
      await _service.initialize();
      await _requestPermissions();
      _prefs ??= await SharedPreferences.getInstance();

      final morningEnabled = _prefs!.getBool('morningEnabled') ?? false;
      final eveningEnabled = _prefs!.getBool('eveningEnabled') ?? false;
      final morningHour = _prefs!.getInt('morningHour');
      final morningMinute = _prefs!.getInt('morningMinute');
      final eveningHour = _prefs!.getInt('eveningHour');
      final eveningMinute = _prefs!.getInt('eveningMinute');

      TimeOfDay morningTime = state.morningTime;
      TimeOfDay eveningTime = state.eveningTime;

      if (morningHour != null && morningMinute != null) {
        morningTime = TimeOfDay(hour: morningHour, minute: morningMinute);
      }
      if (eveningHour != null && eveningMinute != null) {
        eveningTime = TimeOfDay(hour: eveningHour, minute: eveningMinute);
      }

      var updatedState = state.copyWith(
        morningEnabled: morningEnabled,
        eveningEnabled: eveningEnabled,
        morningTime: morningTime,
        eveningTime: eveningTime,
        isLoading: false,
        errorMessage: null,
        statusMessage: null,
      );
      emit(updatedState);
      await _saveSettings(updatedState);

      if (morningEnabled) {
        await _scheduleMorningReminder(morningTime);
      }
      if (eveningEnabled) {
        await _scheduleEveningReminder(eveningTime);
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        statusMessage: null,
      ));
    }
  }

  Future<void> toggleMorning(bool enabled) async {
    final updatedState = state.copyWith(
      morningEnabled: enabled,
      errorMessage: null,
      statusMessage: null,
    );
    emit(updatedState);
    await _saveSettings(updatedState);

    try {
      if (enabled) {
        await _scheduleMorningReminder(updatedState.morningTime);
        emit(state.copyWith(statusMessage: 'تم تفعيل تذكير أذكار الصباح'));
      } else {
        await _service.cancelReminder(100);
        emit(state.copyWith(statusMessage: 'تم تعطيل تذكير أذكار الصباح'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> toggleEvening(bool enabled) async {
    final updatedState = state.copyWith(
      eveningEnabled: enabled,
      errorMessage: null,
      statusMessage: null,
    );
    emit(updatedState);
    await _saveSettings(updatedState);

    try {
      if (enabled) {
        await _scheduleEveningReminder(updatedState.eveningTime);
        emit(state.copyWith(statusMessage: 'تم تفعيل تذكير أذكار المساء'));
      } else {
        await _service.cancelReminder(101);
        emit(state.copyWith(statusMessage: 'تم تعطيل تذكير أذكار المساء'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> updateMorningTime(TimeOfDay time) async {
    final updatedState = state.copyWith(
      morningTime: time,
      errorMessage: null,
      statusMessage: null,
    );
    emit(updatedState);
    await _saveSettings(updatedState);

    if (state.morningEnabled) {
      try {
        await _scheduleMorningReminder(time);
        emit(state.copyWith(statusMessage: 'تم تحديث وقت تذكير أذكار الصباح'));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString()));
      }
    }
  }

  Future<void> updateEveningTime(TimeOfDay time) async {
    final updatedState = state.copyWith(
      eveningTime: time,
      errorMessage: null,
      statusMessage: null,
    );
    emit(updatedState);
    await _saveSettings(updatedState);

    if (state.eveningEnabled) {
      try {
        await _scheduleEveningReminder(time);
        emit(state.copyWith(statusMessage: 'تم تحديث وقت تذكير أذكار المساء'));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString()));
      }
    }
  }

  void clearMessages() {
    if (state.statusMessage != null || state.errorMessage != null) {
      emit(state.copyWith(statusMessage: null, errorMessage: null));
    }
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    final androidPlugin = _service.plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      try {
        await (androidPlugin as dynamic).requestPermission();
      } catch (_) {
        // تجاهل في حال عدم توفر الدالة
      }
    }
  }

  Future<void> _scheduleMorningReminder(TimeOfDay time) {
    return _service.scheduleDailyReminder(
      id: 100,
      timeOfDay: time,
      title: 'أذكار الصباح',
      body: 'حان وقت أذكار الصباح',
      sound: 'mishary1.mp3',
    );
  }

  Future<void> _scheduleEveningReminder(TimeOfDay time) {
    return _service.scheduleDailyReminder(
      id: 101,
      timeOfDay: time,
      title: 'أذكار المساء',
      body: 'حان وقت أذكار المساء',
      sound: 'mishary2.mp3',
    );
  }

  Future<void> _saveSettings(AdhkarReminderState current) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool('morningEnabled', current.morningEnabled);
    await prefs.setBool('eveningEnabled', current.eveningEnabled);
    await prefs.setInt('morningHour', current.morningTime.hour);
    await prefs.setInt('morningMinute', current.morningTime.minute);
    await prefs.setInt('eveningHour', current.eveningTime.hour);
    await prefs.setInt('eveningMinute', current.eveningTime.minute);
  }

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }
}
