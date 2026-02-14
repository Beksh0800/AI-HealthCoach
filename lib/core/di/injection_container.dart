import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Domain interfaces
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/repositories/i_checkin_repository.dart';
import '../../domain/repositories/i_history_repository.dart';
import '../../domain/repositories/i_exercise_repository.dart';
import '../../domain/services/i_ai_service.dart';
import '../../domain/usecases/generate_workout_usecase.dart';
import '../../domain/usecases/save_checkin_usecase.dart';
import '../../domain/usecases/get_workout_stats_usecase.dart';

// Data layer implementations
import '../../data/services/database_service.dart';
import '../../data/services/gemini_service.dart';
import '../../data/services/workout_persistence_service.dart';
import '../../data/services/workout_analytics_service.dart';
import '../../data/services/workout_cache_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/analytics_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/checkin_repository.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/exercise_repository.dart';

// Presentation layer
import '../../presentation/blocs/auth/auth_cubit.dart';
import '../../presentation/blocs/profile/profile_cubit.dart';
import '../../presentation/blocs/checkin/checkin_cubit.dart';
import '../../presentation/blocs/workout/workout_cubit.dart';
import '../../presentation/blocs/history/history_cubit.dart';

/// Global service locator instance
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // Firebase instances
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Services (registered by interface + concrete for direct access)
  sl.registerLazySingleton<DatabaseService>(() => DatabaseService());
  sl.registerLazySingleton<GeminiService>(() => GeminiService());
  sl.registerLazySingleton<IAiService>(() => sl<GeminiService>());
  sl.registerLazySingleton<WorkoutPersistenceService>(() => WorkoutPersistenceService());
  sl.registerLazySingleton<WorkoutAnalyticsService>(
    () => WorkoutAnalyticsService(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  sl.registerLazySingleton<WorkoutCacheService>(() => WorkoutCacheService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  // Repositories (registered by interface)
  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<IUserRepository>(() => sl<UserRepository>());

  sl.registerLazySingleton<CheckInRepository>(
    () => CheckInRepository(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ICheckInRepository>(() => sl<CheckInRepository>());

  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepository(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<IHistoryRepository>(() => sl<HistoryRepository>());

  sl.registerLazySingleton<ExerciseRepository>(
    () => ExerciseRepository(databaseService: sl<DatabaseService>()),
  );
  sl.registerLazySingleton<IExerciseRepository>(() => sl<ExerciseRepository>());

  // Use Cases
  sl.registerLazySingleton<GenerateWorkoutUseCase>(
    () => GenerateWorkoutUseCase(
      aiService: sl<IAiService>(),
      exerciseRepository: sl<IExerciseRepository>(),
    ),
  );
  sl.registerLazySingleton<SaveCheckInUseCase>(
    () => SaveCheckInUseCase(
      checkInRepository: sl<ICheckInRepository>(),
    ),
  );
  sl.registerLazySingleton<GetWorkoutStatsUseCase>(
    () => GetWorkoutStatsUseCase(
      analyticsService: sl<WorkoutAnalyticsService>(),
    ),
  );

  // BLoCs/Cubits (depend on interfaces)
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      auth: sl<FirebaseAuth>(),
      userRepository: sl<IUserRepository>(),
    ),
  );

  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      userRepository: sl<IUserRepository>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  sl.registerFactory<CheckInCubit>(
    () => CheckInCubit(
      checkInRepository: sl<ICheckInRepository>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  sl.registerFactory<WorkoutCubit>(
    () => WorkoutCubit(
      geminiService: sl<IAiService>(),
      exerciseRepository: sl<IExerciseRepository>(),
      persistenceService: sl<WorkoutPersistenceService>(),
      analyticsService: sl<WorkoutAnalyticsService>(),
      cacheService: sl<WorkoutCacheService>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerFactory<HistoryCubit>(
    () => HistoryCubit(
      repository: sl<IHistoryRepository>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
