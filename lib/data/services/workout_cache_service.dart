import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_model.dart';

/// Service for caching generated workouts for offline access.
///
/// Stores up to [_maxCached] most-recent workouts in SharedPreferences
/// as JSON. Oldest entries are evicted when the limit is reached.
class WorkoutCacheService {
  static const String _cacheKey = 'cached_workouts';
  static const int _maxCached = 5;

  /// Cache a workout. Adds to front, evicts oldest if over limit.
  Future<void> cacheWorkout(Workout workout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = _loadRawList(prefs);

      final json = _workoutToJson(workout);
      existing.insert(0, json);

      // Keep only the newest entries
      if (existing.length > _maxCached) {
        existing.removeRange(_maxCached, existing.length);
      }

      await prefs.setString(_cacheKey, jsonEncode(existing));
      debugPrint('WorkoutCacheService: cached workout "${workout.title}"');
    } catch (e) {
      debugPrint('WorkoutCacheService: error caching workout: $e');
    }
  }

  /// Get all cached workouts (most recent first).
  Future<List<Workout>> getCachedWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = _loadRawList(prefs);

      return rawList.map((item) {
        final map = item as Map<String, dynamic>;
        return _workoutFromJson(map);
      }).toList();
    } catch (e) {
      debugPrint('WorkoutCacheService: error loading cache: $e');
      return [];
    }
  }

  /// Check if there are any cached workouts.
  Future<bool> hasCachedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadRawList(prefs).isNotEmpty;
  }

  /// Clear all cached workouts.
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  // ────────────── Private helpers ──────────────

  List<dynamic> _loadRawList(SharedPreferences prefs) {
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  /// Convert a Workout to a plain JSON-safe map (no Firestore types).
  Map<String, dynamic> _workoutToJson(Workout workout) {
    return {
      'id': workout.id,
      'user_uid': workout.userUid,
      'title': workout.title,
      'description': workout.description,
      'type': workout.type,
      'intensity': workout.intensity,
      'estimated_duration': workout.estimatedDuration,
      'warmup': workout.warmup.map(_exerciseToJson).toList(),
      'main_exercises': workout.mainExercises.map(_exerciseToJson).toList(),
      'cooldown': workout.cooldown.map(_exerciseToJson).toList(),
      'created_at': workout.createdAt.toIso8601String(),
      'check_in_id': workout.checkInId,
      'ai_metadata': workout.aiMetadata,
    };
  }

  Map<String, dynamic> _exerciseToJson(WorkoutExercise ex) {
    return {
      'name': ex.name,
      'description': ex.description,
      'sets': ex.sets,
      'reps': ex.reps,
      'duration_seconds': ex.durationSeconds,
      'rest_seconds': ex.restSeconds,
      'image_url': ex.imageUrl,
      'instructions': ex.instructions,
      'difficulty': ex.difficulty,
      'target_muscles': ex.targetMuscles,
      'contraindications': ex.contraindications,
    };
  }

  Workout _workoutFromJson(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] ?? '',
      userUid: map['user_uid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'lfk',
      intensity: map['intensity'] ?? 'moderate',
      estimatedDuration: map['estimated_duration']?.toInt() ?? 30,
      warmup: _parseExerciseList(map['warmup']),
      mainExercises: _parseExerciseList(map['main_exercises']),
      cooldown: _parseExerciseList(map['cooldown']),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
          : DateTime.now(),
      checkInId: map['check_in_id'],
      aiMetadata: map['ai_metadata'] != null
          ? Map<String, dynamic>.from(map['ai_metadata'])
          : null,
    );
  }

  List<WorkoutExercise> _parseExerciseList(dynamic list) {
    if (list == null) return [];
    return (list as List<dynamic>)
        .map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
