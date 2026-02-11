import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/workout_history_model.dart';
import '../../../domain/repositories/i_history_repository.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final IHistoryRepository _repository;
  final FirebaseAuth _auth;

  HistoryCubit({
    required IHistoryRepository repository,
    required FirebaseAuth auth,
  })  : _repository = repository,
        _auth = auth,
        super(HistoryInitial());

  Future<void> loadHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(const HistoryError('Пользователь не авторизован'));
      return;
    }

    emit(HistoryLoading());

    try {
      final historyFuture = _repository.getUserHistory(user.uid);
      final countFuture = _repository.getTotalWorkouts(user.uid);
      final minutesFuture = _repository.getTotalMinutes(user.uid);
      final weekStatsFuture = _repository.getWeeklyStats(user.uid);
      final monthStatsFuture = _repository.getMonthlyStats(user.uid);
      final typeDistFuture = _repository.getWorkoutTypeDistribution(user.uid);

      final results = await Future.wait([
        historyFuture,
        countFuture,
        minutesFuture,
        weekStatsFuture,
        monthStatsFuture,
        typeDistFuture,
      ]);

      emit(HistoryLoaded(
        history: results[0] as List<WorkoutHistory>,
        totalWorkouts: results[1] as int,
        totalMinutes: results[2] as int,
        weeklyActivity: results[3] as List<double>,
        monthlyActivity: results[4] as List<double>,
        typeDistribution: results[5] as Map<String, int>,
      ));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
