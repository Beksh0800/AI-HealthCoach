import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/prompt_templates.dart';
import '../../core/di/injection_container.dart';
import '../../data/models/workout_model.dart';
import '../../data/services/workout_analytics_service.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/profile/profile_cubit.dart';
import '../blocs/history/history_cubit.dart';

/// Home page - main dashboard after onboarding
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WorkoutStats? _workoutStats;
  List<String> _suggestions = [];
  bool _isLoadingAnalytics = true;
  bool _showOfflineState = false;
  Timer? _connectivityTimer;

  @override
  void initState() {
    super.initState();
    _reloadHomeData();
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  void _reloadHomeData() {
    if (!mounted) return;
    setState(() => _showOfflineState = false);
    context.read<ProfileCubit>().loadProfile();
    context.read<HistoryCubit>().loadHistory();
    _loadAnalytics();
    _syncHomeConnectionState();
  }

  bool _isProfileLoadingState(ProfileState state) {
    return state is ProfileInitial ||
        state is ProfileLoading ||
        state is ProfileUpdating;
  }

  bool _isHistoryLoadingState(HistoryState state) {
    return state is HistoryInitial || state is HistoryLoading;
  }

  bool _isHomeLoading(ProfileState profileState, HistoryState historyState) {
    return _isProfileLoadingState(profileState) ||
        _isHistoryLoadingState(historyState);
  }

  void _syncHomeConnectionState() {
    if (!mounted) return;
    final profileState = context.read<ProfileCubit>().state;
    final historyState = context.read<HistoryCubit>().state;
    final isLoading = _isHomeLoading(profileState, historyState);

    if (isLoading) {
      _scheduleOfflineCheck();
      return;
    }

    _connectivityTimer?.cancel();
    if (_showOfflineState) {
      setState(() => _showOfflineState = false);
    }

    if (profileState is ProfileError || historyState is HistoryError) {
      Future<void>.delayed(const Duration(milliseconds: 700), () async {
        if (!mounted) return;
        final hasInternet = await _hasInternetConnection();
        if (!mounted) return;
        setState(() => _showOfflineState = !hasInternet);
      });
    }
  }

  void _scheduleOfflineCheck() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final profileState = context.read<ProfileCubit>().state;
      final historyState = context.read<HistoryCubit>().state;
      if (!_isHomeLoading(profileState, historyState)) return;
      final hasInternet = await _hasInternetConnection();
      if (!mounted) return;
      if (!hasInternet) {
        setState(() => _showOfflineState = true);
      }
    });
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(height: 12),
          Text('Загружаем данные...'),
        ],
      ),
    );
  }

  Widget _buildOfflineState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 44,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            const Text(
              'Нет подключения к интернету.\nПовторите после подключения к интернету.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _reloadHomeData,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAnalytics() async {
    final auth = context.read<AuthCubit>().state;
    if (auth is AuthAuthenticated) {
      final analyticsService = sl<WorkoutAnalyticsService>();
      try {
        final stats = await analyticsService.getWorkoutStats(auth.uid);
        final suggestions = await analyticsService.getWorkoutSuggestions(
          auth.uid,
        );
        if (mounted) {
          setState(() {
            _workoutStats = stats;
            _suggestions = suggestions;
            _isLoadingAnalytics = false;
          });
          _syncHomeConnectionState();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingAnalytics = false);
          _syncHomeConnectionState();
        }
      }
    } else {
      setState(() => _isLoadingAnalytics = false);
      _syncHomeConnectionState();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Доброе утро';
    if (hour < 17) return 'Добрый день';
    return 'Добрый вечер';
  }

  // Removed: _onNavTap handled by ShellRoute

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) => _syncHomeConnectionState(),
        ),
        BlocListener<HistoryCubit, HistoryState>(
          listener: (context, state) => _syncHomeConnectionState(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI-HealthCoach'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthCubit>().signOut();
                context.go(AppRoutes.login);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              return BlocBuilder<HistoryCubit, HistoryState>(
                builder: (context, historyState) {
                  final isHomeLoading = _isHomeLoading(
                    profileState,
                    historyState,
                  );

                  if (_showOfflineState) {
                    return _buildOfflineState();
                  }

                  if (isHomeLoading) {
                    return _buildLoadingState();
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting Card with user name
                        _buildGreetingCard(context),
                        const SizedBox(height: 16),

                        // Streak & AI Recommendations Card
                        _buildStreakAndSuggestionsCard(context),
                        const SizedBox(height: 24),

                        // Quick Actions
                        Text(
                          'Быстрые действия',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),

                        // User Profile Summary
                        _buildProfileSummary(context),
                        const SizedBox(height: 24),

                        // Today's stats placeholder
                        Text(
                          'Статистика',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildStatsCard(context),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        // Removed: BottomNavigationBar handled by ShellRoute
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        String userName = 'Пользователь';
        if (state is ProfileLoaded) {
          userName = state.profile.name;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()}, $userName! 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Готов к сегодняшней тренировке?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state is ProfileLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.push(AppRoutes.checkIn);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('Начать тренировку'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSummary(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) {
          return const SizedBox.shrink();
        }

        final profile = state.profile;
        final medicalProfile = profile.medicalProfile;

        return GestureDetector(
          onTap: () => context.push(AppRoutes.profile),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Мой профиль',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildProfileRow(
                    Icons.cake,
                    'Возраст',
                    '${medicalProfile.age} лет',
                  ),
                  _buildProfileRow(
                    Icons.fitness_center,
                    'Вес',
                    '${medicalProfile.weight.toStringAsFixed(1)} кг',
                  ),
                  _buildProfileRow(
                    Icons.directions_run,
                    'Активность',
                    _localizeActivityLevel(medicalProfile.activityLevel),
                  ),
                  if (profile.goals.isNotEmpty)
                    _buildProfileRow(Icons.flag, 'Цель', profile.goals),
                  if (medicalProfile.injuries.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: medicalProfile.injuries.map((injury) {
                          return Chip(
                            label: Text(
                              injury,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: AppColors.warning.withValues(
                              alpha: 0.1,
                            ),
                            side: BorderSide(
                              color: AppColors.warning.withValues(alpha: 0.3),
                            ),
                          );
                        }).toList(),
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

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.self_improvement,
            title: 'ЛФК',
            color: AppColors.info,
            onTap: () =>
                context.push(AppRoutes.checkIn, extra: WorkoutTypes.lfk),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.accessibility_new,
            title: 'Растяжка',
            color: AppColors.secondary,
            onTap: () =>
                context.push(AppRoutes.checkIn, extra: WorkoutTypes.stretching),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.sports_gymnastics,
            title: 'Силовая',
            color: AppColors.warning,
            onTap: () =>
                context.push(AppRoutes.checkIn, extra: WorkoutTypes.strength),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        String workouts = '—';
        String minutes = '—';
        String progress = 'Старт';

        if (state is HistoryLoaded) {
          workouts = state.totalWorkouts.toString();
          minutes = state.totalMinutes.toString();
          if (state.totalWorkouts > 0) {
            progress =
                '${(state.totalWorkouts / 10 * 100).clamp(0, 100).toInt()}%';
          }
        } else if (state is HistoryLoading) {
          workouts = '...';
          minutes = '...';
        }

        return GestureDetector(
          onTap: () => context.push(AppRoutes.history),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        workouts,
                        'Тренировок',
                        Icons.fitness_center,
                      ),
                      _buildStatItem(minutes, 'Минут', Icons.timer_outlined),
                      _buildStatItem(progress, 'Прогресс', Icons.trending_up),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Нажмите для подробной статистики',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
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

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStreakAndSuggestionsCard(BuildContext context) {
    if (_isLoadingAnalytics) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  'Загружаем аналитику...',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stats = _workoutStats;
    final streak = stats?.currentStreak ?? 0;
    final streakMessage = PromptTemplates.getStreakMessage(streak);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: streak > 0
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    streak > 0 ? Icons.local_fire_department : Icons.flag,
                    color: streak > 0 ? AppColors.warning : AppColors.info,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        streak > 0 ? '$streak дней подряд' : 'Начните серию',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        streakMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Weekly progress
            if (stats != null && stats.hasWorkouts) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat(
                    '${stats.workoutsThisWeek}',
                    'на этой неделе',
                    Icons.calendar_today,
                  ),
                  _buildMiniStat(
                    '${stats.totalMinutes}',
                    'всего минут',
                    Icons.timer,
                  ),
                  _buildMiniStat(
                    '${stats.averageDurationMinutes}м',
                    'в среднем',
                    Icons.trending_up,
                  ),
                ],
              ),
            ],

            // AI Suggestions
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                '✨ AI-рекомендации',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              ...(_suggestions
                  .take(2)
                  .map(
                    (suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        suggestion,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _localizeActivityLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 'Низкая';
      case 'moderate':
        return 'Умеренная';
      case 'high':
        return 'Высокая';
      default:
        return level;
    }
  }
}
