import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/models/recovery_plan_model.dart';
import '../../../data/models/ai_feedback_models.dart';
import '../../blocs/workout/workout_cubit.dart';
import '../../widgets/video/exercise_video_player.dart';
import '../../widgets/video/exercise_video_resolver.dart';
import 'exercise_search_webview_page.dart';
import 'exercise_video_fullscreen_page.dart';

/// Page for playing/executing a workout
class WorkoutPlayerPage extends StatelessWidget {
  const WorkoutPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listener: (context, state) {
        if (state is WorkoutCompleted) {
          _showCompletionDialog(context, state);
        }
      },
      builder: (context, state) {
        if (state is WorkoutReady) {
          return _buildReadyView(context, state.workout);
        }

        if (state is WorkoutInProgress) {
          return _buildPlayerView(context, state);
        }

        if (state is WorkoutPainReported) {
          return _buildPainReportedView(context, state);
        }

        if (state is WorkoutPainRest) {
          return _buildPainRestView(context, state);
        }

        if (state is WorkoutExerciseReplacing) {
          return _buildReplacingView(context, state);
        }

        // Fallback - shouldn't happen
        return Scaffold(
          appBar: AppBar(title: const Text('Тренировка')),
          body: const Center(
            child: Text('Тренировка не найдена'),
          ),
        );
      },
    );
  }

  Widget _buildReadyView(BuildContext context, Workout workout) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Готово к старту'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<WorkoutCubit>().reset();
            context.go(AppRoutes.home);
          },
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
                            WorkoutTypes.labels[workout.type] ?? workout.type,
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
                          '~${workout.estimatedDuration} мин',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      workout.title,
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
                      _buildExerciseSection('Разминка', workout.warmup, Icons.wb_sunny),
                      const SizedBox(height: 16),
                      _buildExerciseSection('Основная часть', workout.mainExercises, Icons.fitness_center),
                      const SizedBox(height: 16),
                      _buildExerciseSection('Заминка', workout.cooldown, Icons.nightlight),
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
                  label: const Text('Начать тренировку'),
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

  Widget _buildExerciseSection(String title, List<WorkoutExercise> exercises, IconData icon) {
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...exercises.asMap().entries.map((entry) {
          final exercise = entry.value;
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
              title: Text(exercise.name),
              subtitle: Text(exercise.displayFormat),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('${state.currentExerciseIndex + 1}/${state.totalExercises}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _formatTime(state.elapsedSeconds),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: state.progress,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),

            Expanded(
              child: isResting
                  ? _buildRestView(context, exercise)
                  : _buildExerciseView(context, state, exercise),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseView(
    BuildContext context,
    WorkoutInProgress state,
    WorkoutExercise exercise,
  ) {
    final resolvedVideo = _resolveExerciseVideo(exercise);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Exercise info
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Exercise image or icon
                  _buildExerciseImage(context, exercise),
                  const SizedBox(height: 24),

                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Подход ${state.currentSet}/${exercise.sets} • ${exercise.displayFormat.split('x').last.trim()}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    exercise.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (resolvedVideo.kind != ExerciseVideoKind.unsupported) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _openVideoByKind(
                        context,
                        exercise,
                        resolvedVideo,
                      ),
                      icon: Icon(
                        resolvedVideo.kind == ExerciseVideoKind.youtubeSearch
                            ? Icons.travel_explore
                            : Icons.play_circle_outline,
                      ),
                      label: Text(
                        resolvedVideo.kind == ExerciseVideoKind.youtubeSearch
                            ? 'Открыть поиск'
                            : 'Смотреть видео',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Instructions
                  if (exercise.instructions.isNotEmpty) ...[
                    const Text(
                      'Инструкция:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...exercise.instructions.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key + 1}. ',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(entry.value),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),

          // Pain button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.read<WorkoutCubit>().reportPain(),
              icon: const Icon(Icons.warning_amber, color: Colors.white),
              label: const Text(
                'МНЕ БОЛЬНО',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shadowColor: AppColors.error.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              if (state.currentExerciseIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.read<WorkoutCubit>().previousExercise(),
                    child: const Text('Назад'),
                  ),
                ),
              if (state.currentExerciseIndex > 0) const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => context.read<WorkoutCubit>().completeSet(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    state.isLastSet && state.isLastExercise
                        ? 'Завершить'
                        : state.isLastSet
                            ? 'Следующее'
                            : 'Готово',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.read<WorkoutCubit>().skipExercise(),
            child: const Text('Пропустить упражнение'),
          ),
        ],
      ),
    );
  }

  Widget _buildRestView(BuildContext context, WorkoutExercise exercise) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pause_circle_filled,
            size: 80,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 24),
          const Text(
            'Отдых',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${exercise.restSeconds} секунд',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Следующий подход: ${exercise.name}',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => context.read<WorkoutCubit>().finishRest(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: const Text('Продолжить'),
          ),
        ],
      ),
    );
  }

  // === Pain and replacement states ===

  Widget _buildPainReportedView(BuildContext context, WorkoutPainReported state) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPainStepTitle(state.step)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (state.step == PainFlowStep.location) {
              context.read<WorkoutCubit>().cancelPainReport();
            } else {
              context.read<WorkoutCubit>().painFlowBack();
            }
          },
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

  String _getPainStepTitle(PainFlowStep step) {
    switch (step) {
      case PainFlowStep.location:
        return 'Где болит?';
      case PainFlowStep.intensity:
        return 'Насколько больно?';
      case PainFlowStep.action:
        return 'Что делаем?';
    }
  }

  Widget _buildPainStepContent(BuildContext context, WorkoutPainReported state) {
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
        const Icon(
          Icons.health_and_safety,
          size: 80,
          color: AppColors.warning,
        ),
        const SizedBox(height: 24),
        const Text(
          'Выберите область боли',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Текущее упражнение: ${state.currentExercise.name}',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
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
              _buildPainLocationButton(context, 'Спина (поясница)', Icons.airline_seat_flat),
              _buildPainLocationButton(context, 'Спина (верх)', Icons.accessibility),
              _buildPainLocationButton(context, 'Шея', Icons.face),
              _buildPainLocationButton(context, 'Колени', Icons.directions_walk),
              _buildPainLocationButton(context, 'Плечи', Icons.fitness_center),
              _buildPainLocationButton(context, 'Запястья', Icons.pan_tool),
              _buildPainLocationButton(context, 'Голеностоп', Icons.directions_run),
              _buildPainLocationButton(context, 'Таз/бедра', Icons.airline_seat_legroom_extra),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.read<WorkoutCubit>().cancelPainReport(),
          child: const Text('Отмена, продолжить упражнение'),
        ),
      ],
    );
  }

  // Step 2: Intensity selection
  Widget _buildIntensityStep(BuildContext context, WorkoutPainReported state) {
    return Column(
      children: [
        Text(
          'Область: ${state.painLocation}',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Оцените интенсивность боли',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView(
            children: [
              _buildIntensityOption(context, 1, '😊', 'Лёгкий дискомфорт', 'Почти не мешает', Colors.green),
              _buildIntensityOption(context, 2, '🙂', 'Слабая боль', 'Терпимо', Colors.green),
              _buildIntensityOption(context, 3, '😐', 'Небольшая боль', 'Заметно, но можно продолжать', Colors.green),
              const Divider(height: 24),
              _buildIntensityOption(context, 4, '😕', 'Умеренная боль', 'Мешает концентрации', Colors.orange),
              _buildIntensityOption(context, 5, '😟', 'Средняя боль', 'Нужно изменить технику', Colors.orange),
              _buildIntensityOption(context, 6, '😣', 'Заметная боль', 'Сложно продолжать', Colors.orange),
              const Divider(height: 24),
              _buildIntensityOption(context, 7, '😖', 'Сильная боль', 'Требуется перерыв', Colors.red),
              _buildIntensityOption(context, 8, '😫', 'Очень сильная', 'Лучше остановиться', Colors.red),
              _buildIntensityOption(context, 9, '🤕', 'Острая боль', 'Нужен отдых', Colors.red),
              _buildIntensityOption(context, 10, '🚨', 'Невыносимая', 'Необходим врач', Colors.red.shade900),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntensityOption(BuildContext context, int level, String emoji, String title, String subtitle, Color color) {
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        _buildPainSummaryCard(state),
        const SizedBox(height: 24),
        Text(
          _getActionTitle(category),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getActionSubtitle(category),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
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

  Widget _buildPainSummaryCard(WorkoutPainReported state) {
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
                  '${state.painLocation}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Уровень боли: ${state.painIntensity}/10',
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
      case 'light': return Colors.green;
      case 'moderate': return Colors.orange;
      case 'severe': return Colors.red;
      default: return AppColors.textSecondary;
    }
  }

  String _getActionTitle(String category) {
    switch (category) {
      case 'light': return 'Что вы хотите сделать?';
      case 'moderate': return 'Рекомендуем осторожность';
      case 'severe': return '⚠️ Требуется отдых';
      default: return 'Выберите действие';
    }
  }

  String _getActionSubtitle(String category) {
    switch (category) {
      case 'light': return 'Лёгкий дискомфорт — можно продолжить';
      case 'moderate': return 'Рекомендуем заменить упражнение или отдохнуть';
      case 'severe': return 'При сильной боли лучше прекратить или отдохнуть';
      default: return '';
    }
  }

  List<Widget> _buildActionOptions(BuildContext context, WorkoutPainReported state, String category) {
    final cubit = context.read<WorkoutCubit>();
    
    switch (category) {
      case 'light':
        return [
          _buildActionButton(
            context,
            icon: Icons.play_arrow,
            title: 'Продолжить упражнение',
            subtitle: 'Боль терпимая, продолжаю',
            color: Colors.green,
            onTap: () => cubit.continueAfterPainAssessment(),
          ),
          _buildActionButton(
            context,
            icon: Icons.swap_horiz,
            title: 'Заменить упражнение',
            subtitle: 'AI подберёт безопасную альтернативу',
            color: Colors.blue,
            onTap: () => cubit.replaceExerciseAfterPainAssessment(),
          ),
          _buildActionButton(
            context,
            icon: Icons.timer,
            title: 'Перерыв 2 минуты',
            subtitle: 'Короткий отдых',
            color: Colors.orange,
            onTap: () => cubit.takePainRest(120),
          ),
        ];
      case 'moderate':
        return [
          _buildActionButton(
            context,
            icon: Icons.swap_horiz,
            title: 'Заменить упражнение',
            subtitle: 'Рекомендуется при умеренной боли',
            color: Colors.blue,
            onTap: () => cubit.replaceExerciseAfterPainAssessment(),
          ),
          _buildActionButton(
            context,
            icon: Icons.timer,
            title: 'Перерыв 5 минут',
            subtitle: 'Отдохните и прислушайтесь к телу',
            color: Colors.orange,
            onTap: () => cubit.takePainRest(300),
          ),
          _buildActionButton(
            context,
            icon: Icons.stop,
            title: 'Закончить тренировку',
            subtitle: 'Сохраним прогресс',
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
                    'При сильной боли рекомендуем обратиться к врачу',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(
            context,
            icon: Icons.timer,
            title: 'Перерыв 10 минут',
            subtitle: 'Длительный отдых с советами',
            color: Colors.orange,
            onTap: () => cubit.takePainRest(600),
          ),
          _buildActionButton(
            context,
            icon: Icons.stop,
            title: 'Закончить тренировку',
            subtitle: 'Здоровье важнее — отдохните сегодня',
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
        onTap: onTap,
      ),
    );
  }

  Widget _buildPainLocationButton(BuildContext context, String location, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () => context.read<WorkoutCubit>().selectPainLocation(location),
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
    final minutes = state.remainingSeconds ~/ 60;
    final seconds = state.remainingSeconds % 60;
    final progress = 1 - (state.remainingSeconds / state.restDurationSeconds);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Перерыв'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.read<WorkoutCubit>().cancelPainReport(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timer display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'осталось',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
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
                    const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                    const SizedBox(height: 8),
                    const Text(
                      'Советы для отдыха:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRestTip(state.painIntensity),
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
                  onPressed: () => context.read<WorkoutCubit>().finishPainRest(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Продолжить раньше'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.read<WorkoutCubit>().endWorkoutDueToPain(),
                child: const Text('Закончить тренировку'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRestTip(int painIntensity) {
    if (painIntensity <= 3) {
      return 'Делайте глубокие вдохи и выдохи.\nРасслабьте напряжённые мышцы.';
    } else if (painIntensity <= 6) {
      return 'Мягко помассируйте область боли.\nПейте воду и дышите спокойно.';
    } else {
      return 'Полностью расслабьтесь.\nЕсли боль не проходит, обратитесь к врачу.';
    }
  }

  Widget _buildReplacingView(BuildContext context, WorkoutExerciseReplacing state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подбор альтернативы'),
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
                    Icon(
                      Icons.psychology,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'AI подбирает безопасную замену',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                state.message,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Область боли: ${state.painLocation}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseImage(BuildContext context, WorkoutExercise exercise) {
    final resolvedVideo = _resolveExerciseVideo(exercise);
    if (resolvedVideo.kind != ExerciseVideoKind.unsupported) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 240,
          child: ExerciseVideoPlayer(
            resolvedVideo: resolvedVideo,
            onFullscreenTap: () => _openFullscreenVideo(
              context,
              exercise.name,
              resolvedVideo,
            ),
            onOpenSearchTap: () => _openSearchVideo(
              context,
              exercise.name,
              resolvedVideo,
            ),
          ),
        ),
      );
    }

    final imageUrl = exercise.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 200,
              height: 150,
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
            return _buildPlaceholderImage(exercise);
          },
        ),
      );
    }

    if (exercise.mediaType == ExerciseMediaType.lottie) {
      return _buildMediaPlaceholder(
        icon: Icons.animation,
        label: 'Анимация',
        color: Colors.teal,
      );
    }

    // Show categorized placeholder
    return _buildPlaceholderImage(exercise);
  }

  ResolvedExerciseVideo _resolveExerciseVideo(WorkoutExercise exercise) {
    return ExerciseVideoResolver.resolve(exercise.videoUrl, exercise.mediaType);
  }

  void _openVideoByKind(
    BuildContext context,
    WorkoutExercise exercise,
    ResolvedExerciseVideo resolvedVideo,
  ) {
    if (resolvedVideo.kind == ExerciseVideoKind.youtubeSearch) {
      _openSearchVideo(context, exercise.name, resolvedVideo);
      return;
    }
    _openFullscreenVideo(context, exercise.name, resolvedVideo);
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
        const SnackBar(content: Text('Ссылка поиска видео недоступна')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExerciseSearchWebViewPage(
          url: url,
          title: exerciseTitle,
        ),
      ),
    );
  }

  Widget _buildMediaPlaceholder({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(80),
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

  Widget _buildPlaceholderImage(WorkoutExercise exercise) {
    final icon = _getExerciseIcon(exercise);
    final color = _getExerciseColor(exercise);
    
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.3),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(80),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 8),
          Text(
            _getExerciseCategory(exercise),
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
    final muscles = exercise.targetMuscles.join(' ').toLowerCase();
    if (muscles.contains('спина') || muscles.contains('back')) return Colors.blue;
    if (muscles.contains('ног') || muscles.contains('leg')) return Colors.green;
    if (muscles.contains('рук') || muscles.contains('arm')) return Colors.orange;
    if (muscles.contains('кор') || muscles.contains('core')) return Colors.purple;
    return AppColors.primary;
  }

  String _getExerciseCategory(WorkoutExercise exercise) {
    final muscles = exercise.targetMuscles.join(' ').toLowerCase();
    if (muscles.contains('спина') || muscles.contains('back')) return 'Спина';
    if (muscles.contains('ног') || muscles.contains('leg')) return 'Ноги';
    if (muscles.contains('рук') || muscles.contains('arm')) return 'Руки';
    if (muscles.contains('кор') || muscles.contains('core')) return 'Кор';
    if (muscles.contains('шея') || muscles.contains('neck')) return 'Шея';
    return 'Общее';
  }

  IconData _getExerciseIcon(WorkoutExercise exercise) {
    if (exercise.targetMuscles.contains('спина')) return Icons.accessibility_new;
    if (exercise.targetMuscles.contains('ноги')) return Icons.directions_walk;
    if (exercise.targetMuscles.contains('руки')) return Icons.fitness_center;
    return Icons.self_improvement;
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Завершить тренировку?'),
        content: const Text('Прогресс не будет сохранён'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<WorkoutCubit>().cancelWorkout();
              context.go(AppRoutes.home);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Завершить'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, WorkoutCompleted initialState) {
    final workoutCubit = context.read<WorkoutCubit>();
    final minutes = initialState.totalDurationSeconds ~/ 60;

    showDialog(
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

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.celebration, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Отличная работа!'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        initialState.workout.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatChip(Icons.timer, '$minutes мин'),
                          _buildStatChip(Icons.fitness_center, '${initialState.workout.totalExercises} упр.'),
                        ],
                      ),
                      if (initialState.painReportsCount > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning, size: 16, color: AppColors.warning),
                              const SizedBox(width: 8),
                              Text(
                                'Жалоб на боль: ${initialState.painReportsCount}',
                                style: const TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Divider(height: 32),
                      
                      // AI Feedback Section
                      if (feedback == null)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'AI анализирует вашу тренировку...',
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(feedback.summary),
                            const SizedBox(height: 12),
                            if (feedback.tips.isNotEmpty) ...[
                              const Text(
                                'Советы:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              ...feedback.tips.map((tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• '),
                                    Expanded(child: Text(tip, style: const TextStyle(fontSize: 13))),
                                  ],
                                ),
                              )),
                            ],
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.psychology, color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      feedback.encouragement,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Recovery Plan Section
                            if (feedback.recoveryPlan != null) ...[
                              const Divider(height: 32),
                              _buildRecoveryPlanSection(feedback.recoveryPlan!),
                            ],
                          ],
                        ),
                    ],
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
                      context.go(AppRoutes.home);
                    },
                    child: const Text('На главную'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecoveryPlanSection(RecoveryPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with rest duration
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade50,
                Colors.indigo.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Column(
            children: [
              const Icon(Icons.restore, color: Colors.indigo, size: 28),
              const SizedBox(height: 4),
              const Text(
                'План восстановления',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '⏰ Отдых: ${plan.restDuration}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Recovery steps
        ...plan.steps.map((step) => _buildRecoveryStepCard(step)),

        // Nutrition tip
        const SizedBox(height: 8),
        _buildRecoveryTipCard(
          icon: '🍽️',
          title: 'Питание',
          description: plan.nutritionTip,
          color: Colors.green,
        ),

        // Sleep tip
        const SizedBox(height: 8),
        _buildRecoveryTipCard(
          icon: '😴',
          title: 'Сон',
          description: plan.sleepTip,
          color: Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildRecoveryStepCard(RecoveryStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (step.timing != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '🕐 ${step.timing}',
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
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
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
                    fontSize: 13,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label, 
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
