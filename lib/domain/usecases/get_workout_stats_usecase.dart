import '../../data/services/workout_analytics_service.dart';

/// Use case: Retrieves workout statistics and generates recommendations
class GetWorkoutStatsUseCase {
  final WorkoutAnalyticsService _analyticsService;

  GetWorkoutStatsUseCase({
    required WorkoutAnalyticsService analyticsService,
  }) : _analyticsService = analyticsService;

  /// Get full workout statistics for a user
  Future<WorkoutStats> call(String userId) async {
    return await _analyticsService.getWorkoutStats(userId);
  }

  /// Get personalized workout suggestions
  Future<List<String>> getSuggestions(String userId) async {
    return await _analyticsService.getWorkoutSuggestions(userId);
  }

  /// Get recommended intensity based on user history
  Future<String> getRecommendedIntensity(String userId) async {
    return await _analyticsService.getRecommendedIntensity(userId);
  }
}
