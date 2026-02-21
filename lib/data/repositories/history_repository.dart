import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/i_history_repository.dart';
import '../models/workout_history_model.dart';

class HistoryRepository implements IHistoryRepository {
  final FirebaseFirestore _firestore;

  HistoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _historyCollection =>
      _firestore.collection('workout_history');

  DateTime _toLocalDateOnly(DateTime dateTime) {
    final local = dateTime.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Get workout history for a user
  @override
  Future<List<WorkoutHistory>> getUserHistory(String userUid) async {
    try {
      final snapshot = await _historyCollection
          .where('user_uid', isEqualTo: userUid)
          .orderBy('completed_at', descending: true)
          .limit(20) // Limit to last 20 workouts for now
          .get();

      return snapshot.docs
          .map(
            (doc) => WorkoutHistory.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Ошибка загрузки истории: $e');
    }
  }

  /// Get total workouts count
  @override
  Future<int> getTotalWorkouts(String userUid) async {
    final snapshot = await _historyCollection
        .where('user_uid', isEqualTo: userUid)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  /// Get total minutes trained (approximate)
  @override
  Future<int> getTotalMinutes(String userUid) async {
    final snapshot = await _historyCollection
        .where('user_uid', isEqualTo: userUid)
        .get();

    int seconds = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      seconds += (data['duration_seconds'] as int? ?? 0);
    }

    return seconds ~/ 60;
  }

  @override
  Future<List<double>> getWeeklyStats(String userUid) async {
    final today = _toLocalDateOnly(DateTime.now());
    final weekStart = today.subtract(const Duration(days: 6));

    final snapshot = await _historyCollection
        .where('user_uid', isEqualTo: userUid)
        .where(
          'completed_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart),
        )
        .get();

    final List<double> stats = List.filled(7, 0.0);

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = _toLocalDateOnly(
        (data['completed_at'] as Timestamp).toDate(),
      );
      final minutes = (data['duration_seconds'] as int? ?? 0) / 60.0;

      final difference = today.difference(date).inDays;
      if (difference >= 0 && difference < 7) {
        // Index 6 is today, index 0 is 6 days ago.
        final index = 6 - difference;
        if (index >= 0 && index < 7) {
          stats[index] += minutes;
        }
      }
    }

    return stats;
  }

  @override
  Future<List<double>> getMonthlyStats(String userUid) async {
    final today = _toLocalDateOnly(DateTime.now());
    final monthStart = today.subtract(const Duration(days: 29));

    final snapshot = await _historyCollection
        .where('user_uid', isEqualTo: userUid)
        .where(
          'completed_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
        )
        .get();

    final List<double> stats = List.filled(30, 0.0);

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = _toLocalDateOnly(
        (data['completed_at'] as Timestamp).toDate(),
      );
      final minutes = (data['duration_seconds'] as int? ?? 0) / 60.0;

      final difference = today.difference(date).inDays;
      if (difference >= 0 && difference < 30) {
        final index = 29 - difference;
        if (index >= 0 && index < 30) {
          stats[index] += minutes;
        }
      }
    }

    return stats;
  }

  @override
  Future<Map<String, int>> getWorkoutTypeDistribution(String userUid) async {
    final snapshot = await _historyCollection
        .where('user_uid', isEqualTo: userUid)
        .get();

    final distribution = <String, int>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final type = data['type'] as String? ?? 'lfk';
      distribution[type] = (distribution[type] ?? 0) + 1;
    }

    return distribution;
  }
}
