import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a single exercise in a workout
/// Model for a single exercise in a workout
class WorkoutExercise {
  final String name;
  final String description;
  final int sets;
  final int reps;
  final int durationSeconds; // For timed exercises
  final int restSeconds;
  final String? imageUrl;
  final List<String> instructions;
  final String difficulty; // easy, medium, hard
  final List<String> targetMuscles;
  final List<String> contraindications;

  WorkoutExercise({
    required this.name,
    required this.description,
    this.sets = 1,
    this.reps = 0,
    this.durationSeconds = 0,
    this.restSeconds = 30,
    this.imageUrl,
    this.instructions = const [],
    this.difficulty = 'medium',
    this.targetMuscles = const [],
    this.contraindications = const [],
  });

  /// Check if exercise is time-based or rep-based
  bool get isTimeBased => durationSeconds > 0;

  /// Get display string for sets/reps
  String get displayFormat {
    if (isTimeBased) {
      return '$sets x $durationSecondsс';
    }
    return '$sets x $reps';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'sets': sets,
      'reps': reps,
      'duration_seconds': durationSeconds,
      'rest_seconds': restSeconds,
      'image_url': imageUrl,
      'instructions': instructions,
      'difficulty': difficulty,
      'target_muscles': targetMuscles,
      'contraindications': contraindications,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      sets: map['sets']?.toInt() ?? 1,
      reps: map['reps']?.toInt() ?? 0,
      durationSeconds: map['duration_seconds']?.toInt() ?? 0,
      restSeconds: map['rest_seconds']?.toInt() ?? 30,
      imageUrl: map['image_url'],
      instructions: List<String>.from(map['instructions'] ?? []),
      difficulty: map['difficulty'] ?? 'medium',
      targetMuscles: List<String>.from(map['target_muscles'] ?? []),
      contraindications: List<String>.from(map['contraindications'] ?? []),
    );
  }
}

/// Model for a complete workout session
class Workout {
  final String id;
  final String userUid;
  final String title;
  final String description;
  final String type; // lfk, stretching, strength
  final String intensity; // light, moderate, high
  final int estimatedDuration; // in minutes
  final List<WorkoutExercise> warmup;
  final List<WorkoutExercise> mainExercises;
  final List<WorkoutExercise> cooldown;
  final DateTime createdAt;
  final String? checkInId; // Link to daily check-in
  final Map<String, dynamic>? aiMetadata; // Store AI generation info

  Workout({
    required this.id,
    required this.userUid,
    required this.title,
    required this.description,
    required this.type,
    required this.intensity,
    required this.estimatedDuration,
    required this.warmup,
    required this.mainExercises,
    required this.cooldown,
    DateTime? createdAt,
    this.checkInId,
    this.aiMetadata,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get total number of exercises
  int get totalExercises =>
      warmup.length + mainExercises.length + cooldown.length;

  /// Get all exercises in order
  List<WorkoutExercise> get allExercises => [...warmup, ...mainExercises, ...cooldown];

  Map<String, dynamic> toMap() {
    return {
      'user_uid': userUid,
      'title': title,
      'description': description,
      'type': type,
      'intensity': intensity,
      'estimated_duration': estimatedDuration,
      'warmup': warmup.map((e) => e.toMap()).toList(),
      'main_exercises': mainExercises.map((e) => e.toMap()).toList(),
      'cooldown': cooldown.map((e) => e.toMap()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
      'check_in_id': checkInId,
      'ai_metadata': aiMetadata,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map, String id) {
    return Workout(
      id: id,
      userUid: map['user_uid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'lfk',
      intensity: map['intensity'] ?? 'moderate',
      estimatedDuration: map['estimated_duration']?.toInt() ?? 30,
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
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      checkInId: map['check_in_id'],
      aiMetadata: map['ai_metadata'],
    );
  }

  Workout copyWith({
    String? id,
    String? userUid,
    String? title,
    String? description,
    String? type,
    String? intensity,
    int? estimatedDuration,
    List<WorkoutExercise>? warmup,
    List<WorkoutExercise>? mainExercises,
    List<WorkoutExercise>? cooldown,
    String? checkInId,
    Map<String, dynamic>? aiMetadata,
  }) {
    return Workout(
      id: id ?? this.id,
      userUid: userUid ?? this.userUid,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      warmup: warmup ?? this.warmup,
      mainExercises: mainExercises ?? this.mainExercises,
      cooldown: cooldown ?? this.cooldown,
      createdAt: createdAt,
      checkInId: checkInId ?? this.checkInId,
      aiMetadata: aiMetadata ?? this.aiMetadata,
    );
  }
}

/// Workout type constants
class WorkoutTypes {
  WorkoutTypes._();

  static const String lfk = 'lfk';
  static const String stretching = 'stretching';
  static const String strength = 'strength';
  static const String cardio = 'cardio';

  static const Map<String, String> labels = {
    lfk: 'ЛФК',
    stretching: 'Растяжка',
    strength: 'Силовая',
    cardio: 'Кардио',
  };

  static const Map<String, String> descriptions = {
    lfk: 'Лечебная физкультура для восстановления',
    stretching: 'Упражнения на гибкость и растяжку',
    strength: 'Силовые упражнения для укрепления мышц',
    cardio: 'Кардио для выносливости',
  };
}

/// Workout intensity constants
class WorkoutIntensity {
  WorkoutIntensity._();

  static const String rest = 'rest';
  static const String light = 'light';
  static const String moderate = 'moderate';
  static const String high = 'high';

  static const Map<String, String> labels = {
    rest: 'Отдых',
    light: 'Легкая',
    moderate: 'Умеренная',
    high: 'Высокая',
  };
}
