import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/workout_model.dart';
import '../../blocs/workout/workout_cubit.dart';
import '../../widgets/video/exercise_video_resolver.dart';

/// Page to preview the generated workout before starting
class WorkoutPreviewPage extends StatelessWidget {
  const WorkoutPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listener: (context, state) {
        if (state is WorkoutInProgress) {
          context.go(AppRoutes.workoutPlayer);
        }
      },
      builder: (context, state) {
        if (state is! WorkoutReady) {
          return Scaffold(
            appBar: AppBar(title: const Text('Тренировка')),
            body: const Center(child: Text('Тренировка не найдена')),
          );
        }

        final workout = state.workout;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ваша тренировка'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(AppRoutes.home),
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
                            'Разминка',
                            Icons.whatshot,
                            AppColors.warning,
                          ),
                          const SizedBox(height: 12),
                          ...workout.warmup.map((e) => _buildExerciseCard(e)),
                          const SizedBox(height: 24),
                        ],

                        // Main Exercises
                        _buildSectionHeader(
                          'Основные упражнения',
                          Icons.fitness_center,
                          AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        ...workout.mainExercises.map(
                          (e) => _buildExerciseCard(e),
                        ),
                        const SizedBox(height: 24),

                        // Cooldown Section
                        if (workout.cooldown.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Заминка',
                            Icons.self_improvement,
                            AppColors.info,
                          ),
                          const SizedBox(height: 12),
                          ...workout.cooldown.map((e) => _buildExerciseCard(e)),
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
                      child: const Text(
                        'Начать тренировку',
                        style: TextStyle(
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
        );
      },
    );
  }

  Widget _buildWorkoutHeader(BuildContext context, Workout workout) {
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
            workout.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.timer, '${workout.estimatedDuration} мин'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.flash_on, workout.intensity),
              const SizedBox(width: 12),
              _buildInfoChip(
                Icons.format_list_numbered,
                '${workout.totalExercises} упр.',
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

  Widget _buildExerciseCard(WorkoutExercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildLeadingVisual(exercise),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          exercise.displayFormat,
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
