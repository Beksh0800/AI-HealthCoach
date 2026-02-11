import '../../data/models/exercise_model.dart';

/// Abstract interface for exercise data operations
abstract class IExerciseRepository {
  /// Get all available exercises
  Future<List<Exercise>> getExercises();

  /// Get exercises by specific type (lfk, stretching, strength)
  Future<List<Exercise>> getExercisesByType(String type);

  /// Get exercise by ID
  Future<Exercise?> getExerciseById(String id);

  /// Get exercises filtered by difficulty
  Future<List<Exercise>> getExercisesByDifficulty(String difficulty);
}
