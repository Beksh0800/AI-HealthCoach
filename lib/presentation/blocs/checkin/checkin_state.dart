part of 'checkin_cubit.dart';

sealed class CheckInState extends Equatable {
  const CheckInState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CheckInInitial extends CheckInState {
  const CheckInInitial();
}

/// Loading check-in data
class CheckInLoading extends CheckInState {
  const CheckInLoading();
}

/// User is filling out check-in form
class CheckInInProgress extends CheckInState {
  final int currentStep;
  final int painLevel;
  final String painLocation;
  final int energyLevel;
  final int sleepQuality;
  final String mood;
  final List<String> symptoms;
  final String? notes;

  const CheckInInProgress({
    this.currentStep = 0,
    this.painLevel = 0,
    this.painLocation = 'Нет боли',
    this.energyLevel = 3,
    this.sleepQuality = 3,
    this.mood = 'neutral',
    this.symptoms = const [],
    this.notes,
  });

  @override
  List<Object?> get props => [
        currentStep,
        painLevel,
        painLocation,
        energyLevel,
        sleepQuality,
        mood,
        symptoms,
        notes,
      ];

  CheckInInProgress copyWith({
    int? currentStep,
    int? painLevel,
    String? painLocation,
    int? energyLevel,
    int? sleepQuality,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) {
    return CheckInInProgress(
      currentStep: currentStep ?? this.currentStep,
      painLevel: painLevel ?? this.painLevel,
      painLocation: painLocation ?? this.painLocation,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
    );
  }
}

/// Check-in completed and saved
class CheckInCompleted extends CheckInState {
  final DailyCheckIn checkIn;

  const CheckInCompleted(this.checkIn);

  @override
  List<Object?> get props => [checkIn];
}

/// Today's check-in already exists
class CheckInAlreadyCompleted extends CheckInState {
  final DailyCheckIn checkIn;

  const CheckInAlreadyCompleted(this.checkIn);

  @override
  List<Object?> get props => [checkIn];
}

/// Error state
class CheckInError extends CheckInState {
  final String message;

  const CheckInError(this.message);

  @override
  List<Object?> get props => [message];
}
