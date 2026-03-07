import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_localization_utils.dart';
import '../../../core/utils/workout_localization_utils.dart';
import '../../../data/models/workout_model.dart';
import '../../../gen/app_localizations.dart';
import '../../blocs/workout/workout_cubit.dart';
import '../../blocs/workout/workout_flow_route_target.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../blocs/checkin/checkin_cubit.dart';
import '../../utils/ui_action_guard.dart';

/// Page for selecting workout type and generating AI workout
class WorkoutGenerationPage extends StatelessWidget {
  final String? initialWorkoutType; // Add this

  const WorkoutGenerationPage({super.key, this.initialWorkoutType});

  @override
  Widget build(BuildContext context) {
    // Use global WorkoutCubit from MultiBlocProvider in main.dart
    // Do NOT create local BlocProvider - it shadows global state!
    return _WorkoutGenerationContent(initialWorkoutType: initialWorkoutType);
  }
}

class _WorkoutGenerationContent extends StatefulWidget {
  final String? initialWorkoutType; // Add this
  const _WorkoutGenerationContent({this.initialWorkoutType});

  @override
  State<_WorkoutGenerationContent> createState() =>
      _WorkoutGenerationContentState();
}

class _WorkoutGenerationContentState extends State<_WorkoutGenerationContent> {
  final UiActionGuard<Never> _actionGuard = UiActionGuard<Never>(
    debugLabel: 'WorkoutGenerationPage',
  );
  bool _isNavigatingFromListener = false;
  bool _isRecoveringFromStateMismatch = false;

  void _recoverFromStateMismatch(
    BuildContext context,
    WorkoutState state, {
    required String source,
  }) {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (!isCurrentRoute) {
      return;
    }

    if (_isRecoveringFromStateMismatch || _isNavigatingFromListener) {
      return;
    }

    final target = state.routeTarget;
    if (target == WorkoutFlowRouteTarget.generation) {
      return;
    }

    _isRecoveringFromStateMismatch = true;
    debugPrint(
      'WorkoutGenerationPage: state mismatch recovery from $source, state=${state.runtimeType}, target=$target',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      switch (target) {
        case WorkoutFlowRouteTarget.preview:
          context.go(AppRoutes.workoutPreview);
          break;
        case WorkoutFlowRouteTarget.player:
          context.go(AppRoutes.workoutPlayer);
          break;
        case WorkoutFlowRouteTarget.generation:
          break;
      }

      _isRecoveringFromStateMismatch = false;
    });
  }

  String _localizedTypeLabel(BuildContext context, String type) {
    return WorkoutLocalizationUtils.localizedWorkoutType(
      AppLocalizations.of(context),
      type,
    );
  }

  String _localizedTypeDescription(BuildContext context, String type) {
    final l = AppLocalizations.of(context);
    switch (type) {
      case WorkoutTypes.lfk:
        return l.workoutDescLfk;
      case WorkoutTypes.stretching:
        return l.workoutDescStretching;
      case WorkoutTypes.strength:
        return l.workoutDescStrength;
      case WorkoutTypes.cardio:
        return l.workoutDescCardio;
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-generate if type is passed
    if (widget.initialWorkoutType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateWorkout(context, widget.initialWorkoutType!);
      });
    } else {
      // Check for saved session on page load ONLY if not starting a specific new one
      context.read<WorkoutCubit>().checkForActiveSession();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _recoverFromStateMismatch(
          context,
          context.read<WorkoutCubit>().state,
          source: 'initial_state_check',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.workoutSelectionTitle),

        // Leading button removed for top-level tab
      ),
      body: BlocConsumer<WorkoutCubit, WorkoutState>(
        listener: (context, state) {
          final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
          if (!isCurrentRoute) {
            return;
          }

          if (state is WorkoutReady) {
            if (_isNavigatingFromListener) return;
            _isNavigatingFromListener = true;
            final future = context.push(AppRoutes.workoutPreview);
            unawaited(
              future.whenComplete(() {
                _isNavigatingFromListener = false;
              }),
            );
          }
          if (state is WorkoutInProgress) {
            // Restored session → go to player
            if (_isNavigatingFromListener) return;
            _isNavigatingFromListener = true;
            final future = context.push(AppRoutes.workoutPlayer);
            unawaited(
              future.whenComplete(() {
                _isNavigatingFromListener = false;
              }),
            );
          }
          if (state is WorkoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  ErrorLocalizationUtils.localize(
                    context,
                    state.errorCode,
                    fallbackMessage: state.debugMessage,
                  ),
                ),
                backgroundColor: AppColors.error,
                action: state.retryable && state.workoutType != null
                    ? SnackBarAction(
                        label: l.workoutRetry,
                        textColor: Colors.white,
                        onPressed: () {
                          _generateWorkout(context, state.workoutType!);
                        },
                      )
                    : null,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.routeTarget != WorkoutFlowRouteTarget.generation) {
            _recoverFromStateMismatch(context, state, source: 'build');
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkoutGenerating) {
            return _buildGeneratingView(context, state);
          }
          if (state is WorkoutSessionRecovery) {
            return _buildSessionRecoveryView(context, state);
          }

          return _buildWorkoutTypeSelection(context);
        },
      ),
    );
  }

  Widget _buildSessionRecoveryView(
    BuildContext context,
    WorkoutSessionRecovery state,
  ) {
    final l = AppLocalizations.of(context);
    final workoutLabel = _localizedTypeLabel(context, state.workout.type);
    final exercisesDone = state.exerciseIndex;
    final totalExercises = state.workout.totalExercises;
    final minutes = state.elapsedSeconds ~/ 60;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.indigo.shade50],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  const Icon(Icons.restore, size: 56, color: Colors.indigo),
                  const SizedBox(height: 16),
                  Text(
                    l.workoutSessionTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.workoutSessionSubtitle,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  // Workout info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          WorkoutLocalizationUtils.localizedWorkoutTitle(
                            l10n: l,
                            localeCode: Localizations.localeOf(
                              context,
                            ).languageCode,
                            type: state.workout.type,
                            rawTitle: state.workout.title,
                            sourceLanguageCode:
                                state.workout.aiMetadata?['language_code']
                                    as String?,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoChip(Icons.fitness_center, workoutLabel),
                            _buildInfoChip(
                              Icons.timer,
                              l.workoutMinutesShort(minutes),
                            ),
                            _buildInfoChip(
                              Icons.format_list_numbered,
                              '$exercisesDone/$totalExercises',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.workoutSessionSaved(
                            WorkoutLocalizationUtils.localizedTimeAgo(
                              l,
                              state.savedAt,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<WorkoutCubit>().restoreSession();
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  l.workoutSessionContinue,
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  context.read<WorkoutCubit>().discardSession();
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(l.workoutSessionNew),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.indigo),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildWorkoutTypeSelection(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.workoutSelectionQuestion,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l.workoutSelectionHint,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildWorkoutTypeCard(
                        context,
                        type: WorkoutTypes.lfk,
                        icon: Icons.self_improvement,
                        color: AppColors.primary,
                      ),
                      _buildWorkoutTypeCard(
                        context,
                        type: WorkoutTypes.stretching,
                        icon: Icons.accessibility_new,
                        color: AppColors.secondary,
                      ),
                      _buildWorkoutTypeCard(
                        context,
                        type: WorkoutTypes.strength,
                        icon: Icons.fitness_center,
                        color: AppColors.warning,
                      ),
                      _buildWorkoutTypeCard(
                        context,
                        type: WorkoutTypes.cardio,
                        icon: Icons.directions_run,
                        color: AppColors.info,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildCachedWorkoutsSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCachedWorkoutsSection(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<List<Workout>>(
      future: context.read<WorkoutCubit>().getCachedWorkouts(),
      builder: (context, snapshot) {
        final workouts = snapshot.data ?? [];
        if (workouts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.offline_bolt,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  l.workoutSavedWorkouts,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...workouts.map((w) => _buildCachedWorkoutCard(context, w)),
          ],
        );
      },
    );
  }

  Widget _buildCachedWorkoutCard(BuildContext context, Workout workout) {
    final l = AppLocalizations.of(context);
    final typeLabel = _localizedTypeLabel(context, workout.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.fitness_center, color: AppColors.primary, size: 20),
        ),
        title: Text(
          WorkoutLocalizationUtils.localizedWorkoutTitle(
            l10n: l,
            localeCode: Localizations.localeOf(context).languageCode,
            type: workout.type,
            rawTitle: workout.title,
            sourceLanguageCode: workout.aiMetadata?['language_code'] as String?,
          ),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$typeLabel • ${l.workoutMinutesShort(workout.estimatedDuration)}',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.play_circle_outline, size: 28),
        onTap: () {
          context.read<WorkoutCubit>().loadCachedWorkout(workout);
        },
      ),
    );
  }

  Widget _buildWorkoutTypeCard(
    BuildContext context, {
    required String type,
    required IconData icon,
    required Color color,
  }) {
    final label = _localizedTypeLabel(context, type);
    final description = _localizedTypeDescription(context, type);

    return GestureDetector(
      onTap: () => _generateWorkout(context, type),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.8), color],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _generateWorkout(BuildContext context, String workoutType) {
    unawaited(
      _actionGuard.run('generate_workout_action', () async {
        _generateWorkoutUnsafe(context, workoutType);
      }),
    );
  }

  void _generateWorkoutUnsafe(BuildContext context, String workoutType) {
    final l = AppLocalizations.of(context);
    final profileState = context.read<ProfileCubit>().state;
    final checkInState = context.read<CheckInCubit>().state;

    if (profileState is! ProfileLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.workoutProfileNotLoaded),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (checkInState is! CheckInCompleted &&
        checkInState is! CheckInAlreadyCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.workoutCheckinRequired),
          backgroundColor: AppColors.warning,
        ),
      );
      context.push(AppRoutes.checkIn, extra: workoutType);
      return;
    }

    final checkIn = checkInState is CheckInCompleted
        ? checkInState.checkIn
        : (checkInState as CheckInAlreadyCompleted).checkIn;

    context.read<WorkoutCubit>().generateWorkout(
      profile: profileState.profile,
      checkIn: checkIn,
      workoutType: workoutType,
      languageCode: Localizations.localeOf(context).languageCode,
    );
  }

  Widget _buildGeneratingView(BuildContext context, WorkoutGenerating state) {
    final l = AppLocalizations.of(context);
    final label = _localizedTypeLabel(context, state.workoutType);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  Icon(Icons.psychology, size: 48, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l.workoutGenerating(label),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _localizedGeneratingMessage(context, state.step),
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            TextButton(
              onPressed: () {
                context.read<WorkoutCubit>().reset();
              },
              child: Text(l.workoutCancel),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedGeneratingMessage(
    BuildContext context,
    WorkoutGenerationStep step,
  ) {
    final l = AppLocalizations.of(context);
    switch (step) {
      case WorkoutGenerationStep.analyzingProfile:
        return l.workoutGeneratingAnalyzingProfile;
      case WorkoutGenerationStep.selectingSafeExercises:
        return l.workoutGeneratingSelectingSafeExercises;
      case WorkoutGenerationStep.adaptingIntensity:
        return l.workoutGeneratingAdaptingIntensity;
      case WorkoutGenerationStep.creatingProgram:
        return l.workoutGeneratingCreatingProgram;
      case WorkoutGenerationStep.validatingSafety:
        return l.workoutGeneratingValidatingSafety;
    }
  }
}
