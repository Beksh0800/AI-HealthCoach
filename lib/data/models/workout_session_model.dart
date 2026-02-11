import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSession {
  final String id;
  final String userId;
  final DateTime date;
  final String feedback; // e.g., difficulty or user comments
  final WorkoutPlan generatedPlan;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.date,
    this.feedback = '',
    required this.generatedPlan,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': Timestamp.fromDate(date),
      'feedback': feedback,
      'generated_plan': generatedPlan.toMap(),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map, String id) {
    return WorkoutSession(
      id: id,
      userId: map['user_id'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      feedback: map['feedback'] ?? '',
      generatedPlan: WorkoutPlan.fromMap(map['generated_plan'] ?? {}),
    );
  }
}

class WorkoutPlan {
  final String workoutFocus;
  final List<WorkoutExercise> exercises;

  WorkoutPlan({
    required this.workoutFocus,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'workout_focus': workoutFocus,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutPlan.fromMap(Map<String, dynamic> map) {
    return WorkoutPlan(
      workoutFocus: map['workout_focus'] ?? '',
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromMap(e))
              .toList() ??
          [],
    );
  }
}

class WorkoutExercise {
  final String name;
  final String reps;
  final String doctorComment;

  WorkoutExercise({
    required this.name,
    required this.reps,
    required this.doctorComment,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'reps': reps,
      'doctor_comment': doctorComment,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      name: map['name'] ?? '',
      reps: map['reps'] ?? '',
      doctorComment: map['doctor_comment'] ?? '',
    );
  }
}
