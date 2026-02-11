import '../../data/models/user_profile_model.dart';
import '../../data/models/daily_checkin_model.dart';
import '../../data/models/workout_model.dart';
import '../services/i_ai_service.dart';
import '../repositories/i_exercise_repository.dart';

/// Use case: Generates a safe, personalized workout
///
/// Business rules:
/// 1. If painLevel >= 7 → throw (workout not recommended)
/// 2. Filter exercises by user contraindications
/// 3. Determine workout type based on pain + energy
/// 4. Call AI service with filtered data
class GenerateWorkoutUseCase {
  final IAiService _aiService;
  final IExerciseRepository _exerciseRepository;

  GenerateWorkoutUseCase({
    required IAiService aiService,
    required IExerciseRepository exerciseRepository,
  })  : _aiService = aiService,
        _exerciseRepository = exerciseRepository;

  /// Execute the use case
  ///
  /// Throws [WorkoutNotRecommendedException] if painLevel >= 7
  /// Throws [AIServiceNotConfiguredException] if AI is not set up
  Future<Workout> call({
    required UserProfile profile,
    required DailyCheckIn checkIn,
    String? preferredType,
  }) async {
    // Rule 1: Check if workout is safe
    if (checkIn.painLevel >= 7) {
      throw WorkoutNotRecommendedException(
        'Уровень боли слишком высокий (${checkIn.painLevel}/10). '
        'Рекомендуем отдых и консультацию врача.',
      );
    }

    // Rule 2: Check AI availability
    if (!_aiService.isConfigured) {
      throw AIServiceNotConfiguredException(
        'ИИ-сервис не настроен. Проверьте API ключи.',
      );
    }

    // Rule 3: Get exercises and filter by contraindications
    final allExercises = await _exerciseRepository.getExercises();
    final userContraindications = profile.medicalProfile.contraindications;

    final safeExercises = allExercises
        .where((e) => e.isSafeFor(userContraindications))
        .toList();

    // Rule 4: Determine workout type
    final workoutType = _determineWorkoutType(checkIn, preferredType);

    // Rule 5: Generate via AI
    return await _aiService.generateWorkout(
      profile: profile,
      checkIn: checkIn,
      workoutType: workoutType,
      availableExercises: safeExercises,
    );
  }

  /// Determine the best workout type based on check-in data
  String _determineWorkoutType(DailyCheckIn checkIn, String? preferred) {
    if (preferred != null) return preferred;

    // High pain → LFK (therapeutic)
    if (checkIn.painLevel >= 4) return WorkoutTypes.lfk;

    // Low energy → Stretching
    if (checkIn.energyLevel <= 2) return WorkoutTypes.stretching;

    // Stressed → LFK or stretching
    if (checkIn.mood == 'stressed') return WorkoutTypes.stretching;

    // Good condition → strength allowed
    if (checkIn.energyLevel >= 4 && checkIn.painLevel <= 2) {
      return WorkoutTypes.strength;
    }

    return WorkoutTypes.lfk;
  }
}

/// Exception: workout is not recommended due to health state
class WorkoutNotRecommendedException implements Exception {
  final String message;
  WorkoutNotRecommendedException(this.message);

  @override
  String toString() => message;
}

/// Exception: AI service is not configured
class AIServiceNotConfiguredException implements Exception {
  final String message;
  AIServiceNotConfiguredException(this.message);

  @override
  String toString() => message;
}
