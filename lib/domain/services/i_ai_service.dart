import '../../data/models/user_profile_model.dart';
import '../../data/models/daily_checkin_model.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/ai_feedback_models.dart';

/// Abstract interface for AI workout generation service
///
/// Implemented by [GeminiService] which handles both Gemini and OpenRouter.
abstract class IAiService {
  /// Whether the service is properly configured with API keys
  bool get isConfigured;

  /// Generate a personalized workout based on user profile and check-in
  Future<Workout> generateWorkout({
    required UserProfile profile,
    required DailyCheckIn checkIn,
    required String workoutType,
    required List<Exercise> availableExercises,
    String? targetIntensity,
  });

  /// Replace a specific exercise with a safe alternative
  Future<WorkoutExercise?> replaceExercise({
    required WorkoutExercise currentExercise,
    required String painLocation,
    required UserProfile profile,
    required List<Exercise> availableExercises,
  });

  /// Explain why an exercise is safe for the user (Encyclopedia feature)
  Future<String> explainExerciseSafety({
    required String exerciseName,
    required String exerciseDescription,
    required UserProfile profile,
  });

  /// Generate a quick recommendation based on check-in
  Future<String> getQuickRecommendation(DailyCheckIn checkIn);

  /// Generate personalized post-workout feedback
  Future<PostWorkoutFeedback> generatePostWorkoutFeedback({
    required int durationMinutes,
    required int exercisesCompleted,
    required int totalExercises,
    required String workoutType,
    required int painReports,
    required UserProfile profile,
    List<String>? painLocations,
  });

  /// Calculate pain-adapted intensity based on user's pain history
  Future<PainAdaptedIntensity> getPainAdaptedIntensity({
    required DailyCheckIn todayCheckIn,
    required List<String> recentPainReports,
    required int recentWorkoutCount,
  });
}
