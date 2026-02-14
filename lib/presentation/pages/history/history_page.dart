import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/workout_history_model.dart';
import '../../blocs/history/history_cubit.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistoryCubit>()..loadHistory(),
      child: const _HistoryPageContent(),
    );
  }
}

class _HistoryPageContent extends StatefulWidget {
  const _HistoryPageContent();

  @override
  State<_HistoryPageContent> createState() => _HistoryPageContentState();
}

class _HistoryPageContentState extends State<_HistoryPageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История и Прогресс'),
        // Leading button removed for top-level tab

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<HistoryCubit>().loadHistory(),
          ),
        ],
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistoryError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }

          if (state is HistoryLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<HistoryCubit>().loadHistory(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsOverview(context, state),
                    const SizedBox(height: 24),
                    _buildChartTabs(context, state),
                    const SizedBox(height: 24),
                    if (state.typeDistribution.isNotEmpty) ...[
                      _buildTypeDistributionChart(context, state.typeDistribution),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Последние тренировки',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.history.isEmpty)
                      _buildEmptyState()
                    else
                      ...state.history.map((workout) => _buildHistoryCard(workout)),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ────────────────────── Stats Overview ──────────────────────

  Widget _buildStatsOverview(BuildContext context, HistoryLoaded state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            state.totalWorkouts.toString(),
            'Тренировок',
            Icons.fitness_center,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            state.totalMinutes.toString(),
            'Минут',
            Icons.timer,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ────────────────────── Tabs: Weekly / Monthly ──────────────────────

  Widget _buildChartTabs(BuildContext context, HistoryLoaded state) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Неделя'),
              Tab(text: 'Месяц'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBarChart(state.weeklyActivity, isWeekly: true),
              _buildLineChart(state.monthlyActivity),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────── Bar Chart (Weekly) ──────────────────────

  Widget _buildBarChart(List<double> data, {required bool isWeekly}) {
    final maxY = data.fold(0.0, (prev, curr) => curr > prev ? curr : prev);
    final roundedMax = maxY > 0 ? (maxY * 1.2).ceilToDouble() : 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1)),
      ),
      child: BarChart(
        BarChartData(
          maxY: roundedMax.toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} мин',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < 7) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _getDayLabel(index),
                        style: TextStyle(
                          color: index == 6 ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: index == 6 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: roundedMax > 0 ? roundedMax / 4 : 15,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          barGroups: data.asMap().entries.map((entry) {
            final isToday = entry.key == 6;
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: isToday
                        ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)]
                        : [AppColors.primary.withValues(alpha: 0.5), AppColors.primary.withValues(alpha: 0.2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ────────────────────── Line Chart (Monthly) ──────────────────────

  Widget _buildLineChart(List<double> data) {
    final maxY = data.fold(0.0, (prev, curr) => curr > prev ? curr : prev);
    final roundedMax = maxY > 0 ? (maxY * 1.2).ceilToDouble() : 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1)),
      ),
      child: LineChart(
        LineChartData(
          maxY: roundedMax.toDouble(),
          minY: 0,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final daysAgo = 29 - spot.x.toInt();
                  final date = DateTime.now().subtract(Duration(days: daysAgo));
                  return LineTooltipItem(
                    '${DateFormat('d MMM', 'ru').format(date)}\n${spot.y.toInt()} мин',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 7,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < 30) {
                    final daysAgo = 29 - index;
                    final date = DateTime.now().subtract(Duration(days: daysAgo));
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('d/M').format(date),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: roundedMax > 0 ? roundedMax / 4 : 15,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ────────────────────── Pie Chart (Type Distribution) ──────────────────────

  Widget _buildTypeDistributionChart(BuildContext context, Map<String, int> distribution) {
    final total = distribution.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final colors = [
      AppColors.primary,
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
    ];

    final entries = distribution.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Типы тренировок',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: entries.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final e = entry.value;
                      final pct = (e.value / total * 100).round();
                      return PieChartSectionData(
                        value: e.value.toDouble(),
                        title: '$pct%',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        color: colors[idx % colors.length],
                        radius: 40,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final e = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[idx % colors.length],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getTypeLabel(e.key),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '${e.value}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────── History Card ──────────────────────

  Widget _buildHistoryCard(WorkoutHistory workout) {
    final dateFormat = DateFormat('d MMM, HH:mm', 'ru');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconForType(workout.type),
            color: AppColors.primary,
          ),
        ),
        title: Text(
          workout.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(dateFormat.format(workout.completedAt)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(workout.durationFormatted, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 12),
                Icon(Icons.flash_on, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(workout.intensityLabel, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 16),
            Text(
              'История пуста',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────── Helpers ──────────────────────

  String _getDayLabel(int index) {
    final now = DateTime.now();
    final date = now.subtract(Duration(days: 6 - index));
    return DateFormat('E', 'ru').format(date);
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'lfk':
        return 'ЛФК';
      case 'stretching':
        return 'Растяжка';
      case 'strength':
        return 'Силовая';
      case 'cardio':
        return 'Кардио';
      default:
        return type;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'lfk':
        return Icons.self_improvement;
      case 'stretching':
        return Icons.accessibility_new;
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }
}
