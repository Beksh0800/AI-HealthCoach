import 'dart:async';

import '../../domain/repositories/i_exercise_repository.dart';
import '../models/exercise_model.dart';
import '../datasources/initial_exercises.dart';
import '../services/database_service.dart';
import '../services/exercise_enrichment_service.dart';

class ExerciseRepository implements IExerciseRepository {
  final DatabaseService _databaseService;
  final ExerciseEnrichmentService _enrichmentService;
  List<Exercise>? _cachedExercises;
  DateTime? _cachedAt;

  static const Duration _cacheTtl = Duration(minutes: 10);
  static const Duration _remoteLoadTimeout = Duration(seconds: 5);
  static const Duration _enrichTimeout = Duration(seconds: 3);

  ExerciseRepository({
    DatabaseService? databaseService,
    ExerciseEnrichmentService? enrichmentService,
  }) : _databaseService = databaseService ?? DatabaseService(),
       _enrichmentService = enrichmentService ?? ExerciseEnrichmentService();

  /// Get all available exercises
  @override
  Future<List<Exercise>> getExercises() async {
    if (_cachedExercises != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheTtl) {
      return _cachedExercises!;
    }

    try {
      final remoteExercises = await _databaseService.getExercises().timeout(
        _remoteLoadTimeout,
      );
      if (remoteExercises.isNotEmpty) {
        final enriched = await _tryEnrich(remoteExercises);
        _cachedExercises = enriched;
        _cachedAt = DateTime.now();
        return enriched;
      }
    } catch (_) {
      // Remote source failed. Return local fallback.
    }

    final enrichedLocal = await _tryEnrich(initialExercises);
    _cachedExercises = enrichedLocal;
    _cachedAt = DateTime.now();
    return enrichedLocal;
  }

  Future<List<Exercise>> _tryEnrich(List<Exercise> source) async {
    try {
      return await _enrichmentService.enrich(source).timeout(_enrichTimeout);
    } catch (_) {
      return source;
    }
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
