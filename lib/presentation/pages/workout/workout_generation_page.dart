import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/workout_model.dart';
import '../../blocs/workout/workout_cubit.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../blocs/checkin/checkin_cubit.dart';

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
  State<_WorkoutGenerationContent> createState() => _WorkoutGenerationContentState();
}

class _WorkoutGenerationContentState extends State<_WorkoutGenerationContent> {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор тренировки'),
        // Leading button removed for top-level tab

      ),
      body: BlocConsumer<WorkoutCubit, WorkoutState>(
        listener: (context, state) {
          if (state is WorkoutReady) {
            context.go(AppRoutes.workoutPreview);
          }
          if (state is WorkoutInProgress) {
            // Restored session → go to player
            context.go(AppRoutes.workoutPlayer);
          }
          if (state is WorkoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
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

  Widget _buildSessionRecoveryView(BuildContext context, WorkoutSessionRecovery state) {
    final workoutLabel = WorkoutTypes.labels[state.workout.type] ?? state.workout.type;
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
                  colors: [
                    Colors.blue.shade50,
                    Colors.indigo.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.restore,
                    size: 56,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Незавершённая тренировка',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'У вас есть сохранённая тренировка',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
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
                          state.workout.title,
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
                            _buildInfoChip(Icons.timer, '$minutes мин'),
                            _buildInfoChip(Icons.format_list_numbered, '$exercisesDone/$totalExercises'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Сохранено: ${state.timeAgoText}',
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
                label: const Text(
                  'Продолжить тренировку',
                  style: TextStyle(fontSize: 16),
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
                child: const Text('Начать новую'),
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutTypeSelection(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Какую тренировку хочешь сегодня?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Выбери тип тренировки и AI создаст персональную программу',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
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
                Icon(Icons.offline_bolt, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Сохранённые тренировки',
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
    final typeLabel = WorkoutTypes.labels[workout.type] ?? workout.type;

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
          workout.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$typeLabel • ${workout.estimatedDuration} мин',
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
    final label = WorkoutTypes.labels[type] ?? type;
    final description = WorkoutTypes.descriptions[type] ?? '';

    return GestureDetector(
      onTap: () => _generateWorkout(context, type),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.8),
              color,
            ],
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
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
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
    final profileState = context.read<ProfileCubit>().state;
    final checkInState = context.read<CheckInCubit>().state;

    if (profileState is! ProfileLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль не загружен. Попробуйте позже.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (checkInState is! CheckInCompleted && checkInState is! CheckInAlreadyCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала пройдите опрос самочувствия'),
          backgroundColor: AppColors.warning,
        ),
      );
      context.go(AppRoutes.checkIn);
      return;
    }

    final checkIn = checkInState is CheckInCompleted 
        ? checkInState.checkIn 
        : (checkInState as CheckInAlreadyCompleted).checkIn;

    context.read<WorkoutCubit>().generateWorkout(
      profile: profileState.profile,
      checkIn: checkIn,
      workoutType: workoutType,
    );
  }

  Widget _buildGeneratingView(BuildContext context, WorkoutGenerating state) {
    final label = WorkoutTypes.labels[state.workoutType] ?? '';

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
                  Icon(
                    Icons.psychology,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Создаём тренировку "$label"',
              style: const TextStyle(
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
            const SizedBox(height: 48),
            TextButton(
              onPressed: () {
                context.read<WorkoutCubit>().reset();
              },
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    );
  }
}
