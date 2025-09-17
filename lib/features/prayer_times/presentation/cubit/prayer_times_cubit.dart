import 'package:adhan/adhan.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/prayer_times_repository.dart';
import '../../data/services/prayer_notification_service.dart';

class PrayerTimesState extends Equatable {
  final PrayerTimes? prayerTimes;
  final bool notificationsEnabled;
  final bool isLoading;
  final String? errorMessage;
  final String? statusMessage;

  const PrayerTimesState({
    this.prayerTimes,
    this.notificationsEnabled = false,
    this.isLoading = false,
    this.errorMessage,
    this.statusMessage,
  });

  PrayerTimesState copyWith({
    PrayerTimes? prayerTimes,
    bool? notificationsEnabled,
    bool? isLoading,
    String? errorMessage,
    String? statusMessage,
  }) {
    return PrayerTimesState(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      statusMessage: statusMessage,
    );
  }

  @override
  List<Object?> get props => [
        prayerTimes,
        notificationsEnabled,
        isLoading,
        errorMessage,
        statusMessage,
      ];
}

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  PrayerTimesCubit({
    required PrayerTimesRepository prayerTimesRepository,
    required PrayerNotificationService notificationService,
  })  : _repository = prayerTimesRepository,
        _notificationService = notificationService,
        super(const PrayerTimesState());

  final PrayerTimesRepository _repository;
  final PrayerNotificationService _notificationService;
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true, errorMessage: null, statusMessage: null));
    try {
      await _notificationService.initialize();
      _prefs ??= await SharedPreferences.getInstance();
      final notificationsEnabled =
          _prefs!.getBool('notificationsScheduled') ?? false;

      final times = await _repository.fetchPrayerTimes();
      emit(state.copyWith(
        prayerTimes: times,
        notificationsEnabled: notificationsEnabled,
        isLoading: false,
        errorMessage: null,
        statusMessage: null,
      ));

      if (notificationsEnabled) {
        try {
          await _rescheduleNotifications(times);
        } catch (e) {
          if (e is NotificationPermissionDeniedException) {
            await _prefs?.setBool('notificationsScheduled', false);
            emit(state.copyWith(
              notificationsEnabled: false,
              errorMessage: e.toString(),
            ));
          } else {
            emit(state.copyWith(errorMessage: e.toString()));
          }
        }
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refreshPrayerTimes() async {
    emit(state.copyWith(isLoading: true, errorMessage: null, statusMessage: null));
    try {
      final times = await _repository.fetchPrayerTimes();
      emit(state.copyWith(
        prayerTimes: times,
        isLoading: false,
        errorMessage: null,
        statusMessage: null,
      ));

      if (state.notificationsEnabled) {
        try {
          await _rescheduleNotifications(times);
        } catch (e) {
          if (e is NotificationPermissionDeniedException) {
            await _prefs?.setBool('notificationsScheduled', false);
            emit(state.copyWith(
              notificationsEnabled: false,
              errorMessage: e.toString(),
            ));
          } else {
            emit(state.copyWith(errorMessage: e.toString()));
          }
        }
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> toggleNotifications() async {
    final times = state.prayerTimes;
    if (times == null) {
      emit(state.copyWith(
        errorMessage: 'لا يمكن جدولة التنبيهات قبل تحميل أوقات الصلاة.',
      ));
      return;
    }

    final prefs = await _ensurePrefs();
    if (state.notificationsEnabled) {
      await _notificationService.cancelAll();
      await prefs.setBool('notificationsScheduled', false);
      emit(state.copyWith(
        notificationsEnabled: false,
        statusMessage: 'تم إلغاء تنبيهات الصلاة.',
        errorMessage: null,
      ));
    } else {
      try {
        await _rescheduleNotifications(times);
        await prefs.setBool('notificationsScheduled', true);
        emit(state.copyWith(
          notificationsEnabled: true,
          statusMessage: 'تم جدولة تنبيهات الصلاة بنجاح.',
          errorMessage: null,
        ));
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

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _rescheduleNotifications(PrayerTimes times) async {
    final hasPermission =
        await _notificationService.requestNotificationPermission();

    if (!hasPermission) {
      throw const NotificationPermissionDeniedException();
    }

    await _notificationService.cancelAll();
    await _notificationService.schedulePrayerNotifications(times);
  }
}

class NotificationPermissionDeniedException implements Exception {
  const NotificationPermissionDeniedException();

  @override
  String toString() =>
      'تم رفض إذن الإشعارات. يرجى تفعيل الإذن من إعدادات النظام للسماح بالتنبيهات.';
}
