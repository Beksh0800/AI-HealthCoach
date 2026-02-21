part of 'workout_cubit.dart';

sealed class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WorkoutInitial extends WorkoutState {
  const WorkoutInitial();
}

/// A saved workout session was found — prompt user to resume or discard
class WorkoutSessionRecovery extends WorkoutState {
  final Workout workout;
  final int exerciseIndex;
  final int currentSet;
  final int elapsedSeconds;
  final DateTime savedAt;

  const WorkoutSessionRecovery({
    required this.workout,
    required this.exerciseIndex,
    required this.currentSet,
    required this.elapsedSeconds,
    required this.savedAt,
  });

  /// How long ago the session was saved
  String get timeAgoText {
    final diff = DateTime.now().difference(savedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours < 24) return '${diff.inHours} ч назад';
    return '${diff.inDays} дн назад';
  }

  @override
  List<Object?> get props => [
    workout,
    exerciseIndex,
    currentSet,
    elapsedSeconds,
    savedAt,
  ];
}

/// Generating workout with AI
class WorkoutGenerating extends WorkoutState {
  final String workoutType;
  final String message;

  const WorkoutGenerating({
    required this.workoutType,
    this.message = 'Генерируем тренировку...',
  });

  @override
  List<Object?> get props => [workoutType, message];
}

/// Workout generated and ready
class WorkoutReady extends WorkoutState {
  final Workout workout;

  const WorkoutReady(this.workout);

  @override
  List<Object?> get props => [workout];
}

/// Workout in progress (user is doing exercises)
class WorkoutInProgress extends WorkoutState {
  final Workout workout;
  final int currentExerciseIndex;
  final int currentSet;
  final bool isResting;
  final int? restRemainingSeconds;
  final int elapsedSeconds;
  final bool isPaused;

  const WorkoutInProgress({
    required this.workout,
    this.currentExerciseIndex = 0,
    this.currentSet = 1,
    this.isResting = false,
    this.restRemainingSeconds,
    this.elapsedSeconds = 0,
    this.isPaused = false,
  });

  WorkoutExercise get currentExercise =>
      workout.allExercises[currentExerciseIndex];
  int get totalExercises => workout.allExercises.length;
  double get progress => (currentExerciseIndex + 1) / totalExercises;
  bool get isLastExercise => currentExerciseIndex >= totalExercises - 1;
  bool get isLastSet => currentSet >= currentExercise.sets;

  @override
  List<Object?> get props => [
    workout,
    currentExerciseIndex,
    currentSet,
    isResting,
    restRemainingSeconds,
    elapsedSeconds,
    isPaused,
  ];

  WorkoutInProgress copyWith({
    Workout? workout,
    int? currentExerciseIndex,
    int? currentSet,
    bool? isResting,
    int? restRemainingSeconds,
    int? elapsedSeconds,
    bool? isPaused,
  }) {
    return WorkoutInProgress(
      workout: workout ?? this.workout,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSet: currentSet ?? this.currentSet,
      isResting: isResting ?? this.isResting,
      restRemainingSeconds: restRemainingSeconds ?? this.restRemainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

/// Pain assessment flow step
enum PainFlowStep { location, intensity, action }

/// Pain reported during workout - multi-step flow
class WorkoutPainReported extends WorkoutState {
  final Workout workout;
  final int currentExerciseIndex;
  final int elapsedSeconds;
  final PainFlowStep step;
  final String? painLocation;
  final int? painIntensity; // 1-10

  const WorkoutPainReported({
    required this.workout,
    required this.currentExerciseIndex,
    required this.elapsedSeconds,
    this.step = PainFlowStep.location,
    this.painLocation,
    this.painIntensity,
  });

  WorkoutExercise get currentExercise =>
      workout.allExercises[currentExerciseIndex];

  /// Get pain level category
  String get painCategory {
    if (painIntensity == null) return '';
    if (painIntensity! <= 3) return 'light';
    if (painIntensity! <= 6) return 'moderate';
    return 'severe';
  }

  WorkoutPainReported copyWith({
    PainFlowStep? step,
    String? painLocation,
    int? painIntensity,
  }) {
    return WorkoutPainReported(
      workout: workout,
      currentExerciseIndex: currentExerciseIndex,
      elapsedSeconds: elapsedSeconds,
      step: step ?? this.step,
      painLocation: painLocation ?? this.painLocation,
      painIntensity: painIntensity ?? this.painIntensity,
    );
  }

  @override
  List<Object?> get props => [
    workout,
    currentExerciseIndex,
    elapsedSeconds,
    step,
    painLocation,
    painIntensity,
  ];
}

/// Resting due to pain
class WorkoutPainRest extends WorkoutState {
  final Workout workout;
  final int currentExerciseIndex;
  final int elapsedSeconds;
  final int restDurationSeconds;
  final int remainingSeconds;
  final String painLocation;
  final int painIntensity;

  const WorkoutPainRest({
    required this.workout,
    required this.currentExerciseIndex,
    required this.elapsedSeconds,
    required this.restDurationSeconds,
    required this.remainingSeconds,
    required this.painLocation,
    required this.painIntensity,
  });

  WorkoutExercise get currentExercise =>
      workout.allExercises[currentExerciseIndex];

  WorkoutPainRest copyWith({int? remainingSeconds}) {
    return WorkoutPainRest(
      workout: workout,
      currentExerciseIndex: currentExerciseIndex,
      elapsedSeconds: elapsedSeconds,
      restDurationSeconds: restDurationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      painLocation: painLocation,
      painIntensity: painIntensity,
    );
  }

  @override
  List<Object?> get props => [
    workout,
    currentExerciseIndex,
    elapsedSeconds,
    restDurationSeconds,
    remainingSeconds,
    painLocation,
    painIntensity,
  ];
}

/// Replacing exercise with safer alternative
class WorkoutExerciseReplacing extends WorkoutState {
  final Workout workout;
  final int currentExerciseIndex;
  final int elapsedSeconds;
  final String painLocation;
  final String message;

  const WorkoutExerciseReplacing({
    required this.workout,
    required this.currentExerciseIndex,
    required this.elapsedSeconds,
    required this.painLocation,
    this.message = 'Подбираем безопасную альтернативу...',
  });

  @override
  List<Object?> get props => [
    workout,
    currentExerciseIndex,
    elapsedSeconds,
    painLocation,
    message,
  ];
}

/// Workout completed
class WorkoutCompleted extends WorkoutState {
  final Workout workout;
  final int totalDurationSeconds;
  final int painReportsCount;
  final PostWorkoutFeedback? feedback;

  const WorkoutCompleted({
    required this.workout,
    required this.totalDurationSeconds,
    this.painReportsCount = 0,
    this.feedback,
  });

  @override
  List<Object?> get props => [
    workout,
    totalDurationSeconds,
    painReportsCount,
    feedback,
  ];
}

/// Error state
class WorkoutError extends WorkoutState {
  final String message;
  final bool retryable;
  final String? workoutType;

  const WorkoutError(this.message, {this.retryable = true, this.workoutType});

  @override
  List<Object?> get props => [message, retryable, workoutType];
}
