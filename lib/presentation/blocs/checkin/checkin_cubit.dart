import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/daily_checkin_model.dart';
import '../../../domain/repositories/i_checkin_repository.dart';

part 'checkin_state.dart';

/// Cubit for managing daily check-in flow
class CheckInCubit extends Cubit<CheckInState> {
  final ICheckInRepository _checkInRepository;
  final FirebaseAuth _auth;

  CheckInCubit({
    required ICheckInRepository checkInRepository,
    required FirebaseAuth auth,
  })  : _checkInRepository = checkInRepository,
        _auth = auth,
        super(const CheckInInitial());

  /// Check if user has already completed today's check-in
  Future<void> checkTodayStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(const CheckInError('Пользователь не авторизован'));
      return;
    }

    emit(const CheckInLoading());

    try {
      final todayCheckIn = await _checkInRepository.getTodayCheckIn(user.uid);
      if (todayCheckIn != null) {
        emit(CheckInAlreadyCompleted(todayCheckIn));
      } else {
        emit(const CheckInInProgress());
      }
    } catch (e) {
      emit(const CheckInInProgress());
    }
  }

  /// Start a new check-in
  void startCheckIn() {
    emit(const CheckInInProgress());
  }

  /// Update pain level
  void updatePainLevel(int level) {
    final current = state;
    if (current is CheckInInProgress) {
      emit(current.copyWith(painLevel: level));
    }
  }

  /// Update pain location
  void updatePainLocation(String location) {
    final current = state;
    if (current is CheckInInProgress) {
      emit(current.copyWith(painLocation: location));
    }
  }

  /// Update energy level
  void updateEnergyLevel(int level) {
    final current = state;
    if (current is CheckInInProgress) {
      emit(current.copyWith(energyLevel: level));
    }
  }

  /// Update sleep quality
  void updateSleepQuality(int quality) {
    final current = state;
    if (current is CheckInInProgress) {
      emit(current.copyWith(sleepQuality: quality));
    }
  }

  /// Update mood
  void updateMood(String mood) {
    final current = state;
    if (current is CheckInInProgress) {
      emit(current.copyWith(mood: mood));
    }
  }

  /// Toggle symptom selection
  void toggleSymptom(String symptom) {
    final current = state;
    if (current is CheckInInProgress) {
      final symptoms = List<String>.from(current.symptoms);
      if (symptoms.contains(symptom)) {
        symptoms.remove(symptom);
      } else {
        symptoms.add(symptom);
      }
      emit(current.copyWith(symptoms: symptoms));
    }
  }

  /// Update notes
  void updateNotes(String? notes) {
    final current = state;
    if (current is CheckInInProgress) {
      emit(current.copyWith(notes: notes));
    }
  }

  /// Go to next step
  void nextStep() {
    final current = state;
    if (current is CheckInInProgress && current.currentStep < 3) {
      emit(current.copyWith(currentStep: current.currentStep + 1));
    }
  }

  /// Go to previous step
  void previousStep() {
    final current = state;
    if (current is CheckInInProgress && current.currentStep > 0) {
      emit(current.copyWith(currentStep: current.currentStep - 1));
    }
  }

  /// Submit check-in
  Future<void> submitCheckIn() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(const CheckInError('Пользователь не авторизован'));
      return;
    }

    final current = state;
    if (current is! CheckInInProgress) return;

    emit(const CheckInLoading());

    try {
      final checkIn = DailyCheckIn(
        id: '',
        odUid: user.uid,
        date: DateTime.now(),
        painLevel: current.painLevel,
        painLocation: current.painLocation,
        energyLevel: current.energyLevel,
        sleepQuality: current.sleepQuality,
        mood: current.mood,
        currentSymptoms: current.symptoms,
        notes: current.notes,
      );

      final id = await _checkInRepository.saveCheckIn(checkIn);
      emit(CheckInCompleted(checkIn.copyWith(id: id)));
    } catch (e) {
      emit(CheckInError('Ошибка сохранения: $e'));
    }
  }

  /// Reset to start new check-in
  void reset() {
    emit(const CheckInInProgress());
  }
}
