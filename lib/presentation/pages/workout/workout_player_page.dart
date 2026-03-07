import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/tab_branch_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ai_text_localization_utils.dart';
import '../../../core/utils/exercise_localization_utils.dart';
import '../../../core/utils/workout_localization_utils.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/models/recovery_plan_model.dart';
import '../../../data/models/ai_feedback_models.dart';
import '../../blocs/workout/workout_cubit.dart';
import '../../blocs/workout/workout_flow_route_target.dart';
import '../../utils/ui_action_guard.dart';
import '../../widgets/video/exercise_video_player.dart';
import '../../widgets/video/exercise_video_resolver.dart';
import 'exercise_search_webview_page.dart';
import 'exercise_video_fullscreen_page.dart';
import '../../../gen/app_localizations.dart';

/// Page for playing/executing a workout
class WorkoutPlayerPage extends StatefulWidget {
  const WorkoutPlayerPage({super.key});

  @override
  State<WorkoutPlayerPage> createState() => _WorkoutPlayerPageState();
}

class _WorkoutPlayerPageState extends State<WorkoutPlayerPage> {
  final UiActionGuard<_WorkoutModalType> _uiActionGuard =
      UiActionGuard<_WorkoutModalType>(debugLabel: 'WorkoutPlayerPage');
  bool _isRecoveringFromInvalidState = false;

  void _runGuardedAction(
    BuildContext context, {
    required String actionKey,
    bool isModalAction = false,
    _WorkoutModalType? modalType,
    bool idempotentWhenSameModalOpen = false,
    Duration minInterval = const Duration(milliseconds: 250),
    required FutureOr<void> Function() action,
  }) {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (!isCurrentRoute) {
      return;
    }

    if (isModalAction) {
      if (modalType == null) {
        debugPrint(
          'WorkoutPlayerPage: Ignored "$actionKey" because modalType is required for modal actions',
        );
        return;
      }

      unawaited(
        _uiActionGuard.runModal(
          actionKey,
          modalType: modalType,
          action: action,
          minInterval: minInterval,
          idempotentWhenSameModalOpen: idempotentWhenSameModalOpen,
        ),
      );
      return;
    }

    unawaited(_uiActionGuard.run(actionKey, action, minInterval: minInterval));
  }

  void _closeReadyFlow(BuildContext context) {
    context.read<WorkoutCubit>().reset();
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goToTabBranch(AppTabBranch.home);
  }

  void _recoverFromInvalidState(
    BuildContext context,
    WorkoutState state, {
    required String source,
  }) {
    if (_isRecoveringFromInvalidState) {
      return;
    }
    _isRecoveringFromInvalidState = true;

    final target = state.routeTarget;
    debugPrint(
      'WorkoutPlayerPage: state mismatch recovery from $source, state=${state.runtimeType}, navigatingTo=$target',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      switch (target) {
        case WorkoutFlowRouteTarget.preview:
          context.go(AppRoutes.workoutPreview);
          break;
        case WorkoutFlowRouteTarget.generation:
          context.goToTabBranch(AppTabBranch.workout, initialLocation: true);
          break;
        case WorkoutFlowRouteTarget.player:
          break;
      }

      _isRecoveringFromInvalidState = false;
    });
  }

  void _handlePlayerBack(
    BuildContext context,
    WorkoutState state, {
    required String source,
  }) {
    debugPrint(
      'WorkoutPlayerPage: back pressed from $source, state=${state.runtimeType}',
    );

    if (state is WorkoutPainReported) {
      if (state.step == PainFlowStep.location) {
        context.read<WorkoutCubit>().cancelPainReport();
      } else {
        context.read<WorkoutCubit>().painFlowBack();
      }
      return;
    }

    if (state is WorkoutPainRest) {
      context.read<WorkoutCubit>().cancelPainReport();
      return;
    }

    if (state is WorkoutReady) {
      _closeReadyFlow(context);
      return;
    }

    if (state is WorkoutInProgress ||
        state is WorkoutExerciseReplacing ||
        state is WorkoutCompleted) {
      _runGuardedAction(
        context,
        actionKey: 'workout_exit_confirmation_dialog',
        isModalAction: true,
        modalType: _WorkoutModalType.exit,
        action: () => _showExitConfirmation(context),
      );
      return;
    }

    _recoverFromInvalidState(context, state, source: 'back_$source');
  }

  Widget _withBackHandler(
    BuildContext context,
    WorkoutState state,
    Widget child,
  ) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _handlePlayerBack(context, state, source: 'system');
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listenWhen: (previous, current) =>
          previous is! WorkoutCompleted && current is WorkoutCompleted,
      listener: (context, state) {
        if (state is WorkoutCompleted) {
          _runGuardedAction(
            context,
            actionKey: 'workout_completion_dialog',
            isModalAction: true,
            modalType: _WorkoutModalType.completion,
            action: () => _showCompletionDialog(context, state),
          );
        }
      },
      // Only rebuild for structural changes.
      // Elapsed/rest countdown are rendered by local timer widgets.
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is WorkoutInProgress && current is WorkoutInProgress) {
          return previous.currentExerciseIndex !=
                  current.currentExerciseIndex ||
              previous.currentSet != current.currentSet ||
              previous.isResting != current.isResting ||
              previous.isPaused != current.isPaused ||
              previous.workout != current.workout;
        }
        if (previous is WorkoutPainRest && current is WorkoutPainRest) {
          // Pain-rest countdown is rendered separately — skip timer ticks
          return previous.currentExerciseIndex !=
                  current.currentExerciseIndex ||
              previous.workout != current.workout;
        }
        if (previous is WorkoutPainReported && current is WorkoutPainReported) {
          return previous.step != current.step ||
              previous.painLocation != current.painLocation ||
              previous.painIntensity != current.painIntensity;
        }
        return true;
      },
      builder: (context, state) {
        if (state is WorkoutReady) {
          return _withBackHandler(
            context,
            state,
            _buildReadyView(context, state.workout),
          );
        }

        if (state is WorkoutInProgress) {
          return _withBackHandler(
            context,
            state,
            _buildPlayerView(context, state),
          );
        }

        if (state is WorkoutPainReported) {
          return _withBackHandler(
            context,
            state,
            _buildPainReportedView(context, state),
          );
        }

        if (state is WorkoutPainRest) {
          return _withBackHandler(
            context,
            state,
            _buildPainRestView(context, state),
          );
        }

        if (state is WorkoutExerciseReplacing) {
          return _withBackHandler(
            context,
            state,
            _buildReplacingView(context, state),
          );
        }

        if (state is WorkoutCompleted) {
          return _withBackHandler(
            context,
            state,
            _buildWorkoutCompletedView(context),
          );
        }

        _recoverFromInvalidState(context, state, source: 'build_fallback');
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).workoutPlayerTitle),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildWorkoutCompletedView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).workoutPlayerTitle),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).completionAnalyzing),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyView(BuildContext context, Workout workout) {
    final l10n = AppLocalizations.of(context);
    final localizedTitle = WorkoutLocalizationUtils.localizedWorkoutTitle(
      l10n: l10n,
      localeCode: Localizations.localeOf(context).languageCode,
      type: workout.type,
      rawTitle: workout.title,
      sourceLanguageCode: workout.aiMetadata?['language_code'] as String?,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workoutPlayerReady),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handlePlayerBack(
            context,
            WorkoutReady(workout),
            source: 'appbar',
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            WorkoutLocalizationUtils.localizedWorkoutType(
                              l10n,
                              workout.type,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.timer,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '~${l10n.workoutMinutesShort(workout.estimatedDuration)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizedTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      workout.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Exercise sections
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExerciseSection(
                        context,
                        l10n.workoutPlayerWarmup,
                        workout.warmup,
                        Icons.wb_sunny,
                      ),
                      const SizedBox(height: 16),
                      _buildExerciseSection(
                        context,
                        l10n.workoutPlayerMainPart,
                        workout.mainExercises,
                        Icons.fitness_center,
                      ),
                      const SizedBox(height: 16),
                      _buildExerciseSection(
                        context,
                        l10n.workoutPlayerCooldown,
                        workout.cooldown,
                        Icons.nightlight,
                      ),
                    ],
                  ),
                ),
              ),

              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.read<WorkoutCubit>().startWorkout(),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.workoutPlayerStartWorkout),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseSection(
    BuildContext context,
    String title,
    List<WorkoutExercise> exercises,
    IconData icon,
  ) {
    if (exercises.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              '$title (${exercises.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...exercises.asMap().entries.map((entry) {
          final exercise = entry.value;
          final displayName = _localizedExerciseName(context, exercise);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                child: Text(
                  '${entry.key + 1}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(displayName),
              subtitle: Text(
                WorkoutLocalizationUtils.localizedExerciseFormat(
                  AppLocalizations.of(context),
                  exercise,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPlayerView(BuildContext context, WorkoutInProgress state) {
    final exercise = state.currentExercise;
    final isResting = state.isResting;
    final displayName = _localizedExerciseName(context, exercise);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          key: const Key('workout_player_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handlePlayerBack(context, state, source: 'appbar'),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'skip') {
                _runGuardedAction(
                  context,
                  actionKey: 'workout_skip_exercise',
                  action: () => context.read<WorkoutCubit>().skipExercise(),
                );
              } else if (value == 'exit') {
                _runGuardedAction(
                  context,
                  actionKey: 'workout_exit_confirmation_dialog',
                  isModalAction: true,
                  modalType: _WorkoutModalType.exit,
                  action: () => _showExitConfirmation(context),
                );
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'skip',
                child: Text(
                  AppLocalizations.of(context).workoutPlayerSkipExercise,
                ),
              ),
              PopupMenuItem(
                value: 'exit',
                child: Text(
                  AppLocalizations.of(context).workoutPlayerFinishWorkout,
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: isResting
            ? _buildRestView(context, state, exercise)
            : _buildExerciseView(context, state, exercise),
      ),
    );
  }

  Widget _buildExerciseView(
    BuildContext context,
    WorkoutInProgress state,
    WorkoutExercise exercise,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _buildExerciseImage(context, exercise),
                ),
                const SizedBox(height: 10),
                _buildLiveStatsRow(context, state, exercise),
                const SizedBox(height: 10),
                _buildAiInsightCard(
                  context,
                  exercise,
                  sourceLanguageCode:
                      state.workout.aiMetadata?['language_code'] as String?,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _runGuardedAction(
                context,
                actionKey: 'workout_report_pain',
                action: () => context.read<WorkoutCubit>().reportPain(),
              ),
              icon: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
              ),
              label: Text(
                AppLocalizations.of(context).workoutPlayerPainButton,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: state.currentExerciseIndex > 0
                        ? () => _runGuardedAction(
                            context,
                            actionKey: 'workout_previous_exercise',
                            action: () =>
                                context.read<WorkoutCubit>().previousExercise(),
                          )
                        : null,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _runGuardedAction(
                        context,
                        actionKey: 'workout_toggle_pause',
                        action: () {
                          if (state.isPaused) {
                            context.read<WorkoutCubit>().resumeWorkout();
                          } else {
                            context.read<WorkoutCubit>().pauseWorkout();
                          }
                        },
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Icon(
                        state.isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => _runGuardedAction(
                      context,
                      actionKey: 'workout_complete_set',
                      action: () => context.read<WorkoutCubit>().completeSet(),
                    ),
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context).workoutPlayerExerciseOf(
                      state.currentExerciseIndex + 1,
                      state.totalExercises,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: state.progress,
                  backgroundColor: AppColors.primaryLight.withValues(
                    alpha: 0.25,
                  ),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestView(
    BuildContext context,
    WorkoutInProgress state,
    WorkoutExercise exercise,
  ) {
    final totalRest = state.restDurationSeconds > 0
        ? state.restDurationSeconds
        : (exercise.restSeconds > 0 ? exercise.restSeconds : 30);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_filled,
              size: 74,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).workoutPlayerRest,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _WorkoutRestCountdown(
              restStartedAtEpochMs: state.restStartedAtEpochMs,
              restDurationSeconds: totalRest,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(
                context,
              ).workoutPlayerNextSet(_localizedExerciseName(context, exercise)),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).workoutPlayerAutoResume,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _runGuardedAction(
                  context,
                  actionKey: 'workout_finish_rest',
                  action: () => context.read<WorkoutCubit>().finishRest(),
                ),
                child: Text(
                  AppLocalizations.of(context).workoutSessionContinue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatsRow(
    BuildContext context,
    WorkoutInProgress state,
    WorkoutExercise exercise,
  ) {
    final reps = _extractRepCount(exercise);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: _WorkoutTimerDisplay(formatTime: _formatTime),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context).workoutPlayerReps.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reps,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiInsightCard(
    BuildContext context,
    WorkoutExercise exercise, {
    String? sourceLanguageCode,
  }) {
    return Container(
      key: const Key('workout_ai_insight_card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                AppLocalizations.of(context).workoutPlayerAiInsight,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).workoutPlayerAiNote,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _LocalizedAiInsightText(
                      exercise: exercise,
                      sourceLanguageCode: sourceLanguageCode,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        key: const Key('workout_ai_insight_open_button'),
                        onPressed: () => _runGuardedAction(
                          context,
                          actionKey: 'workout_ai_insight_dialog',
                          isModalAction: true,
                          modalType: _WorkoutModalType.aiInsight,
                          idempotentWhenSameModalOpen: true,
                          action: () => _showAiInsightDialog(
                            context,
                            exercise,
                            sourceLanguageCode: sourceLanguageCode,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppLocalizations.of(context).workoutPlayerGotIt,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildInsightThumbnail(exercise),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAiInsightDialog(
    BuildContext context,
    WorkoutExercise exercise, {
    String? sourceLanguageCode,
  }) async {
    final exerciseName = _localizedExerciseName(context, exercise);
    debugPrint(
      'WorkoutPlayerPage: Requesting AI insight dialog for "$exerciseName"',
    );

    final dismissReason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(
        name: 'workout_ai_insight_dialog_route',
      ),
      builder: (dialogContext) => AlertDialog(
        key: const Key('workout_ai_insight_dialog'),
        title: Text(AppLocalizations.of(context).workoutPlayerAiNote),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _localizedExerciseName(context, exercise),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              _LocalizedAiInsightText(
                exercise: exercise,
                sourceLanguageCode: sourceLanguageCode,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('workout_ai_insight_close_button'),
            onPressed: () {
              debugPrint(
                'WorkoutPlayerPage: AI insight dialog close button pressed for "$exerciseName"',
              );
              Navigator.of(dialogContext).pop('close_button');
            },
            child: Text(AppLocalizations.of(context).workoutPlayerClose),
          ),
        ],
      ),
    );

    debugPrint(
      'WorkoutPlayerPage: AI insight dialog dismissed (reason: ${dismissReason ?? 'system_or_route_pop'}) for "$exerciseName"',
    );
  }

  Widget _buildInsightThumbnail(WorkoutExercise exercise) {
    final imageUrl = Exercise.sanitizeImageUrl(exercise.imageUrl);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 74,
          height: 74,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildInsightPlaceholder(),
        ),
      );
    }
    return _buildInsightPlaceholder();
  }

  Widget _buildInsightPlaceholder() {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.medical_information_outlined,
        color: AppColors.primary,
      ),
    );
  }

  String _extractRepCount(WorkoutExercise exercise) {
    final matches = RegExp(r'\d+')
        .allMatches(exercise.displayFormat)
        .map((m) => m.group(0))
        .whereType<String>()
        .toList();
    if (matches.length >= 2) return matches.last;
    if (matches.isNotEmpty) return matches.first;
    return exercise.sets.toString();
  }

  // === Pain and replacement states ===

  Widget _buildPainReportedView(
    BuildContext context,
    WorkoutPainReported state,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPainStepTitle(context, state.step)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handlePlayerBack(context, state, source: 'appbar'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildPainStepContent(context, state),
        ),
      ),
    );
  }

  String _getPainStepTitle(BuildContext context, PainFlowStep step) {
    switch (step) {
      case PainFlowStep.location:
        return AppLocalizations.of(context).painWhereTitle;
      case PainFlowStep.intensity:
        return AppLocalizations.of(context).painIntensityTitle;
      case PainFlowStep.action:
        return AppLocalizations.of(context).painActionTitle;
    }
  }

  Widget _buildPainStepContent(
    BuildContext context,
    WorkoutPainReported state,
  ) {
    switch (state.step) {
      case PainFlowStep.location:
        return _buildLocationStep(context, state);
      case PainFlowStep.intensity:
        return _buildIntensityStep(context, state);
      case PainFlowStep.action:
        return _buildActionStep(context, state);
    }
  }

  // Step 1: Location selection
  Widget _buildLocationStep(BuildContext context, WorkoutPainReported state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.health_and_safety, size: 80, color: AppColors.warning),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context).painSelectArea,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).painCurrentExercise(
            _localizedExerciseName(context, state.currentExercise),
          ),
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildPainLocationButton(
                context,
                AppLocalizations.of(context).painLocationLowerBack,
                Icons.airline_seat_flat,
              ),
              _buildPainLocationButton(
                context,
                AppLocalizations.of(context).painLocationUpperBack,
                Icons.accessibility,
              ),
              _buildPainLocationButton(
                context,
                AppLocalizations.of(context).painLocationNeck,
                Icons.face,
              ),
              _buildPainLocationButton(
                context,
                AppLocalizations.of(context).painLocationKnees,
                Icons.directions_walk,
              ),
              _buildPainLocationButton(
                context,
                AppLocalizations.of(context).painLocationShoulders,
                Icons.fitness_center,
              ),
              _buildPainLocationButton(
                context,
                AppLocalizations.of(context).painLocationWrists,
                Icons.pan_tool,
              ),
              _buildPainLocationButton(
                context,
                AppLocalizations.of(context).painLocationAnkle,
                Icons.directions_run,
              ),
              _buildPainLocationButton(
                context,
                AppLocalizations.of(context).painLocationHips,
                Icons.airline_seat_legroom_extra,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.read<WorkoutCubit>().cancelPainReport(),
          child: Text(AppLocalizations.of(context).painCancelContinue),
        ),
      ],
    );
  }

  // Step 2: Intensity selection
  Widget _buildIntensityStep(BuildContext context, WorkoutPainReported state) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).painAreaText(state.painLocation!),
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context).painRateIntensity,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView(
            children: [
              _buildIntensityOption(
                context,
                1,
                '😊',
                AppLocalizations.of(context).painIntensity1,
                AppLocalizations.of(context).painIntensity1Sub,
                Colors.green,
              ),
              _buildIntensityOption(
                context,
                2,
                '🙂',
                AppLocalizations.of(context).painIntensity2,
                AppLocalizations.of(context).painIntensity2Sub,
                Colors.green,
              ),
              _buildIntensityOption(
                context,
                3,
                '😐',
                AppLocalizations.of(context).painIntensity3,
                AppLocalizations.of(context).painIntensity3Sub,
                Colors.green,
              ),
              const Divider(height: 24),
              _buildIntensityOption(
                context,
                4,
                '😕',
                AppLocalizations.of(context).painIntensity4,
                AppLocalizations.of(context).painIntensity4Sub,
                Colors.orange,
              ),
              _buildIntensityOption(
                context,
                5,
                '😟',
                AppLocalizations.of(context).painIntensity5,
                AppLocalizations.of(context).painIntensity5Sub,
                Colors.orange,
              ),
              _buildIntensityOption(
                context,
                6,
                '😣',
                AppLocalizations.of(context).painIntensity6,
                AppLocalizations.of(context).painIntensity6Sub,
                Colors.orange,
              ),
              const Divider(height: 24),
              _buildIntensityOption(
                context,
                7,
                '😖',
                AppLocalizations.of(context).painIntensity7,
                AppLocalizations.of(context).painIntensity7Sub,
                Colors.red,
              ),
              _buildIntensityOption(
                context,
                8,
                '😫',
                AppLocalizations.of(context).painIntensity8,
                AppLocalizations.of(context).painIntensity8Sub,
                Colors.red,
              ),
              _buildIntensityOption(
                context,
                9,
                '🤕',
                AppLocalizations.of(context).painIntensity9,
                AppLocalizations.of(context).painIntensity9Sub,
                Colors.red,
              ),
              _buildIntensityOption(
                context,
                10,
                '🚨',
                AppLocalizations.of(context).painIntensity10,
                AppLocalizations.of(context).painIntensity10Sub,
                Colors.red.shade900,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntensityOption(
    BuildContext context,
    int level,
    String emoji,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$level',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        subtitle: Text(subtitle),
        onTap: () => context.read<WorkoutCubit>().selectPainIntensity(level),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  // Step 3: Action selection
  Widget _buildActionStep(BuildContext context, WorkoutPainReported state) {
    final category = state.painCategory;

    return Column(
      children: [
        _buildPainSummaryCard(context, state),
        const SizedBox(height: 24),
        Text(
          _getActionTitle(context, category),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getActionSubtitle(context, category),
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: _buildActionOptions(context, state, category),
          ),
        ),
      ],
    );
  }

  Widget _buildPainSummaryCard(
    BuildContext context,
    WorkoutPainReported state,
  ) {
    final color = _getPainColor(state.painCategory);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            state.painCategory == 'severe' ? Icons.warning : Icons.info_outline,
            color: color,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).painAreaText(state.painLocation ?? ''),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  AppLocalizations.of(
                    context,
                  ).painLevelText(state.painIntensity ?? 0),
                  style: TextStyle(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPainColor(String category) {
    switch (category) {
      case 'light':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getActionTitle(BuildContext context, String category) {
    switch (category) {
      case 'light':
        return AppLocalizations.of(context).painActionLightTitle;
      case 'moderate':
        return AppLocalizations.of(context).painActionModerateTitle;
      case 'severe':
        return AppLocalizations.of(context).painActionSevereTitle;
      default:
        return AppLocalizations.of(context).painActionDefault;
    }
  }

  String _getActionSubtitle(BuildContext context, String category) {
    switch (category) {
      case 'light':
        return AppLocalizations.of(context).painActionLightSubtitle;
      case 'moderate':
        return AppLocalizations.of(context).painActionModerateSubtitle;
      case 'severe':
        return AppLocalizations.of(context).painActionSevereSubtitle;
      default:
        return '';
    }
  }

  List<Widget> _buildActionOptions(
    BuildContext context,
    WorkoutPainReported state,
    String category,
  ) {
    final cubit = context.read<WorkoutCubit>();

    switch (category) {
      case 'light':
        return [
          _buildActionButton(
            context,
            actionKey: 'pain_action_continue',
            icon: Icons.play_arrow,
            title: AppLocalizations.of(context).painContinueExercise,
            subtitle: AppLocalizations.of(context).painContinueSub,
            color: Colors.green,
            onTap: () => cubit.continueAfterPainAssessment(),
          ),
          _buildActionButton(
            context,
            actionKey: 'pain_action_replace',
            icon: Icons.swap_horiz,
            title: AppLocalizations.of(context).painReplaceExercise,
            subtitle: AppLocalizations.of(context).painReplaceSub,
            color: Colors.blue,
            onTap: () => cubit.replaceExerciseAfterPainAssessment(),
          ),
          _buildActionButton(
            context,
            actionKey: 'pain_action_rest_120',
            icon: Icons.timer,
            title: AppLocalizations.of(context).painBreak2min,
            subtitle: AppLocalizations.of(context).painBreak2minSub,
            color: Colors.orange,
            onTap: () => cubit.takePainRest(120),
          ),
        ];
      case 'moderate':
        return [
          _buildActionButton(
            context,
            actionKey: 'pain_action_replace',
            icon: Icons.swap_horiz,
            title: AppLocalizations.of(context).painReplaceExercise,
            subtitle: AppLocalizations.of(context).painReplaceModSub,
            color: Colors.blue,
            onTap: () => cubit.replaceExerciseAfterPainAssessment(),
          ),
          _buildActionButton(
            context,
            actionKey: 'pain_action_rest_300',
            icon: Icons.timer,
            title: AppLocalizations.of(context).painBreak5min,
            subtitle: AppLocalizations.of(context).painBreak5minSub,
            color: Colors.orange,
            onTap: () => cubit.takePainRest(300),
          ),
          _buildActionButton(
            context,
            actionKey: 'pain_action_end_workout',
            icon: Icons.stop,
            title: AppLocalizations.of(context).painEndWorkout,
            subtitle: AppLocalizations.of(context).painEndWorkoutSaveSub,
            color: Colors.grey,
            onTap: () => cubit.endWorkoutDueToPain(),
          ),
        ];
      case 'severe':
        return [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.medical_services, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).painSevereWarning,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(
            context,
            actionKey: 'pain_action_rest_600',
            icon: Icons.timer,
            title: AppLocalizations.of(context).painBreak10min,
            subtitle: AppLocalizations.of(context).painBreak10minSub,
            color: Colors.orange,
            onTap: () => cubit.takePainRest(600),
          ),
          _buildActionButton(
            context,
            actionKey: 'pain_action_end_workout',
            icon: Icons.stop,
            title: AppLocalizations.of(context).painEndWorkout,
            subtitle: AppLocalizations.of(context).painEndWorkoutHealthSub,
            color: Colors.red,
            onTap: () => cubit.endWorkoutDueToPain(),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String actionKey,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: () =>
            _runGuardedAction(context, actionKey: actionKey, action: onTap),
      ),
    );
  }

  Widget _buildPainLocationButton(
    BuildContext context,
    String location,
    IconData icon,
  ) {
    return OutlinedButton.icon(
      onPressed: () =>
          context.read<WorkoutCubit>().selectPainLocation(location),
      icon: Icon(icon, size: 20),
      label: Text(
        location,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }

  // Pain rest view with countdown timer
  Widget _buildPainRestView(BuildContext context, WorkoutPainRest state) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).painRestTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handlePlayerBack(context, state, source: 'appbar'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timer display
              _WorkoutPainRestCountdown(
                restStartedAtEpochMs: state.restStartedAtEpochMs,
                restDurationSeconds: state.restDurationSeconds,
              ),
              const SizedBox(height: 48),

              // Rest tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).painRestTips,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRestTip(context, state.painIntensity),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.read<WorkoutCubit>().finishPainRest(),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    AppLocalizations.of(context).painRestContinueEarly,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    context.read<WorkoutCubit>().endWorkoutDueToPain(),
                child: Text(AppLocalizations.of(context).painEndWorkout),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRestTip(BuildContext context, int painIntensity) {
    if (painIntensity <= 3) {
      return AppLocalizations.of(context).painRestTipLight;
    } else if (painIntensity <= 6) {
      return AppLocalizations.of(context).painRestTipModerate;
    } else {
      return AppLocalizations.of(context).painRestTipSevere;
    }
  }

  Widget _buildReplacingView(
    BuildContext context,
    WorkoutExerciseReplacing state,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).painReplacingTitle),
      ),
      body: Center(
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
                AppLocalizations.of(context).painReplacingText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).painReplacingText,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(
                  context,
                ).painReplacingArea(state.painLocation),
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseImage(BuildContext context, WorkoutExercise exercise) {
    final resolvedVideo = _resolveExerciseVideo(exercise);
    final displayName = _localizedExerciseName(context, exercise);
    if (resolvedVideo.kind != ExerciseVideoKind.unsupported) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ExerciseVideoPlayer(
            resolvedVideo: resolvedVideo,
            onFullscreenTap: () =>
                _openFullscreenVideo(context, displayName, resolvedVideo),
            onOpenSearchTap: () =>
                _openSearchVideo(context, displayName, resolvedVideo),
          ),
        ),
      );
    }

    final imageUrl = Exercise.sanitizeImageUrl(exercise.imageUrl);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: 190,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage(context, exercise);
          },
        ),
      );
    }

    if (exercise.mediaType == ExerciseMediaType.lottie) {
      return _buildMediaPlaceholder(
        icon: Icons.animation,
        label: AppLocalizations.of(context).workoutPlayerAnimation,
        color: Colors.teal,
      );
    }

    // Show categorized placeholder
    return _buildPlaceholderImage(context, exercise);
  }

  ResolvedExerciseVideo _resolveExerciseVideo(WorkoutExercise exercise) {
    return ExerciseVideoResolver.resolve(exercise.videoUrl, exercise.mediaType);
  }

  String _localizedExerciseName(
    BuildContext context,
    WorkoutExercise exercise,
  ) {
    return ExerciseLocalizationUtils.localizedExerciseName(
      Localizations.localeOf(context).languageCode,
      rawName: exercise.name,
      exerciseId: exercise.exerciseId,
    );
  }

  void _openFullscreenVideo(
    BuildContext context,
    String exerciseTitle,
    ResolvedExerciseVideo resolvedVideo,
  ) {
    if (!resolvedVideo.isPlayable &&
        resolvedVideo.kind != ExerciseVideoKind.youtubeSearch) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExerciseVideoFullscreenPage(
          title: exerciseTitle,
          resolvedVideo: resolvedVideo,
        ),
      ),
    );
  }

  void _openSearchVideo(
    BuildContext context,
    String exerciseTitle,
    ResolvedExerciseVideo resolvedVideo,
  ) {
    final url = resolvedVideo.normalizedUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).workoutPlayerSearchUnavailable,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ExerciseSearchWebViewPage(url: url, title: exerciseTitle),
      ),
    );
  }

  Widget _buildMediaPlaceholder({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(
    BuildContext context,
    WorkoutExercise exercise,
  ) {
    final icon = _getExerciseIcon(exercise);
    final color = _getExerciseColor(exercise);

    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 8),
          Text(
            _getExerciseCategory(context, exercise),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getExerciseColor(WorkoutExercise exercise) {
    final muscles = _normalizedMuscles(exercise);
    if (_containsAny(muscles, const [
      'back',
      'спин',
      'арқа',
      'upper_back',
      'lower_back',
    ])) {
      return Colors.blue;
    }
    if (_containsAny(muscles, const [
      'leg',
      'ног',
      'аяқ',
      'knee',
      'бедр',
      'жамбас',
      'glute',
    ])) {
      return Colors.green;
    }
    if (_containsAny(muscles, const [
      'arm',
      'рук',
      'қол',
      'shoulder',
      'плеч',
      'bicep',
      'tricep',
    ])) {
      return Colors.orange;
    }
    if (_containsAny(muscles, const ['core', 'кор', 'пресс', 'abs', 'іш'])) {
      return Colors.purple;
    }
    return AppColors.primary;
  }

  String _getExerciseCategory(BuildContext context, WorkoutExercise exercise) {
    final muscles = _normalizedMuscles(exercise);
    if (_containsAny(muscles, const [
      'back',
      'спин',
      'арқа',
      'upper_back',
      'lower_back',
    ])) {
      return AppLocalizations.of(context).categoryBack;
    }
    if (_containsAny(muscles, const [
      'leg',
      'ног',
      'аяқ',
      'knee',
      'бедр',
      'жамбас',
      'glute',
    ])) {
      return AppLocalizations.of(context).categoryLegs;
    }
    if (_containsAny(muscles, const [
      'arm',
      'рук',
      'қол',
      'shoulder',
      'плеч',
      'bicep',
      'tricep',
    ])) {
      return AppLocalizations.of(context).categoryArms;
    }
    if (_containsAny(muscles, const ['core', 'кор', 'пресс', 'abs', 'іш'])) {
      return AppLocalizations.of(context).categoryCore;
    }
    if (_containsAny(muscles, const ['neck', 'шея', 'мойын'])) {
      return AppLocalizations.of(context).categoryNeck;
    }
    return AppLocalizations.of(context).categoryGeneral;
  }

  IconData _getExerciseIcon(WorkoutExercise exercise) {
    final muscles = _normalizedMuscles(exercise);
    if (_containsAny(muscles, const [
      'back',
      'спин',
      'арқа',
      'upper_back',
      'lower_back',
    ])) {
      return Icons.accessibility_new;
    }
    if (_containsAny(muscles, const [
      'leg',
      'ног',
      'аяқ',
      'knee',
      'бедр',
      'жамбас',
      'glute',
    ])) {
      return Icons.directions_walk;
    }
    if (_containsAny(muscles, const [
      'arm',
      'рук',
      'қол',
      'shoulder',
      'плеч',
      'bicep',
      'tricep',
    ])) {
      return Icons.fitness_center;
    }
    return Icons.self_improvement;
  }

  String _normalizedMuscles(WorkoutExercise exercise) {
    return exercise.targetMuscles.join(' ').toLowerCase();
  }

  bool _containsAny(String value, List<String> candidates) {
    for (final candidate in candidates) {
      if (value.contains(candidate)) {
        return true;
      }
    }
    return false;
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _showExitConfirmation(BuildContext context) async {
    final canPop = context.canPop();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('workout_exit_confirmation_dialog'),
        title: Text(AppLocalizations.of(context).workoutPlayerExitTitle),
        content: Text(AppLocalizations.of(context).workoutPlayerExitMessage),
        actions: [
          TextButton(
            key: const Key('workout_exit_cancel_button'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context).workoutPlayerExitCancel),
          ),
          ElevatedButton(
            key: const Key('workout_exit_confirm_button'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<WorkoutCubit>().cancelWorkout();
              if (canPop) {
                context.pop();
                return;
              }
              context.goToTabBranch(AppTabBranch.home);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context).workoutPlayerExitConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _showCompletionDialog(
    BuildContext context,
    WorkoutCompleted initialState,
  ) async {
    final workoutCubit = context.read<WorkoutCubit>();
    final minutes = initialState.totalDurationSeconds ~/ 60;
    final canPop = context.canPop();
    final l10n = AppLocalizations.of(context);
    final localizedWorkoutTitle =
        WorkoutLocalizationUtils.localizedWorkoutTitle(
          l10n: l10n,
          localeCode: Localizations.localeOf(context).languageCode,
          type: initialState.workout.type,
          rawTitle: initialState.workout.title,
          sourceLanguageCode:
              initialState.workout.aiMetadata?['language_code'] as String?,
        );
    var showAllTips = false;
    var showAllRecoverySteps = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: workoutCubit,
        child: BlocBuilder<WorkoutCubit, WorkoutState>(
          builder: (context, state) {
            PostWorkoutFeedback? feedback;
            if (state is WorkoutCompleted) {
              feedback = state.feedback;
            }

            final mediaQuery = MediaQuery.of(dialogContext);
            final isCompact =
                mediaQuery.size.height < 760 || mediaQuery.size.width < 380;
            final summaryMaxLines = isCompact ? 3 : 5;
            final encouragementMaxLines = isCompact ? 2 : 3;
            final visibleTipsCount = isCompact ? 2 : 4;

            return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                insetPadding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 16 : 24,
                  vertical: isCompact ? 14 : 24,
                ),
                title: Row(
                  children: [
                    const Icon(Icons.celebration, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context).completionTitle),
                  ],
                ),
                content: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        mediaQuery.size.height * (isCompact ? 0.62 : 0.7),
                  ),
                  child: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: isCompact ? 54 : 64,
                            color: AppColors.success,
                          ),
                          SizedBox(height: isCompact ? 12 : 16),
                          Text(
                            localizedWorkoutTitle,
                            style: TextStyle(
                              fontSize: isCompact ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isCompact ? 12 : 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildStatChip(
                                Icons.timer,
                                AppLocalizations.of(
                                  context,
                                ).completionMinutes(minutes),
                                compact: isCompact,
                              ),
                              _buildStatChip(
                                Icons.fitness_center,
                                AppLocalizations.of(
                                  context,
                                ).completionExercises(
                                  initialState.workout.totalExercises,
                                ),
                                compact: isCompact,
                              ),
                            ],
                          ),
                          if (initialState.painReportsCount > 0) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.warning,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).completionPainReports(
                                      initialState.painReportsCount,
                                    ),
                                    style: const TextStyle(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Divider(height: isCompact ? 24 : 32),

                          if (feedback == null)
                            Column(
                              children: [
                                const SizedBox(height: 8),
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).completionAnalyzing,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feedback.title,
                                  style: TextStyle(
                                    fontSize: isCompact ? 15 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  feedback.summary,
                                  maxLines: summaryMaxLines,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                if (feedback.tips.isNotEmpty) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.15),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.tips_and_updates_rounded,
                                              color: AppColors.primary,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              ).completionTips(
                                                feedback.tips.length,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ...feedback.tips
                                            .take(
                                              showAllTips
                                                  ? feedback.tips.length
                                                  : visibleTipsCount,
                                            )
                                            .map(
                                              (tip) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 6,
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                        top: 6,
                                                      ),
                                                      child: Icon(
                                                        Icons.circle,
                                                        size: 6,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        tip,
                                                        style: TextStyle(
                                                          fontSize: isCompact
                                                              ? 12
                                                              : 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        if (feedback.tips.length >
                                            visibleTipsCount)
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  showAllTips = !showAllTips;
                                                });
                                              },
                                              child: Text(
                                                showAllTips
                                                    ? AppLocalizations.of(
                                                        context,
                                                      ).completionCollapse
                                                    : AppLocalizations.of(
                                                        context,
                                                      ).completionShowAll,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.psychology,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          feedback.encouragement,
                                          maxLines: encouragementMaxLines,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.italic,
                                            fontSize: isCompact ? 13 : 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (feedback.recoveryPlan != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue.withValues(
                                          alpha: 0.18,
                                        ),
                                      ),
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        tilePadding: EdgeInsets.zero,
                                        childrenPadding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        iconColor: Colors.indigo,
                                        collapsedIconColor: Colors.indigo,
                                        leading: const Icon(
                                          Icons.restore,
                                          color: Colors.indigo,
                                        ),
                                        title: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).completionRecoveryPlan,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Text(
                                          isCompact
                                              ? AppLocalizations.of(
                                                  context,
                                                ).completionRecoveryBrief
                                              : AppLocalizations.of(
                                                  context,
                                                ).completionRecoveryExpand,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        children: [
                                          _buildRecoveryPlanSection(
                                            context,
                                            feedback.recoveryPlan!,
                                            compact: isCompact,
                                            showAllSteps: showAllRecoverySteps,
                                            onToggleSteps: () {
                                              setState(() {
                                                showAllRecoverySteps =
                                                    !showAllRecoverySteps;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        workoutCubit.reset();
                        if (canPop) {
                          context.pop();
                          return;
                        }
                        context.goToTabBranch(AppTabBranch.home);
                      },
                      child: Text(
                        AppLocalizations.of(context).completionGoHome,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecoveryPlanSection(
    BuildContext context,
    RecoveryPlan plan, {
    bool compact = false,
    bool showAllSteps = false,
    VoidCallback? onToggleSteps,
  }) {
    final visibleSteps = compact && !showAllSteps ? 3 : plan.steps.length;
    final displayedSteps = plan.steps.take(visibleSteps).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.indigo.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.indigo.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: Colors.indigo, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).completionRestDuration(plan.restDuration),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        ...displayedSteps.map(
          (step) => _buildRecoveryStepCard(step, compact: compact),
        ),

        if (compact && plan.steps.length > 3 && onToggleSteps != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onToggleSteps,
              child: Text(
                showAllSteps
                    ? AppLocalizations.of(context).completionHideSteps
                    : AppLocalizations.of(
                        context,
                      ).completionMoreSteps(plan.steps.length - 3),
              ),
            ),
          ),

        const SizedBox(height: 8),
        _buildRecoveryTipCard(
          icon: '\uD83E\uDD57',
          title: AppLocalizations.of(context).completionNutrition,
          description: plan.nutritionTip,
          color: Colors.green,
          compact: compact,
        ),

        const SizedBox(height: 8),
        _buildRecoveryTipCard(
          icon: '\uD83D\uDE34',
          title: AppLocalizations.of(context).completionSleep,
          description: plan.sleepTip,
          color: Colors.deepPurple,
          compact: compact,
        ),
      ],
    );
  }

  Widget _buildRecoveryStepCard(RecoveryStep step, {bool compact = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.icon, style: TextStyle(fontSize: compact ? 20 : 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 12 : 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.description,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (!compact && step.timing != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '\u23F0 ${step.timing}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryTipCard({
    required String icon,
    required String title,
    required String description,
    required Color color,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 12 : 13,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: AppColors.primary),
          SizedBox(width: compact ? 5 : 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: compact ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

enum _WorkoutModalType { aiInsight, exit, completion }

class _WorkoutRestCountdown extends StatefulWidget {
  const _WorkoutRestCountdown({
    required this.restStartedAtEpochMs,
    required this.restDurationSeconds,
  });

  final int restStartedAtEpochMs;
  final int restDurationSeconds;

  @override
  State<_WorkoutRestCountdown> createState() => _WorkoutRestCountdownState();
}

class _WorkoutRestCountdownState extends State<_WorkoutRestCountdown> {
  Timer? _ticker;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _computeRemaining();
    _startTicker();
  }

  @override
  void didUpdateWidget(covariant _WorkoutRestCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restStartedAtEpochMs != widget.restStartedAtEpochMs ||
        oldWidget.restDurationSeconds != widget.restDurationSeconds) {
      _remainingSeconds = _computeRemaining();
      _startTicker();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final nextRemaining = _computeRemaining();
      if (nextRemaining != _remainingSeconds) {
        setState(() => _remainingSeconds = nextRemaining);
      }
      if (nextRemaining <= 0) {
        _ticker?.cancel();
      }
    });
  }

  int _computeRemaining() {
    final duration = widget.restDurationSeconds;
    if (duration <= 0) return 0;

    final startedAt = widget.restStartedAtEpochMs;
    if (startedAt <= 0) return duration;

    final elapsed = (DateTime.now().millisecondsSinceEpoch - startedAt) ~/ 1000;
    final clampedElapsed = elapsed.clamp(0, duration);
    return (duration - clampedElapsed).clamp(0, duration);
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.restDurationSeconds > 0
        ? widget.restDurationSeconds
        : 1;
    final progress = 1 - (_remainingSeconds / duration);

    return Column(
      children: [
        Text(
          AppLocalizations.of(
            context,
          ).workoutPlayerRestSeconds(_remainingSeconds),
          style: const TextStyle(
            fontSize: 20,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.primary.withValues(alpha: 0.16),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _WorkoutPainRestCountdown extends StatefulWidget {
  const _WorkoutPainRestCountdown({
    required this.restStartedAtEpochMs,
    required this.restDurationSeconds,
  });

  final int restStartedAtEpochMs;
  final int restDurationSeconds;

  @override
  State<_WorkoutPainRestCountdown> createState() =>
      _WorkoutPainRestCountdownState();
}

class _WorkoutPainRestCountdownState extends State<_WorkoutPainRestCountdown> {
  Timer? _ticker;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _computeRemaining();
    _startTicker();
  }

  @override
  void didUpdateWidget(covariant _WorkoutPainRestCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restStartedAtEpochMs != widget.restStartedAtEpochMs ||
        oldWidget.restDurationSeconds != widget.restDurationSeconds) {
      _remainingSeconds = _computeRemaining();
      _startTicker();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final nextRemaining = _computeRemaining();
      if (nextRemaining != _remainingSeconds) {
        setState(() => _remainingSeconds = nextRemaining);
      }
      if (nextRemaining <= 0) {
        _ticker?.cancel();
      }
    });
  }

  int _computeRemaining() {
    final duration = widget.restDurationSeconds;
    if (duration <= 0) return 0;

    final startedAt = widget.restStartedAtEpochMs;
    if (startedAt <= 0) return duration;

    final elapsed = (DateTime.now().millisecondsSinceEpoch - startedAt) ~/ 1000;
    final clampedElapsed = elapsed.clamp(0, duration);
    return (duration - clampedElapsed).clamp(0, duration);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.restDurationSeconds > 0
        ? widget.restDurationSeconds
        : 1;
    final progress = 1 - (_remainingSeconds / total);
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 12,
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Text(
              AppLocalizations.of(context).painRestRemaining,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LocalizedAiInsightText extends StatefulWidget {
  const _LocalizedAiInsightText({
    required this.exercise,
    this.sourceLanguageCode,
    this.maxLines,
    this.style,
  });

  final WorkoutExercise exercise;
  final String? sourceLanguageCode;
  final int? maxLines;
  final TextStyle? style;

  @override
  State<_LocalizedAiInsightText> createState() =>
      _LocalizedAiInsightTextState();
}

class _LocalizedAiInsightTextState extends State<_LocalizedAiInsightText> {
  static final Map<String, String> _localizedCache = <String, String>{};

  String? _localizedText;
  bool _isLoading = false;
  String _activeRequestKey = '';
  String _lastLocaleCode = '';

  @override
  void initState() {
    super.initState();
    // Localizations lookup must not happen in initState.
    // Initial resolve is triggered in didChangeDependencies.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = Localizations.localeOf(context).languageCode;
    if (localeCode != _lastLocaleCode) {
      _lastLocaleCode = localeCode;
      unawaited(_resolveLocalizedText());
    }
  }

  @override
  void didUpdateWidget(covariant _LocalizedAiInsightText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.description != widget.exercise.description ||
        oldWidget.exercise.name != widget.exercise.name ||
        oldWidget.exercise.exerciseId != widget.exercise.exerciseId ||
        oldWidget.sourceLanguageCode != widget.sourceLanguageCode) {
      unawaited(_resolveLocalizedText());
    }
  }

  Future<void> _resolveLocalizedText() async {
    final rawDescription = widget.exercise.description.trim();
    if (rawDescription.isEmpty) {
      if (!mounted) return;
      setState(() {
        _localizedText = null;
        _isLoading = false;
      });
      return;
    }

    final localeCode = Localizations.localeOf(context).languageCode;
    final shouldLocalize = AiTextLocalizationUtils.shouldRequestLocalization(
      text: rawDescription,
      currentLocaleCode: localeCode,
      sourceLanguageCode: widget.sourceLanguageCode,
    );

    if (!shouldLocalize) {
      if (!mounted) return;
      setState(() {
        _localizedText = rawDescription;
        _isLoading = false;
      });
      return;
    }

    final requestKey =
        '${AiTextLocalizationUtils.normalizeLanguageCode(localeCode)}|${widget.exercise.exerciseId ?? widget.exercise.name}|${rawDescription.hashCode}';

    final cached = _localizedCache[requestKey];
    if (cached != null && cached.trim().isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _localizedText = cached;
        _isLoading = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _activeRequestKey = requestKey;
      _isLoading = true;
      _localizedText = null;
    });

    try {
      final localized = await context.read<WorkoutCubit>().explainExercise(
        widget.exercise.name,
        rawDescription,
        languageCode: localeCode,
      );

      if (!mounted || _activeRequestKey != requestKey) return;
      final normalized = localized.trim();
      if (normalized.isNotEmpty) {
        _localizedCache[requestKey] = normalized;
      }

      setState(() {
        _localizedText = normalized.isEmpty ? null : normalized;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || _activeRequestKey != requestKey) return;
      setState(() {
        _localizedText = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rawDescription = widget.exercise.description.trim();

    String visibleText;
    if (rawDescription.isEmpty) {
      visibleText = l10n.workoutPlayerNoDescription;
    } else if (_isLoading) {
      visibleText = l10n.workoutPlayerAiLocalizedPending;
    } else {
      final localeCode = Localizations.localeOf(context).languageCode;
      final mismatch = AiTextLocalizationUtils.shouldRequestLocalization(
        text: rawDescription,
        currentLocaleCode: localeCode,
        sourceLanguageCode: widget.sourceLanguageCode,
      );

      if (mismatch) {
        visibleText =
            _localizedText ?? l10n.workoutPlayerAiLocalizedUnavailable;
      } else {
        visibleText = _localizedText ?? rawDescription;
      }
    }

    return Text(
      visibleText,
      maxLines: widget.maxLines,
      overflow: widget.maxLines != null ? TextOverflow.ellipsis : null,
      style: widget.style,
    );
  }
}

/// A self-contained timer display widget that updates every second
/// using its own [dart:async] [Timer], without touching the bloc stream.
///
/// This widget only rebuilds itself (via [setState]) — the rest of the
/// [WorkoutPlayerPage] is completely unaffected by timer ticks.
class _WorkoutTimerDisplay extends StatefulWidget {
  const _WorkoutTimerDisplay({required this.formatTime});

  final String Function(int seconds) formatTime;

  @override
  State<_WorkoutTimerDisplay> createState() => _WorkoutTimerDisplayState();
}

class _WorkoutTimerDisplayState extends State<_WorkoutTimerDisplay> {
  Timer? _localTimer;
  int _displayedSeconds = 0;

  @override
  void initState() {
    super.initState();
    // Sync initial value from cubit
    final cubit = context.read<WorkoutCubit>();
    _displayedSeconds = cubit.getElapsedSeconds();
    // Update only this widget every second
    _localTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final elapsed = context.read<WorkoutCubit>().getElapsedSeconds();
      if (mounted && elapsed != _displayedSeconds) {
        setState(() => _displayedSeconds = elapsed);
      }
    });
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parts = widget.formatTime(_displayedSeconds).split(':');
    final minutes = parts.first;
    final seconds = parts.last;
    return Row(
      children: [
        Expanded(
          child: _buildCell(
            minutes,
            AppLocalizations.of(context).workoutPlayerMinutes.toUpperCase(),
          ),
        ),
        Container(
          width: 1,
          height: 42,
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
        Expanded(
          child: _buildCell(
            seconds,
            AppLocalizations.of(context).workoutPlayerSeconds.toUpperCase(),
          ),
        ),
      ],
    );
  }

  Widget _buildCell(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
