import 'package:cloud_firestore/cloud_firestore.dart';

import 'workout_model.dart';

/// Model representing a completed workout session
class WorkoutHistory {
  final String id;
  final String workoutId;
  final String userUid;
  final String title;
  final String type; // lfk, stretching, strength
  final String intensity; // light, moderate, high
  final int durationSeconds;
  final int exercisesCompleted;
  final DateTime completedAt;

  WorkoutHistory({
    required this.id,
    required this.workoutId,
    required this.userUid,
    required this.title,
    required this.type,
    required this.intensity,
    required this.durationSeconds,
    required this.exercisesCompleted,
    required this.completedAt,
  });

  String get typeLabel => WorkoutTypes.labels[type] ?? type;
  String get intensityLabel => WorkoutIntensity.labels[intensity] ?? intensity;

  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutesм $secondsс';
  }

  factory WorkoutHistory.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutHistory(
      id: id,
      workoutId: map['workout_id'] ?? '',
      userUid: map['user_uid'] ?? '',
      title: map['title'] ?? 'Тренировка',
      type: map['type'] ?? 'lfk',
      intensity: map['intensity'] ?? 'moderate',
      durationSeconds: map['duration_seconds']?.toInt() ?? 0,
      exercisesCompleted: map['exercises_completed']?.toInt() ?? 0,
      completedAt:
          ((map['completed_at'] as Timestamp?)?.toDate() ?? DateTime.now())
              .toLocal(),
    );
  }
}
