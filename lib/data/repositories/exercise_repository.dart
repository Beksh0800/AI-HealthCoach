import '../../domain/repositories/i_exercise_repository.dart';
import '../models/exercise_model.dart';
import '../datasources/initial_exercises.dart';

class ExerciseRepository implements IExerciseRepository {
  /// Get all available exercises
  @override
  Future<List<Exercise>> getExercises() async {
    // Simulate async loads
    // await Future.delayed(const Duration(milliseconds: 100));
    return initialExercises;
  }

  /// Get exercises by specific type (lfk, stretching, strength)
  @override
  Future<List<Exercise>> getExercisesByType(String type) async {
    return initialExercises.where((e) => e.type == type).toList();
  }

  /// Get exercise by ID
  @override
  Future<Exercise?> getExerciseById(String id) async {
    try {
      return initialExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get a list of exercises suitable for a specific difficulty
  @override
  Future<List<Exercise>> getExercisesByDifficulty(String difficulty) async {
    return initialExercises.where((e) => e.difficulty == difficulty).toList();
  }
}
