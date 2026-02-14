import '../../domain/repositories/i_exercise_repository.dart';
import '../models/exercise_model.dart';
import '../datasources/initial_exercises.dart';
import '../services/database_service.dart';
import '../services/exercise_enrichment_service.dart';

class ExerciseRepository implements IExerciseRepository {
  final DatabaseService _databaseService;
  final ExerciseEnrichmentService _enrichmentService;

  ExerciseRepository({
    DatabaseService? databaseService,
    ExerciseEnrichmentService? enrichmentService,
  })  : _databaseService = databaseService ?? DatabaseService(),
        _enrichmentService = enrichmentService ?? ExerciseEnrichmentService();

  /// Get all available exercises
  @override
  Future<List<Exercise>> getExercises() async {
    try {
      final remoteExercises = await _databaseService.getExercises();
      if (remoteExercises.isNotEmpty) {
        return _enrichmentService.enrich(remoteExercises);
      }
    } catch (_) {
      // Remote source failed. Return local fallback.
    }
    return _enrichmentService.enrich(initialExercises);
  }

  /// Get exercises by specific type (lfk, stretching, strength)
  @override
  Future<List<Exercise>> getExercisesByType(String type) async {
    final all = await getExercises();
    return all.where((e) => e.type == type).toList();
  }

  /// Get exercise by ID
  @override
  Future<Exercise?> getExerciseById(String id) async {
    final all = await getExercises();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get a list of exercises suitable for a specific difficulty
  @override
  Future<List<Exercise>> getExercisesByDifficulty(String difficulty) async {
    final all = await getExercises();
    return all.where((e) => e.difficulty == difficulty).toList();
  }
}
