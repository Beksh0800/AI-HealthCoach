part of 'history_cubit.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

final class HistoryInitial extends HistoryState {}

final class HistoryLoading extends HistoryState {}

final class HistoryLoaded extends HistoryState {
  final List<WorkoutHistory> history;
  final int totalWorkouts;
  final int totalMinutes;
  final List<double> weeklyActivity; // 7 days of activity in minutes
  final List<double> monthlyActivity; // 30 days of activity in minutes
  final Map<String, int> typeDistribution; // type → count

  const HistoryLoaded({
    required this.history,
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.weeklyActivity,
    this.monthlyActivity = const [],
    this.typeDistribution = const {},
  });

  @override
  List<Object> get props => [history, totalWorkouts, totalMinutes, weeklyActivity, monthlyActivity, typeDistribution];
}

final class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}
