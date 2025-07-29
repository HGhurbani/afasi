
import 'package:get_it/get_it.dart';
import '../../data/repositories/audio_repository.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../../features/audio/bloc/audio_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Initialize storage
  await StorageService.init();
  
  // Services
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  
  // Repositories
  getIt.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl());
  
  // BLoCs
  getIt.registerFactory<AudioBloc>(() => AudioBloc(
    audioRepository: getIt<AudioRepository>(),
    audioService: getIt<AudioService>(),
  ));
}
