import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/tab_branch_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/exercise_localization_utils.dart';
import '../../../core/utils/workout_localization_utils.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/workout_model.dart';
import '../../../gen/app_localizations.dart';
import '../../blocs/workout/workout_cubit.dart';
import '../../blocs/workout/workout_flow_route_target.dart';
import '../../widgets/video/exercise_video_resolver.dart';

/// Page to preview the generated workout before starting
class WorkoutPreviewPage extends StatefulWidget {
  const WorkoutPreviewPage({super.key});

  @override
  State<WorkoutPreviewPage> createState() => _WorkoutPreviewPageState();
}

class _WorkoutPreviewPageState extends State<WorkoutPreviewPage> {
  bool _isNavigatingToPlayer = false;
  bool _isRecoveringFromInvalidState = false;

  void _handleBack(WorkoutState state, {required String source}) {
    final target = state.routeTarget;
    debugPrint(
      'WorkoutPreviewPage: back pressed from $source, state=${state.runtimeType}, target=$target',
    );

    if (target == WorkoutFlowRouteTarget.player) {
      _recoverFromInvalidState(state, source: source);
      return;
    }

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.goToTabBranch(AppTabBranch.workout, initialLocation: true);
  }

  void _recoverFromInvalidState(WorkoutState state, {required String source}) {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (!isCurrentRoute) {
      return;
    }

    if (_isRecoveringFromInvalidState) {
      return;
    }
    _isRecoveringFromInvalidState = true;

    final target = state.routeTarget;
    debugPrint(
      'WorkoutPreviewPage: state mismatch recovery from $source, state=${state.runtimeType}, navigatingTo=$target',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (target) {
        case WorkoutFlowRouteTarget.player:
          context.go(AppRoutes.workoutPlayer);
          break;
        case WorkoutFlowRouteTarget.preview:
          break;
        case WorkoutFlowRouteTarget.generation:
          context.goToTabBranch(AppTabBranch.workout, initialLocation: true);
          break;
      }
      _isRecoveringFromInvalidState = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listenWhen: (previous, current) =>
          previous is! WorkoutInProgress && current is WorkoutInProgress,
      listener: (context, state) {
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
        if (!isCurrentRoute) {
          return;
        }

        if (state is WorkoutInProgress) {
          if (_isNavigatingToPlayer) {
            debugPrint(
              'WorkoutPreviewPage: ignored duplicate navigation while push is in-flight',
            );
            return;
          }

          _isNavigatingToPlayer = true;
          debugPrint(
            'WorkoutPreviewPage: transitioning to workout player (single transition guard)',
          );
          final navigationFuture = context.push(AppRoutes.workoutPlayer);
          unawaited(
            navigationFuture.whenComplete(() {
              _isNavigatingToPlayer = false;
            }),
          );
        }
      },
      builder: (context, state) {
        if (state is! WorkoutReady) {
          _recoverFromInvalidState(state, source: 'build_fallback');
          return Scaffold(
            appBar: AppBar(title: Text(l.workoutPlayerTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final workout = state.workout;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            _handleBack(state, source: 'system');
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(l.workoutPreviewTitle),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _handleBack(state, source: 'appbar'),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Workout Header
                          _buildWorkoutHeader(context, workout),
                          const SizedBox(height: 24),

                          // Warmup Section
                          if (workout.warmup.isNotEmpty) ...[
                            _buildSectionHeader(
                              l.workoutPreviewWarmup,
                              Icons.whatshot,
                              AppColors.warning,
                            ),
                            const SizedBox(height: 12),
                            ...workout.warmup.map(
                              (e) => _buildExerciseCard(context, e),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Main Exercises
                          _buildSectionHeader(
                            l.workoutPreviewMain,
                            Icons.fitness_center,
                            AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          ...workout.mainExercises.map(
                            (e) => _buildExerciseCard(context, e),
                          ),
                          const SizedBox(height: 24),

                          // Cooldown Section
                          if (workout.cooldown.isNotEmpty) ...[
                            _buildSectionHeader(
                              l.workoutPreviewCooldown,
                              Icons.self_improvement,
                              AppColors.info,
                            ),
                            const SizedBox(height: 12),
                            ...workout.cooldown.map(
                              (e) => _buildExerciseCard(context, e),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Start Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<WorkoutCubit>().startWorkout();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          l.workoutPreviewStart,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutHeader(BuildContext context, Workout workout) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            WorkoutLocalizationUtils.localizedWorkoutTitle(
              l10n: l,
              localeCode: Localizations.localeOf(context).languageCode,
              type: workout.type,
              rawTitle: workout.title,
              sourceLanguageCode:
                  workout.aiMetadata?['language_code'] as String?,
            ),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.timer,
                      l.workoutMinutesShort(workout.estimatedDuration),
                    ),
                    _buildInfoChip(
                      Icons.flash_on,
                      WorkoutLocalizationUtils.localizedIntensity(
                        l,
                        workout.intensity,
                      ),
                    ),
                    _buildInfoChip(
                      Icons.format_list_numbered,
                      l.workoutPreviewExercises(workout.totalExercises),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (workout.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      workout.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(BuildContext context, WorkoutExercise exercise) {
    final displayName = ExerciseLocalizationUtils.localizedExerciseName(
      Localizations.localeOf(context).languageCode,
      rawName: exercise.name,
      exerciseId: exercise.exerciseId,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildLeadingVisual(exercise),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          WorkoutLocalizationUtils.localizedExerciseFormat(
            AppLocalizations.of(context),
            exercise,
          ),
          style: TextStyle(color: AppColors.textSecondary),
        ),
        trailing: _buildMediaIcon(exercise),
      ),
    );
  }

  Widget _buildLeadingVisual(WorkoutExercise exercise) {
    final thumb = _resolveThumbnail(exercise);
    if (thumb != null && thumb.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          thumb,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => _fallbackLeadingIcon(),
        ),
      );
    }
    return _fallbackLeadingIcon();
  }

  Widget _fallbackLeadingIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fitness_center, color: AppColors.primary),
    );
  }

  String? _resolveThumbnail(WorkoutExercise exercise) {
    final resolved = ExerciseVideoResolver.resolve(
      exercise.videoUrl,
      exercise.mediaType,
    );
    if (resolved.kind == ExerciseVideoKind.youtubeVideo) {
      final thumbnail = ExerciseVideoResolver.youtubeThumbnailById(
        resolved.youtubeId,
        mediumQuality: true,
      );
      if (thumbnail != null && thumbnail.isNotEmpty) {
        return thumbnail;
      }
    }
    return Exercise.sanitizeImageUrl(exercise.imageUrl);
  }

  Widget? _buildMediaIcon(WorkoutExercise exercise) {
    final resolved = ExerciseVideoResolver.resolve(
      exercise.videoUrl,
      exercise.mediaType,
    );
    if (resolved.kind == ExerciseVideoKind.youtubeVideo ||
        resolved.kind == ExerciseVideoKind.networkVideo) {
      return const Icon(Icons.play_circle, color: AppColors.primary);
    }
    if (resolved.kind == ExerciseVideoKind.youtubeSearch) {
      return const Icon(Icons.travel_explore, color: AppColors.primary);
    }
    if (exercise.mediaType == ExerciseMediaType.lottie) {
      return const Icon(Icons.animation, color: AppColors.primary);
    }
    if (Exercise.isSupportedImageUrl(exercise.imageUrl)) {
      return const Icon(Icons.image, color: AppColors.primary);
    }
    return null;
  }
}
