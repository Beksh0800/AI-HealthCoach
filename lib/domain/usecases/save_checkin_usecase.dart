import '../../data/models/daily_checkin_model.dart';
import '../repositories/i_checkin_repository.dart';

/// Result of saving a check-in, with workout recommendation
class CheckInResult {
  final String checkInId;
  final WorkoutRecommendation recommendation;

  CheckInResult({
    required this.checkInId,
    required this.recommendation,
  });
}

/// Workout recommendation based on check-in data
enum WorkoutRecommendation {
  /// Pain >= 7: No workout, rest recommended
  rest,

  /// Pain 4-6 or low energy: Light (LFK) workout
  lightWorkout,

  /// Normal condition: Regular workout
  regularWorkout,
}

/// Use case: Saves daily check-in and determines workout recommendation
///
/// Business rules:
/// 1. Validate check-in data
/// 2. Save to repository
/// 3. Return recommendation based on pain/energy levels
class SaveCheckInUseCase {
  final ICheckInRepository _checkInRepository;

  SaveCheckInUseCase({
    required ICheckInRepository checkInRepository,
  }) : _checkInRepository = checkInRepository;

  Future<CheckInResult> call(DailyCheckIn checkIn) async {
    // Validate
    if (checkIn.painLevel < 0 || checkIn.painLevel > 10) {
      throw ArgumentError('Уровень боли должен быть от 0 до 10');
    }
    if (checkIn.energyLevel < 1 || checkIn.energyLevel > 5) {
      throw ArgumentError('Уровень энергии должен быть от 1 до 5');
    }

    // Save
    final checkInId = await _checkInRepository.saveCheckIn(checkIn);

    // Determine recommendation
    final recommendation = _getRecommendation(checkIn);

    return CheckInResult(
      checkInId: checkInId,
      recommendation: recommendation,
    );
  }

  WorkoutRecommendation _getRecommendation(DailyCheckIn checkIn) {
    if (checkIn.painLevel >= 7) return WorkoutRecommendation.rest;
    if (checkIn.painLevel >= 4 || checkIn.energyLevel <= 2) {
      return WorkoutRecommendation.lightWorkout;
    }
    return WorkoutRecommendation.regularWorkout;
  }
}
