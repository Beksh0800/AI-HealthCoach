import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/user_profile_model.dart';
import '../../../data/models/daily_checkin_model.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/workout_model.dart';
import '../../../domain/services/i_ai_service.dart';
import '../../../data/models/ai_feedback_models.dart';
import '../../../data/services/workout_persistence_service.dart';
import '../../../data/services/workout_analytics_service.dart';
import '../../../data/services/workout_cache_service.dart';
import '../../../domain/repositories/i_exercise_repository.dart';
import '../../../core/errors/error_mapper.dart';

part 'workout_state.dart';

/// Cubit for managing workout generation and execution
class WorkoutCubit extends Cubit<WorkoutState> {
  final IAiService _geminiService;
  final IExerciseRepository _exerciseRepository;
  final FirebaseFirestore _firestore;
  final WorkoutPersistenceService _persistenceService;
  final WorkoutAnalyticsService _analyticsService;
  final WorkoutCacheService _cacheService;
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _painReportsCount = 0;
  UserProfile? _currentProfile;

  /// Counter for saving progress periodically (every 10 seconds)
  int _saveCounter = 0;

  WorkoutCubit({
    required IAiService geminiService,
    required IExerciseRepository exerciseRepository,
    required WorkoutPersistenceService persistenceService,
    required WorkoutAnalyticsService analyticsService,
    required WorkoutCacheService cacheService,
    FirebaseFirestore? firestore,
  }) : _geminiService = geminiService,
       _exerciseRepository = exerciseRepository,
       _persistenceService = persistenceService,
       _analyticsService = analyticsService,
       _cacheService = cacheService,
       _firestore = firestore ?? FirebaseFirestore.instance,
       super(const WorkoutInitial());

  /// Check for an active saved workout session and prompt recovery
  Future<void> checkForActiveSession() async {
    try {
      final hasActive = await _persistenceService.hasActiveWorkout();
      if (!hasActive) return;

      final progress = await _persistenceService.getSavedProgress();
      if (progress == null) return;

      final workout = progress['workout'] as Workout?;
      if (workout == null) {
        // Can't restore without workout data
        await _persistenceService.clearWorkoutProgress();
        return;
      }

      final savedAtMs = progress['savedAt'] as int?;
      final savedAt = savedAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(savedAtMs)
          : DateTime.now();

      emit(
        WorkoutSessionRecovery(
          workout: workout,
          exerciseIndex: progress['exerciseIndex'] as int? ?? 0,
          currentSet: progress['currentSet'] as int? ?? 1,
          elapsedSeconds: progress['elapsedSeconds'] as int? ?? 0,
          savedAt: savedAt,
        ),
      );
    } catch (e) {
      debugPrint('Error checking active session: $e');
      // Clear corrupted data
      await _persistenceService.clearWorkoutProgress();
    }
  }

  /// Restore a saved workout session and continue from where user left off
  void restoreSession() {
    final current = state;
    if (current is! WorkoutSessionRecovery) return;

    _elapsedSeconds = current.elapsedSeconds;
    emit(
      WorkoutInProgress(
        workout: current.workout,
        currentExerciseIndex: current.exerciseIndex,
        currentSet: current.currentSet,
        elapsedSeconds: current.elapsedSeconds,
      ),
    );
    _startTimer();
  }

  /// Discard a saved session and return to initial state
  void discardSession() {
    _persistenceService.clearWorkoutProgress();
    emit(const WorkoutInitial());
  }

  /// Get cached workouts for offline access.
  Future<List<Workout>> getCachedWorkouts() =>
      _cacheService.getCachedWorkouts();

  /// Load a cached workout directly into WorkoutReady state.
  void loadCachedWorkout(Workout workout) {
    _painReportsCount = 0;
    emit(WorkoutReady(workout));
  }

  /// Generate a new workout
  Future<void> generateWorkout({
    required UserProfile profile,
    required DailyCheckIn checkIn,
    required String workoutType,
  }) async {
    _currentProfile = profile;
    _painReportsCount = 0;

    emit(
      WorkoutGenerating(
        workoutType: workoutType,
        message: 'Анализируем профиль и состояние...',
      ),
    );

    try {
      emit(
        WorkoutGenerating(
          workoutType: workoutType,
          message: 'Подбираем безопасные упражнения из базы...',
        ),
      );

      // Fetch available exercises for this workout type
      final exercises = await _exerciseRepository.getExercisesByType(
        workoutType,
      );

      // --- Adaptive Intensity Logic ---
      String? targetIntensity;
      List<String> excludedExercises = [];
      String? reason;

      try {
        final statsFuture = _analyticsService.getWorkoutStats(profile.uid);
        final recentPainFuture = _analyticsService.getRecentPainReports(
          profile.uid,
        );
        final stats = await statsFuture;
        final recentPain = await recentPainFuture;

        final adaptation = await _geminiService.getPainAdaptedIntensity(
          todayCheckIn: checkIn,
          recentPainReports: recentPain,
          recentWorkoutCount: stats.workoutsThisWeek,
        );

        targetIntensity = adaptation.adjustedIntensity;
        excludedExercises = adaptation.avoidExerciseTypes;
        reason = adaptation.reason;

        if (reason.isNotEmpty) {
          emit(
            WorkoutGenerating(
              workoutType: workoutType,
              message: 'Адаптируем нагрузку: $reason',
            ),
          );
        }
      } catch (e) {
        debugPrint('Error getting adaptive intensity: $e');
        // Continue with standard generation
      }
      // -------------------------------

      emit(
        WorkoutGenerating(
          workoutType: workoutType,
          message: 'AI создаёт персональную программу...',
        ),
      );

      // Filter out specifically excluded exercises if any
      final filteredExercises = exercises.where((e) {
        return !excludedExercises.any(
          (excluded) =>
              e.title.toLowerCase().contains(excluded.toLowerCase()) ||
              e.id.toLowerCase().contains(excluded.toLowerCase()),
        );
      }).toList();

      final generatedWorkout = await _geminiService.generateWorkout(
        profile: profile,
        checkIn: checkIn,
        workoutType: workoutType,
        availableExercises: filteredExercises,
        targetIntensity: targetIntensity,
      );

      final workout = _applyMediaToWorkout(
        generatedWorkout,
        filteredExercises,
        profile.medicalProfile.gender,
      );

      debugPrint(
        'WorkoutCubit: Workout received from GeminiService: ${workout.title}',
      );
      debugPrint(
        'WorkoutCubit: Exercises count - warmup: ${workout.warmup.length}, main: ${workout.mainExercises.length}, cooldown: ${workout.cooldown.length}',
      );

      emit(
        WorkoutGenerating(
          workoutType: workoutType,
          message: 'Проверяем безопасность упражнений...',
        ),
      );

      final localWorkout = workout.copyWith(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      );
      emit(WorkoutReady(localWorkout));

      // Persist in background to avoid blocking UI transition.
      unawaited(_cacheService.cacheWorkout(localWorkout));
      unawaited(_saveGeneratedWorkoutToFirestore(localWorkout));
    } catch (e) {
      debugPrint('WorkoutCubit: Error in generateWorkout: $e');
      final mapped = ErrorMapper.toAppException(
        e,
        fallbackMessage: 'Не удалось сгенерировать тренировку',
      );
      emit(
        WorkoutError(
          mapped.message,
          retryable: ErrorMapper.isRetryable(e),
          workoutType: workoutType,
        ),
      );
    }
  }

  Future<void> _saveGeneratedWorkoutToFirestore(Workout localWorkout) async {
    debugPrint('WorkoutCubit: Saving workout to Firestore in background...');
    try {
      final docRef = await _firestore
          .collection('workouts')
          .add(localWorkout.toMap());
      debugPrint('WorkoutCubit: Workout saved with ID: ${docRef.id}');

      if (isClosed) return;
      final current = state;
      if (current is WorkoutReady && current.workout.id == localWorkout.id) {
        emit(WorkoutReady(localWorkout.copyWith(id: docRef.id)));
      }
    } catch (firebaseError) {
      debugPrint('WorkoutCubit: Firebase save failed: $firebaseError');
    }
  }

  Workout _applyMediaToWorkout(
    Workout workout,
    List<Exercise> libraryExercises,
    String gender,
  ) {
    final warmup = workout.warmup
        .map(
          (exercise) =>
              _enrichExerciseMedia(exercise, libraryExercises, gender),
        )
        .toList();
    final main = workout.mainExercises
        .map(
          (exercise) =>
              _enrichExerciseMedia(exercise, libraryExercises, gender),
        )
        .toList();
    final cooldown = workout.cooldown
        .map(
          (exercise) =>
              _enrichExerciseMedia(exercise, libraryExercises, gender),
        )
        .toList();

    return workout.copyWith(
      warmup: warmup,
      mainExercises: main,
      cooldown: cooldown,
    );
  }

  WorkoutExercise _enrichExerciseMedia(
    WorkoutExercise workoutExercise,
    List<Exercise> libraryExercises,
    String gender,
  ) {
    final normalizedWorkoutName = _normalizeName(workoutExercise.name);
    final match = libraryExercises.where((exercise) {
      final normalizedTitle = _normalizeName(exercise.title);
      return normalizedTitle == normalizedWorkoutName ||
          normalizedWorkoutName.contains(normalizedTitle) ||
          normalizedTitle.contains(normalizedWorkoutName);
    }).toList();

    if (match.isEmpty) {
      return workoutExercise;
    }

    final found = match.first;
    final resolvedMediaUrl = found.resolveMediaUrl(gender: gender);
    final fallbackVideoUrl =
        resolvedMediaUrl != null &&
            !Exercise.isSupportedImageUrl(resolvedMediaUrl)
        ? resolvedMediaUrl
        : null;

    return workoutExercise.copyWith(
      exerciseId: found.id,
      imageUrl:
          found.resolveImageUrl(gender: gender) ??
          Exercise.sanitizeImageUrl(workoutExercise.imageUrl),
      videoUrl: found.videoUrl ?? fallbackVideoUrl ?? workoutExercise.videoUrl,
      mediaType: found.mediaType,
      source: found.source,
      license: found.license,
    );
  }

  String _normalizeName(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zа-я0-9]+', caseSensitive: false), ' ')
        .trim();
  }

  /// Start the workout
  void startWorkout() {
    final currentState = state;
    if (currentState is WorkoutReady) {
      _elapsedSeconds = 0;
      emit(WorkoutInProgress(workout: currentState.workout));
      _startTimer();
    }
  }

  /// Start the elapsed time timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      _saveCounter++;
      final current = state;
      if (current is WorkoutInProgress && !current.isPaused) {
        if (current.isResting) {
          final currentRemaining = current.restRemainingSeconds ?? 0;
          final nextRemaining = currentRemaining - 1;

          if (nextRemaining <= 0) {
            emit(
              current.copyWith(
                elapsedSeconds: _elapsedSeconds,
                isResting: false,
              ),
            );
          } else {
            emit(
              current.copyWith(
                elapsedSeconds: _elapsedSeconds,
                restRemainingSeconds: nextRemaining,
              ),
            );
          }
        } else {
          emit(current.copyWith(elapsedSeconds: _elapsedSeconds));
        }
        // Save progress every 10 seconds
        if (_saveCounter >= 10) {
          _saveCounter = 0;
          _saveProgress(current);
        }
      }
    });
  }

  /// Save current workout progress
  void _saveProgress(WorkoutInProgress state) {
    _persistenceService.saveWorkoutProgress(
      workoutId: state.workout.id,
      exerciseIndex: state.currentExerciseIndex,
      currentSet: state.currentSet,
      elapsedSeconds: _elapsedSeconds,
      workout: state.workout,
    );
  }

  /// Complete current set and move to rest or next exercise
  void completeSet() {
    final current = state;
    if (current is! WorkoutInProgress) return;

    if (!current.isLastSet) {
      // More sets to do - go to rest
      final restSeconds = current.currentExercise.restSeconds > 0
          ? current.currentExercise.restSeconds
          : 30;
      emit(
        current.copyWith(
          currentSet: current.currentSet + 1,
          isResting: true,
          restRemainingSeconds: restSeconds,
        ),
      );
    } else {
      // All sets done - move to next exercise
      _moveToNextExercise();
    }
  }

  /// Finish rest period
  void finishRest() {
    final current = state;
    if (current is WorkoutInProgress && current.isResting) {
      emit(current.copyWith(isResting: false, restRemainingSeconds: 0));
    }
  }

  /// Skip to next exercise
  void skipExercise() {
    _moveToNextExercise();
  }

  /// Move to the next exercise
  void _moveToNextExercise() {
    final current = state;
    if (current is! WorkoutInProgress) return;

    if (current.isLastExercise) {
      // Workout complete!
      // Workout complete!
      _finishWorkout(current.workout);
    } else {
      emit(
        current.copyWith(
          currentExerciseIndex: current.currentExerciseIndex + 1,
          currentSet: 1,
          isResting: false,
          restRemainingSeconds: 0,
        ),
      );
    }
  }

  /// Go back to previous exercise
  void previousExercise() {
    final current = state;
    if (current is WorkoutInProgress && current.currentExerciseIndex > 0) {
      emit(
        current.copyWith(
          currentExerciseIndex: current.currentExerciseIndex - 1,
          currentSet: 1,
          isResting: false,
          restRemainingSeconds: 0,
        ),
      );
    }
  }

  /// Pause the workout
  void pauseWorkout() {
    _timer?.cancel();
    final current = state;
    if (current is WorkoutInProgress) {
      emit(current.copyWith(isPaused: true));
    }
  }

  /// Resume the workout
  void resumeWorkout() {
    final current = state;
    if (current is WorkoutInProgress) {
      emit(current.copyWith(isPaused: false));
      _startTimer();
    }
  }

  /// Report pain during exercise - shows pain location dialog
  void reportPain() {
    final current = state;
    if (current is WorkoutInProgress) {
      _timer?.cancel();
      _painReportsCount++;
      emit(
        WorkoutPainReported(
          workout: current.workout,
          currentExerciseIndex: current.currentExerciseIndex,
          elapsedSeconds: _elapsedSeconds,
        ),
      );
    }
  }

  /// Set pain location and request exercise replacement
  Future<void> requestExerciseReplacement(String painLocation) async {
    final current = state;
    if (current is! WorkoutPainReported) return;

    emit(
      WorkoutExerciseReplacing(
        workout: current.workout,
        currentExerciseIndex: current.currentExerciseIndex,
        elapsedSeconds: current.elapsedSeconds,
        painLocation: painLocation,
        message: 'Подбираем безопасную альтернативу...',
      ),
    );

    try {
      if (_currentProfile == null) {
        // No profile, just skip the exercise
        _continueAfterPain(current.workout, current.currentExerciseIndex);
        return;
      }

      final exercises = await _exerciseRepository.getExercises();

      final replacement = await _geminiService.replaceExercise(
        currentExercise: current.currentExercise,
        painLocation: painLocation,
        profile: _currentProfile!,
        availableExercises: exercises,
      );

      if (replacement != null) {
        // Replace exercise in workout
        final updatedWorkout = _replaceExerciseInWorkout(
          current.workout,
          current.currentExerciseIndex,
          replacement,
        );

        emit(
          WorkoutInProgress(
            workout: updatedWorkout,
            currentExerciseIndex: current.currentExerciseIndex,
            elapsedSeconds: current.elapsedSeconds,
          ),
        );
        _startTimer();
      } else {
        // Couldn't get replacement, skip to next
        _continueAfterPain(current.workout, current.currentExerciseIndex);
      }
    } catch (e) {
      // On error, skip to next exercise
      _continueAfterPain(current.workout, current.currentExerciseIndex);
    }
  }

  /// Skip exercise after reporting pain (without replacement)
  void skipAfterPain() {
    final current = state;
    if (current is WorkoutPainReported) {
      _continueAfterPain(current.workout, current.currentExerciseIndex);
    }
  }

  /// Cancel pain report and continue with same exercise
  void cancelPainReport() {
    final current = state;
    if (current is WorkoutPainReported) {
      emit(
        WorkoutInProgress(
          workout: current.workout,
          currentExerciseIndex: current.currentExerciseIndex,
          elapsedSeconds: current.elapsedSeconds,
        ),
      );
      _startTimer();
    } else if (current is WorkoutPainRest) {
      _restTimer?.cancel();
      emit(
        WorkoutInProgress(
          workout: current.workout,
          currentExerciseIndex: current.currentExerciseIndex,
          elapsedSeconds: current.elapsedSeconds,
        ),
      );
      _startTimer();
    }
  }

  /// Step 1 -> Step 2: Select pain location and move to intensity selection
  void selectPainLocation(String location) {
    final current = state;
    if (current is WorkoutPainReported &&
        current.step == PainFlowStep.location) {
      emit(
        current.copyWith(step: PainFlowStep.intensity, painLocation: location),
      );
    }
  }

  /// Step 2 -> Step 3: Select pain intensity and move to action selection
  void selectPainIntensity(int intensity) {
    final current = state;
    if (current is WorkoutPainReported &&
        current.step == PainFlowStep.intensity) {
      emit(
        current.copyWith(step: PainFlowStep.action, painIntensity: intensity),
      );
    }
  }

  /// Go back to previous step in pain flow
  void painFlowBack() {
    final current = state;
    if (current is WorkoutPainReported) {
      if (current.step == PainFlowStep.intensity) {
        emit(current.copyWith(step: PainFlowStep.location));
      } else if (current.step == PainFlowStep.action) {
        emit(current.copyWith(step: PainFlowStep.intensity));
      }
    }
  }

  Timer? _restTimer;

  /// Take a pain rest break
  void takePainRest(int durationSeconds) {
    final current = state;
    if (current is WorkoutPainReported) {
      emit(
        WorkoutPainRest(
          workout: current.workout,
          currentExerciseIndex: current.currentExerciseIndex,
          elapsedSeconds: current.elapsedSeconds,
          restDurationSeconds: durationSeconds,
          remainingSeconds: durationSeconds,
          painLocation: current.painLocation ?? '',
          painIntensity: current.painIntensity ?? 5,
        ),
      );
      _startRestTimer();
    }
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state;
      if (current is WorkoutPainRest) {
        if (current.remainingSeconds <= 1) {
          _restTimer?.cancel();
          finishPainRest();
        } else {
          emit(
            current.copyWith(remainingSeconds: current.remainingSeconds - 1),
          );
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// Finish pain rest and continue workout
  void finishPainRest() {
    _restTimer?.cancel();
    final current = state;
    if (current is WorkoutPainRest) {
      emit(
        WorkoutInProgress(
          workout: current.workout,
          currentExerciseIndex: current.currentExerciseIndex,
          elapsedSeconds: current.elapsedSeconds,
        ),
      );
      _startTimer();
    }
  }

  /// End workout due to severe pain
  void endWorkoutDueToPain() {
    final current = state;
    Workout? workout;

    if (current is WorkoutPainReported) {
      workout = current.workout;
    } else if (current is WorkoutPainRest) {
      workout = current.workout;
    }

    if (workout != null) {
      _restTimer?.cancel();
      _timer?.cancel();
      _finishWorkout(workout);
    }
  }

  /// Continue workout from action step (light pain)
  void continueAfterPainAssessment() {
    final current = state;
    if (current is WorkoutPainReported) {
      emit(
        WorkoutInProgress(
          workout: current.workout,
          currentExerciseIndex: current.currentExerciseIndex,
          elapsedSeconds: current.elapsedSeconds,
        ),
      );
      _startTimer();
    }
  }

  /// Request exercise replacement from action step
  Future<void> replaceExerciseAfterPainAssessment() async {
    final current = state;
    if (current is WorkoutPainReported && current.painLocation != null) {
      await requestExerciseReplacement(current.painLocation!);
    }
  }

  void _continueAfterPain(Workout workout, int currentIndex) {
    if (currentIndex >= workout.allExercises.length - 1) {
      // Last exercise, complete workout
      // Last exercise, complete workout
      _finishWorkout(workout);
    } else {
      // Move to next exercise
      emit(
        WorkoutInProgress(
          workout: workout,
          currentExerciseIndex: currentIndex + 1,
          elapsedSeconds: _elapsedSeconds,
        ),
      );
      _startTimer();
    }
  }

  Workout _replaceExerciseInWorkout(
    Workout workout,
    int exerciseIndex,
    WorkoutExercise replacement,
  ) {
    // Calculate which section and index
    int warmupLength = workout.warmup.length;
    int mainLength = workout.mainExercises.length;

    if (exerciseIndex < warmupLength) {
      // Replace in warmup
      final newWarmup = List<WorkoutExercise>.from(workout.warmup);
      newWarmup[exerciseIndex] = replacement;
      return workout.copyWith(warmup: newWarmup);
    } else if (exerciseIndex < warmupLength + mainLength) {
      // Replace in main exercises
      final mainIndex = exerciseIndex - warmupLength;
      final newMain = List<WorkoutExercise>.from(workout.mainExercises);
      newMain[mainIndex] = replacement;
      return workout.copyWith(mainExercises: newMain);
    } else {
      // Replace in cooldown
      final cooldownIndex = exerciseIndex - warmupLength - mainLength;
      final newCooldown = List<WorkoutExercise>.from(workout.cooldown);
      newCooldown[cooldownIndex] = replacement;
      return workout.copyWith(cooldown: newCooldown);
    }
  }

  /// Get explanation for why an exercise is safe
  Future<String> explainExercise(
    String exerciseName,
    String exerciseDescription,
  ) async {
    if (_currentProfile == null) {
      return 'Профиль не загружен';
    }

    return _geminiService.explainExerciseSafety(
      exerciseName: exerciseName,
      exerciseDescription: exerciseDescription,
      profile: _currentProfile!,
    );
  }

  /// Cancel and reset workout
  void cancelWorkout() {
    _timer?.cancel();
    _persistenceService.clearWorkoutProgress();
    emit(const WorkoutInitial());
  }

  /// Save workout completion to history
  Future<void> _saveWorkoutHistory(Workout workout, int durationSeconds) async {
    try {
      await _firestore.collection('workout_history').add({
        'workout_id': workout.id,
        'user_uid': workout.userUid,
        'title': workout.title,
        'type': workout.type,
        'intensity': workout.intensity,
        'duration_seconds': durationSeconds,
        'exercises_completed': workout.totalExercises,
        'pain_reports': _painReportsCount,
        'completed_at': Timestamp.now(),
      });
    } catch (e) {
      // Silent fail - don't disrupt user experience
      debugPrint('Error saving workout history: $e');
    }
  }

  /// Finish workout and generate feedback
  Future<void> _finishWorkout(Workout workout) async {
    _timer?.cancel();

    // 1. Emit completed state immediately
    emit(
      WorkoutCompleted(
        workout: workout,
        totalDurationSeconds: _elapsedSeconds,
        painReportsCount: _painReportsCount,
      ),
    );

    // 2. Save history
    _saveWorkoutHistory(workout, _elapsedSeconds);

    // 3. Generate feedback in background
    if (_currentProfile != null) {
      try {
        final feedback = await _geminiService.generatePostWorkoutFeedback(
          durationMinutes: _elapsedSeconds ~/ 60,
          exercisesCompleted: workout.totalExercises,
          totalExercises: workout.totalExercises,
          workoutType: workout.type,
          painReports: _painReportsCount,
          profile: _currentProfile!,
        );

        // Update state if we are still on completion screen
        if (!isClosed && state is WorkoutCompleted) {
          final currentState = state as WorkoutCompleted;
          // Only update if it's the same workout (sanity check)
          if (currentState.workout.id == workout.id) {
            emit(
              WorkoutCompleted(
                workout: currentState.workout,
                totalDurationSeconds: currentState.totalDurationSeconds,
                painReportsCount: currentState.painReportsCount,
                feedback: feedback,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error generating feedback: $e');
      }
    }
  }

  /// Reset to initial state

  /// Reset to initial state
  void reset() {
    _timer?.cancel();
    _painReportsCount = 0;
    _persistenceService.clearWorkoutProgress();
    emit(const WorkoutInitial());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
