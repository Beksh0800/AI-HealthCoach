import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_model.dart';

/// Service for persisting workout state between app sessions
class WorkoutPersistenceService {
  static const String _keyWorkoutId = 'active_workout_id';
  static const String _keyExerciseIndex = 'workout_exercise_index';
  static const String _keyCurrentSet = 'workout_current_set';
  static const String _keyElapsedSeconds = 'workout_elapsed_seconds';
  static const String _keyStartTime = 'workout_start_time';
  static const String _keyWorkoutData = 'workout_data_json';

  /// Max age for a saved session before it's considered stale (24 hours)
  static const int _maxSessionAgeMs = 24 * 60 * 60 * 1000;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save the current workout progress including full workout data
  Future<void> saveWorkoutProgress({
    required String workoutId,
    required int exerciseIndex,
    required int currentSet,
    required int elapsedSeconds,
    Workout? workout,
  }) async {
    final prefs = await _preferences;
    await prefs.setString(_keyWorkoutId, workoutId);
    await prefs.setInt(_keyExerciseIndex, exerciseIndex);
    await prefs.setInt(_keyCurrentSet, currentSet);
    await prefs.setInt(_keyElapsedSeconds, elapsedSeconds);
    await prefs.setInt(_keyStartTime, DateTime.now().millisecondsSinceEpoch);

    // Save full workout data for recovery
    if (workout != null) {
      try {
        final workoutMap = _workoutToStorageMap(workout);
        await prefs.setString(_keyWorkoutData, jsonEncode(workoutMap));
      } catch (_) {
        // Non-critical — progress is still saved without workout data
      }
    }
  }

  /// Check if there's an active, non-stale workout session to restore
  Future<bool> hasActiveWorkout() async {
    final prefs = await _preferences;
    final workoutId = prefs.getString(_keyWorkoutId);
    if (workoutId == null) return false;

    // Check if session is stale
    final savedAt = prefs.getInt(_keyStartTime);
    if (savedAt != null) {
      final age = DateTime.now().millisecondsSinceEpoch - savedAt;
      if (age > _maxSessionAgeMs) {
        // Session too old — clear it
        await clearWorkoutProgress();
        return false;
      }
    }

    return true;
  }

  /// Get saved workout progress with full workout data
  Future<Map<String, dynamic>?> getSavedProgress() async {
    final prefs = await _preferences;
    final workoutId = prefs.getString(_keyWorkoutId);

    if (workoutId == null) return null;

    // Check staleness
    final savedAt = prefs.getInt(_keyStartTime);
    if (savedAt != null) {
      final age = DateTime.now().millisecondsSinceEpoch - savedAt;
      if (age > _maxSessionAgeMs) {
        await clearWorkoutProgress();
        return null;
      }
    }

    final result = <String, dynamic>{
      'workoutId': workoutId,
      'exerciseIndex': prefs.getInt(_keyExerciseIndex) ?? 0,
      'currentSet': prefs.getInt(_keyCurrentSet) ?? 1,
      'elapsedSeconds': prefs.getInt(_keyElapsedSeconds) ?? 0,
      'savedAt': savedAt,
    };

    // Try to restore full workout
    final workoutJson = prefs.getString(_keyWorkoutData);
    if (workoutJson != null) {
      try {
        final workoutMap = jsonDecode(workoutJson) as Map<String, dynamic>;
        final workout = _workoutFromStorageMap(workoutMap, workoutId);
        result['workout'] = workout;
      } catch (_) {
        // Can't restore workout data, but progress info is still available
      }
    }

    return result;
  }

  /// Clear workout progress (when completed or cancelled)
  Future<void> clearWorkoutProgress() async {
    final prefs = await _preferences;
    await prefs.remove(_keyWorkoutId);
    await prefs.remove(_keyExerciseIndex);
    await prefs.remove(_keyCurrentSet);
    await prefs.remove(_keyElapsedSeconds);
    await prefs.remove(_keyStartTime);
    await prefs.remove(_keyWorkoutData);
  }

  // === Private helpers for Workout JSON (avoids Firestore Timestamp) ===

  /// Convert Workout to a plain JSON-safe map (no Firestore types)
  Map<String, dynamic> _workoutToStorageMap(Workout workout) {
    return {
      'id': workout.id,
      'user_uid': workout.userUid,
      'title': workout.title,
      'description': workout.description,
      'type': workout.type,
      'intensity': workout.intensity,
      'estimated_duration': workout.estimatedDuration,
      'warmup': workout.warmup.map((e) => e.toMap()).toList(),
      'main_exercises': workout.mainExercises.map((e) => e.toMap()).toList(),
      'cooldown': workout.cooldown.map((e) => e.toMap()).toList(),
      'created_at_ms': workout.createdAt.millisecondsSinceEpoch,
      'check_in_id': workout.checkInId,
      'ai_metadata': workout.aiMetadata,
    };
  }

  /// Restore Workout from a plain JSON map
  Workout _workoutFromStorageMap(Map<String, dynamic> map, String workoutId) {
    return Workout(
      id: map['id'] as String? ?? workoutId,
      userUid: map['user_uid'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'lfk',
      intensity: map['intensity'] as String? ?? 'moderate',
      estimatedDuration: (map['estimated_duration'] as num?)?.toInt() ?? 30,
      warmup: (map['warmup'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      mainExercises: (map['main_exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      cooldown: (map['cooldown'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: map['created_at_ms'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at_ms'] as int)
          : DateTime.now(),
      checkInId: map['check_in_id'] as String?,
      aiMetadata: map['ai_metadata'] as Map<String, dynamic>?,
    );
  }
}
