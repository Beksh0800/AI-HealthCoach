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

  @override
  List<Object?> get props => [
    workout,
    exerciseIndex,
    currentSet,
    elapsedSeconds,
    savedAt,
  ];
}

enum WorkoutGenerationStep {
  analyzingProfile,
  selectingSafeExercises,
  adaptingIntensity,
  creatingProgram,
  validatingSafety,
}

/// Generating workout with AI
class WorkoutGenerating extends WorkoutState {
  final String workoutType;
  final WorkoutGenerationStep step;

  const WorkoutGenerating({
    required this.workoutType,
    this.step = WorkoutGenerationStep.analyzingProfile,
  });

  @override
  List<Object?> get props => [workoutType, step];
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
  final int restStartedAtEpochMs;
  final int restDurationSeconds;
  final int elapsedSeconds;
  final bool isPaused;

  const WorkoutInProgress({
    required this.workout,
    this.currentExerciseIndex = 0,
    this.currentSet = 1,
    this.isResting = false,
    this.restStartedAtEpochMs = 0,
    this.restDurationSeconds = 0,
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
    restStartedAtEpochMs,
    restDurationSeconds,
    isPaused,
  ];

  WorkoutInProgress copyWith({
    Workout? workout,
    int? currentExerciseIndex,
    int? currentSet,
    bool? isResting,
    int? restStartedAtEpochMs,
    int? restDurationSeconds,
    int? elapsedSeconds,
    bool? isPaused,
  }) {
    return WorkoutInProgress(
      workout: workout ?? this.workout,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSet: currentSet ?? this.currentSet,
      isResting: isResting ?? this.isResting,
      restStartedAtEpochMs: restStartedAtEpochMs ?? this.restStartedAtEpochMs,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
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
  final int restStartedAtEpochMs;
  final int restDurationSeconds;
  final String painLocation;
  final int painIntensity;

  const WorkoutPainRest({
    required this.workout,
    required this.currentExerciseIndex,
    required this.elapsedSeconds,
    required this.restStartedAtEpochMs,
    required this.restDurationSeconds,
    required this.painLocation,
    required this.painIntensity,
  });

  WorkoutExercise get currentExercise =>
      workout.allExercises[currentExerciseIndex];

  @override
  List<Object?> get props => [
    workout,
    currentExerciseIndex,
    elapsedSeconds,
    restStartedAtEpochMs,
    restDurationSeconds,
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

  const WorkoutExerciseReplacing({
    required this.workout,
    required this.currentExerciseIndex,
    required this.elapsedSeconds,
    required this.painLocation,
  });

  @override
  List<Object?> get props => [
    workout,
    currentExerciseIndex,
    elapsedSeconds,
    painLocation,
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
  final String errorCode;
  final String? debugMessage;
  final bool retryable;
  final String? workoutType;

  const WorkoutError({
    required this.errorCode,
    this.debugMessage,
    this.retryable = true,
    this.workoutType,
  });

  @override
  List<Object?> get props => [errorCode, debugMessage, retryable, workoutType];
}
