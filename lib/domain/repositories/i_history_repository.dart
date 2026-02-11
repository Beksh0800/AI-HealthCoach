import '../../data/models/workout_history_model.dart';

/// Abstract interface for workout history operations
abstract class IHistoryRepository {
  /// Get workout history for a user
  Future<List<WorkoutHistory>> getUserHistory(String userUid);

  /// Get total workouts count
  Future<int> getTotalWorkouts(String userUid);

  /// Get total minutes trained
  Future<int> getTotalMinutes(String userUid);

  /// Get weekly workout stats (minutes per day, 7 values)
  Future<List<double>> getWeeklyStats(String userUid);

  /// Get monthly workout stats (minutes per day, 30 values)
  Future<List<double>> getMonthlyStats(String userUid);

  /// Get workout type distribution (type → count)
  Future<Map<String, int>> getWorkoutTypeDistribution(String userUid);
}
