import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/i_checkin_repository.dart';
import '../models/daily_checkin_model.dart';

/// Repository for daily check-in operations
class CheckInRepository implements ICheckInRepository {
  final FirebaseFirestore _firestore;

  CheckInRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _checkInsCollection =>
      _firestore.collection('check_ins');

  /// Save a new check-in
  @override
  Future<String> saveCheckIn(DailyCheckIn checkIn) async {
    final docRef = await _checkInsCollection.add(checkIn.toMap());
    return docRef.id;
  }

  /// Get today's check-in for a user
  @override
  Future<DailyCheckIn?> getTodayCheckIn(String userUid) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await _checkInsCollection
        .where('user_uid', isEqualTo: userUid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    return DailyCheckIn.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// Get check-in history for a user
  @override
  Future<List<DailyCheckIn>> getCheckInHistory(
    String userUid, {
    int limit = 30,
  }) async {
    final query = await _checkInsCollection
        .where('user_uid', isEqualTo: userUid)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return query.docs
        .map((doc) =>
            DailyCheckIn.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Get latest check-in for a user
  @override
  Future<DailyCheckIn?> getLatestCheckIn(String userUid) async {
    final query = await _checkInsCollection
        .where('user_uid', isEqualTo: userUid)
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    return DailyCheckIn.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// Delete a check-in
  @override
  Future<void> deleteCheckIn(String checkInId) async {
    await _checkInsCollection.doc(checkInId).delete();
  }
}
