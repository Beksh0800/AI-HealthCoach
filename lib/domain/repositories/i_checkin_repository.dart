import '../../data/models/daily_checkin_model.dart';

/// Abstract interface for daily check-in operations
abstract class ICheckInRepository {
  /// Save a new check-in
  Future<String> saveCheckIn(DailyCheckIn checkIn);

  /// Get today's check-in for a user
  Future<DailyCheckIn?> getTodayCheckIn(String userUid);

  /// Get check-in history for a user
  Future<List<DailyCheckIn>> getCheckInHistory(
    String userUid, {
    int limit = 30,
  });

  /// Get latest check-in for a user
  Future<DailyCheckIn?> getLatestCheckIn(String userUid);

  /// Delete a check-in
  Future<void> deleteCheckIn(String checkInId);
}
