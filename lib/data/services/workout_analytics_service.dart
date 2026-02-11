import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/workout_history_model.dart';

/// Service for analyzing workout patterns and generating smart recommendations
class WorkoutAnalyticsService {
  final FirebaseFirestore _firestore;

  WorkoutAnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get workout statistics for a user
  Future<WorkoutStats> getWorkoutStats(String userId) async {
    final historySnapshot = await _firestore
        .collection('workout_history')
        .where('user_uid', isEqualTo: userId)
        .orderBy('completed_at', descending: true)
        .get();

    final workouts = historySnapshot.docs
        .map((doc) => WorkoutHistory.fromMap(doc.data(), doc.id))
        .toList();

    if (workouts.isEmpty) {
      return WorkoutStats.empty();
    }

    // Calculate statistics
    final totalWorkouts = workouts.length;
    final totalMinutes = workouts.fold<int>(
      0,
      (acc, w) => acc + (w.durationSeconds ~/ 60),
    );
    final totalExercises = workouts.fold<int>(
      0,
      (acc, w) => acc + w.exercisesCompleted,
    );

    // Weekly breakdown
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeek = workouts.where(
      (w) => w.completedAt.isAfter(weekAgo),
    );

    // Most common workout type
    final typeCounts = <String, int>{};
    for (final w in workouts) {
      typeCounts[w.type] = (typeCounts[w.type] ?? 0) + 1;
    }
    final favoriteType = typeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Average duration
    final avgDuration = totalMinutes ~/ totalWorkouts;

    // Streak calculation
    final streak = _calculateStreak(workouts);

    return WorkoutStats(
      totalWorkouts: totalWorkouts,
      totalMinutes: totalMinutes,
      totalExercises: totalExercises,
      workoutsThisWeek: thisWeek.length,
      minutesThisWeek: thisWeek.fold(0, (acc, w) => acc + (w.durationSeconds ~/ 60)),
      averageDurationMinutes: avgDuration,
      favoriteWorkoutType: favoriteType,
      currentStreak: streak,
      lastWorkoutDate: workouts.first.completedAt,
    );
  }

  /// Calculate current workout streak (consecutive days)
  int _calculateStreak(List<WorkoutHistory> workouts) {
    if (workouts.isEmpty) return 0;

    int streak = 0;
    DateTime lastDate = DateTime.now();

    // Sort by date descending
    final sorted = List<WorkoutHistory>.from(workouts)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    for (final workout in sorted) {
      final workoutDate = DateTime(
        workout.completedAt.year,
        workout.completedAt.month,
        workout.completedAt.day,
      );
      final checkDate = DateTime(lastDate.year, lastDate.month, lastDate.day);

      final diff = checkDate.difference(workoutDate).inDays;

      if (diff == 0 || diff == 1) {
        streak++;
        lastDate = workoutDate;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get pain report patterns to identify problematic exercises
  Future<Map<String, int>> getPainPatterns(String userId) async {
    final painReports = await _firestore
        .collection('pain_reports')
        .where('user_uid', isEqualTo: userId)
        .get();

    final patterns = <String, int>{};
    for (final doc in painReports.docs) {
      final data = doc.data();
      final exerciseName = data['exercise_name'] as String?;
      if (exerciseName != null) {
        patterns[exerciseName] = (patterns[exerciseName] ?? 0) + 1;
      }
    }

    return patterns;
  }

  /// Get recommended intensity based on recent performance
  Future<String> getRecommendedIntensity(String userId) async {
    final stats = await getWorkoutStats(userId);

    // New user - start light
    if (stats.totalWorkouts < 5) {
      return 'light';
    }

    // Check weekly volume
    if (stats.workoutsThisWeek >= 5) {
      return 'light'; // Rest recommended
    }

    if (stats.workoutsThisWeek >= 3) {
      return 'moderate';
    }

    // Check streak - reward consistency
    if (stats.currentStreak >= 7) {
      return 'high';
    }

    return 'moderate';
  }

  /// Get personalized workout suggestions
  Future<List<String>> getWorkoutSuggestions(String userId) async {
    final stats = await getWorkoutStats(userId);
    final suggestions = <String>[];

    // Based on streak
    if (stats.currentStreak == 0) {
      suggestions.add('🎯 Начните новую серию тренировок сегодня!');
    } else if (stats.currentStreak >= 3) {
      suggestions.add('🔥 Отличная серия — ${stats.currentStreak} дней подряд!');
    }

    // Based on weekly volume
    if (stats.workoutsThisWeek == 0) {
      suggestions.add('💪 Самое время для первой тренировки на этой неделе');
    } else if (stats.workoutsThisWeek >= 5) {
      suggestions.add('🧘 Отдых важен! Попробуйте растяжку');
    }

    // Based on favorite type - suggest variety
    if (stats.favoriteWorkoutType == 'strength' && stats.totalWorkouts > 3) {
      suggestions.add('🌿 Добавьте растяжку для восстановления');
    } else if (stats.favoriteWorkoutType == 'stretching') {
      suggestions.add('💪 Попробуйте силовую нагрузку для баланса');
    }

    return suggestions;
  }

  /// Get recent pain reports (last 30 days) to identify active issues
  Future<List<String>> getRecentPainReports(String userId) async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    final snapshot = await _firestore
        .collection('pain_reports')
        .where('user_uid', isEqualTo: userId)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(monthAgo))
        .get();

    final painLocations = <String>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['pain_location'] != null) {
        painLocations.add(data['pain_location'] as String);
      }
    }
    
    // Return unique locations
    return painLocations.toSet().toList();
  }
}

/// Workout statistics model
class WorkoutStats {
  final int totalWorkouts;
  final int totalMinutes;
  final int totalExercises;
  final int workoutsThisWeek;
  final int minutesThisWeek;
  final int averageDurationMinutes;
  final String favoriteWorkoutType;
  final int currentStreak;
  final DateTime? lastWorkoutDate;

  WorkoutStats({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalExercises,
    required this.workoutsThisWeek,
    required this.minutesThisWeek,
    required this.averageDurationMinutes,
    required this.favoriteWorkoutType,
    required this.currentStreak,
    this.lastWorkoutDate,
  });

  factory WorkoutStats.empty() => WorkoutStats(
        totalWorkouts: 0,
        totalMinutes: 0,
        totalExercises: 0,
        workoutsThisWeek: 0,
        minutesThisWeek: 0,
        averageDurationMinutes: 0,
        favoriteWorkoutType: 'lfk',
        currentStreak: 0,
      );

  bool get hasWorkouts => totalWorkouts > 0;
}
