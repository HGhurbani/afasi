
import 'package:get_it/get_it.dart';
import '../../data/repositories/audio_repository.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../../features/adhkar_reminder/data/services/adhkar_reminder_service.dart';
import '../../features/adhkar_reminder/presentation/cubit/adhkar_reminder_cubit.dart';
import '../../features/audio/bloc/audio_bloc.dart';
import '../../features/prayer_times/data/repositories/prayer_times_repository.dart';
import '../../features/prayer_times/data/services/prayer_notification_service.dart';
import '../../features/prayer_times/presentation/cubit/prayer_times_cubit.dart';
import '../../features/tasbih/presentation/cubit/tasbih_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Initialize storage
  await StorageService.init();
  
  // Services
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  getIt.registerLazySingleton<AdhkarReminderService>(
      () => AdhkarReminderService());
  getIt.registerLazySingleton<PrayerNotificationService>(
      () => PrayerNotificationService());

  // Repositories
  getIt.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl());
  getIt.registerLazySingleton<PrayerTimesRepository>(
      () => PrayerTimesRepository());

  // BLoCs
  getIt.registerFactory<AudioBloc>(() => AudioBloc(
    audioRepository: getIt<AudioRepository>(),
    audioService: getIt<AudioService>(),
  ));
  getIt.registerFactory<TasbihCubit>(() => TasbihCubit());
  getIt.registerFactory<AdhkarReminderCubit>(
      () => AdhkarReminderCubit(service: getIt<AdhkarReminderService>()));
  getIt.registerFactory<PrayerTimesCubit>(() => PrayerTimesCubit(
        prayerTimesRepository: getIt<PrayerTimesRepository>(),
        notificationService: getIt<PrayerNotificationService>(),
      ));
}
