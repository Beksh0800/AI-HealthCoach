import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/daily_checkin_model.dart';
import '../../blocs/checkin/checkin_cubit.dart';

/// Daily check-in page - collects current health status
class CheckInPage extends StatefulWidget {
  final String? initialWorkoutType;

  const CheckInPage({super.key, this.initialWorkoutType});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  @override
  void initState() {
    super.initState();
    context.read<CheckInCubit>().checkTodayStatus();
  }

  @override
  Widget build(BuildContext context) {
    return _CheckInPageContent(initialWorkoutType: widget.initialWorkoutType);
  }
}

class _CheckInPageContent extends StatelessWidget {
  final String? initialWorkoutType;

  const _CheckInPageContent({this.initialWorkoutType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Как ты себя чувствуешь?'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: BlocConsumer<CheckInCubit, CheckInState>(
        listener: (context, state) {
          if (state is CheckInCompleted) {
            // Navigate to workout generation
            context.go(AppRoutes.workout, extra: initialWorkoutType);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.checkIn.isWorkoutRecommended
                      ? 'Готово! Рекомендуемая интенсивность: ${state.checkIn.suggestedIntensity}'
                      : 'Сегодня лучше отдохнуть 🛌',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CheckInLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CheckInAlreadyCompleted) {
            return _buildAlreadyCompletedView(context, state.checkIn);
          }

          if (state is CheckInInProgress) {
            return _buildCheckInForm(context, state);
          }

          if (state is CheckInError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CheckInCubit>().startCheckIn(),
                    child: const Text('Попробовать снова'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildAlreadyCompletedView(BuildContext context, DailyCheckIn checkIn) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: AppColors.success),
            const SizedBox(height: 24),
            const Text(
              'Опрос уже пройден сегодня!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Уровень боли',
                      '${checkIn.painLevel}/10',
                      Icons.healing,
                    ),
                    _buildInfoRow(
                      'Энергия',
                      '${checkIn.energyLevel}/5',
                      Icons.bolt,
                    ),
                    _buildInfoRow(
                      'Сон',
                      '${checkIn.sleepQuality}/5',
                      Icons.bedtime,
                    ),
                    _buildInfoRow(
                      'Настроение',
                      CheckInConstants.moodLabels[checkIn.mood] ?? checkIn.mood,
                      Icons.mood,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      'Рекомендация',
                      checkIn.suggestedIntensity,
                      Icons.fitness_center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.workout, extra: initialWorkoutType),
              child: const Text('К тренировке'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.read<CheckInCubit>().startCheckIn(),
              child: const Text('Пройти снова'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInForm(BuildContext context, CheckInInProgress state) {
    return SafeArea(
      child: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= state.currentStep
                          ? AppColors.primary
                          : AppColors.primaryLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(context, state),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (state.currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.read<CheckInCubit>().previousStep(),
                      child: const Text('Назад'),
                    ),
                  ),
                if (state.currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (state.currentStep == 3) {
                        context.read<CheckInCubit>().submitCheckIn();
                      } else {
                        context.read<CheckInCubit>().nextStep();
                      }
                    },
                    child: Text(state.currentStep == 3 ? 'Завершить' : 'Далее'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, CheckInInProgress state) {
    switch (state.currentStep) {
      case 0:
        return _buildPainStep(context, state);
      case 1:
        return _buildEnergyStep(context, state);
      case 2:
        return _buildMoodStep(context, state);
      case 3:
        return _buildSymptomsStep(context, state);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPainStep(BuildContext context, CheckInInProgress state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Уровень боли',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Оцени свой текущий уровень боли от 0 до 10',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            '${state.painLevel}',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: _getPainColor(state.painLevel),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: state.painLevel.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: state.painLevel.toString(),
          activeColor: _getPainColor(state.painLevel),
          onChanged: (value) {
            context.read<CheckInCubit>().updatePainLevel(value.round());
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Нет боли', style: TextStyle(color: AppColors.textSecondary)),
            Text('Сильная боль', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        if (state.painLevel > 0) ...[
          const SizedBox(height: 32),
          const Text(
            'Где болит?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CheckInConstants.painLocations.map((location) {
              final isSelected = state.painLocation == location;
              return ChoiceChip(
                label: Text(location),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    context.read<CheckInCubit>().updatePainLocation(location);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildEnergyStep(BuildContext context, CheckInInProgress state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Уровень энергии',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Как ты оцениваешь свою энергию сегодня?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        ...List.generate(5, (index) {
          final level = index + 1;
          final isSelected = state.energyLevel == level;
          final labels = ['Очень низкий', 'Низкий', 'Средний', 'Высокий', 'Очень высокий'];
          final icons = [
            Icons.battery_0_bar,
            Icons.battery_2_bar,
            Icons.battery_4_bar,
            Icons.battery_5_bar,
            Icons.battery_full,
          ];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => context.read<CheckInCubit>().updateEnergyLevel(level),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icons[index],
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        const Text(
          'Качество сна',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final quality = index + 1;
            final isSelected = state.sleepQuality == quality;
            return GestureDetector(
              onTap: () => context.read<CheckInCubit>().updateSleepQuality(quality),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$quality',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Плохо', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('Отлично', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodStep(BuildContext context, CheckInInProgress state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Настроение',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Как ты себя чувствуешь эмоционально?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: CheckInConstants.moods.map((mood) {
            final isSelected = state.mood == mood;
            final label = CheckInConstants.moodLabels[mood] ?? mood;
            final emoji = CheckInConstants.moodEmojis[mood] ?? '😐';

            return GestureDetector(
              onTap: () => context.read<CheckInCubit>().updateMood(mood),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      label.split(' ')[0],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomsStep(BuildContext context, CheckInInProgress state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Дополнительные симптомы',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Отметь, если есть какие-либо симптомы (необязательно)',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CheckInConstants.commonSymptoms.map((symptom) {
            final isSelected = state.symptoms.contains(symptom);
            return FilterChip(
              label: Text(symptom),
              selected: isSelected,
              onSelected: (_) => context.read<CheckInCubit>().toggleSymptom(symptom),
              selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        const Text(
          'Заметки',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Дополнительная информация (необязательно)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => context.read<CheckInCubit>().updateNotes(value.isEmpty ? null : value),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getSummaryColor(state).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getSummaryColor(state).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                _getSummaryIcon(state),
                color: _getSummaryColor(state),
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Рекомендация',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getSummaryColor(state),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSummaryText(state),
                      style: TextStyle(color: _getSummaryColor(state)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPainColor(int level) {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }

  Color _getSummaryColor(CheckInInProgress state) {
    if (state.painLevel >= 7) return AppColors.error;
    if (state.painLevel >= 4 || state.energyLevel <= 2) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getSummaryIcon(CheckInInProgress state) {
    if (state.painLevel >= 7) return Icons.hotel;
    if (state.painLevel >= 4 || state.energyLevel <= 2) return Icons.self_improvement;
    return Icons.fitness_center;
  }

  String _getSummaryText(CheckInInProgress state) {
    if (state.painLevel >= 7) {
      return 'Сегодня рекомендуется отдых. Берегите себя!';
    }
    if (state.painLevel >= 4 || state.energyLevel <= 2) {
      return 'Рекомендуется легкая тренировка с акцентом на растяжку';
    }
    if (state.energyLevel >= 4 && state.painLevel <= 2) {
      return 'Отличное состояние! Можно выполнить полноценную тренировку';
    }
    return 'Рекомендуется умеренная тренировка';
  }
}
