import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../domain/repositories/i_user_repository.dart';

part 'profile_state.dart';

/// Cubit for managing user profile state
class ProfileCubit extends Cubit<ProfileState> {
  final IUserRepository _userRepository;
  final FirebaseAuth _auth;
  StreamSubscription<UserProfile?>? _profileSubscription;

  ProfileCubit({
    required IUserRepository userRepository,
    required FirebaseAuth auth,
  }) : _userRepository = userRepository,
       _auth = auth,
       super(const ProfileInitial());

  /// Load the current user's profile
  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(const ProfileNotFound());
      return;
    }

    emit(const ProfileLoading());

    try {
      final profile = await _userRepository.getUserProfile(user.uid);
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileNotFound());
      }
    } catch (e) {
      emit(
        ProfileError(
          ErrorMapper.toMessage(
            e,
            fallbackMessage:
                'Не удалось загрузить профиль. Проверьте соединение.',
          ),
        ),
      );
    }
  }

  /// Subscribe to profile changes (real-time sync)
  void subscribeToProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      emit(const ProfileNotFound());
      return;
    }

    _profileSubscription?.cancel();
    _profileSubscription = _userRepository
        .watchUserProfile(user.uid)
        .listen(
          (profile) {
            if (profile != null) {
              emit(ProfileLoaded(profile));
            } else {
              emit(const ProfileNotFound());
            }
          },
          onError: (error) {
            emit(
              ProfileError(
                ErrorMapper.toMessage(
                  error,
                  fallbackMessage: 'Ошибка синхронизации профиля.',
                ),
              ),
            );
          },
        );
  }

  /// Update user profile
  Future<void> updateProfile(UserProfile updatedProfile) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentState.profile));
    }

    try {
      await _userRepository.updateUserProfile(updatedProfile);
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      if (currentState is ProfileLoaded) {
        emit(currentState);
      }
      emit(
        ProfileError(
          ErrorMapper.toMessage(
            e,
            fallbackMessage: 'Не удалось обновить профиль. Попробуйте позже.',
          ),
        ),
      );
    }
  }

  /// Update specific profile fields
  Future<void> updateProfileField({
    String? name,
    String? goals,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? activityLevel,
    List<String>? injuries,
  }) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    final currentProfile = currentState.profile;
    final sanitizedNameRaw = _sanitizeText(
      name ?? currentProfile.name,
      AppConstants.maxNameLength,
    );
    final sanitizedName = sanitizedNameRaw.isEmpty
        ? currentProfile.name
        : sanitizedNameRaw;
    final sanitizedGoals = _sanitizeText(
      goals ?? currentProfile.goals,
      AppConstants.maxGoalsLength,
    );
    final sanitizedAge = _clampInt(
      age ?? currentProfile.medicalProfile.age,
      AppConstants.minAge,
      AppConstants.maxAge,
    );
    final sanitizedHeight = _clampDouble(
      height ?? currentProfile.medicalProfile.height,
      AppConstants.minHeightCm,
      AppConstants.maxHeightCm,
    );
    final sanitizedWeight = _clampDouble(
      weight ?? currentProfile.medicalProfile.weight,
      AppConstants.minWeightKg,
      AppConstants.maxWeightKg,
    );
    final sanitizedGender = _normalizeGender(
      gender ?? currentProfile.medicalProfile.gender,
    );
    final sanitizedInjuries = _sanitizeInjuries(
      injuries ?? currentProfile.medicalProfile.injuries,
    );
    final contraindications = MedicalProfile.generateContraindications(
      sanitizedInjuries,
      AppConstants.contraindicationsMap,
    );
    final updatedProfile = currentProfile.copyWith(
      name: sanitizedName,
      goals: sanitizedGoals,
      medicalProfile: MedicalProfile(
        age: sanitizedAge,
        weight: sanitizedWeight,
        height: sanitizedHeight,
        gender: sanitizedGender,
        activityLevel:
            activityLevel ?? currentProfile.medicalProfile.activityLevel,
        injuries: sanitizedInjuries,
        contraindications: contraindications,
      ),
      updatedAt: DateTime.now(),
    );

    await updateProfile(updatedProfile);
  }

  String _sanitizeText(String value, int maxLength) {
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }

  int _clampInt(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  double _clampDouble(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  String _normalizeGender(String value) {
    switch (value.trim().toLowerCase()) {
      case 'male':
      case 'female':
      case 'not_specified':
        return value.trim().toLowerCase();
      default:
        return 'not_specified';
    }
  }

  List<String> _sanitizeInjuries(List<String> injuries) {
    final result = <String>[];
    for (final injury in injuries) {
      final normalized = _sanitizeText(injury, AppConstants.maxInjuryLength);
      if (normalized.isEmpty || result.contains(normalized)) continue;
      result.add(normalized);
      if (result.length >= AppConstants.maxInjuriesCount) break;
    }
    return result;
  }

  /// Clear profile (on logout)
  void clearProfile() {
    _profileSubscription?.cancel();
    emit(const ProfileInitial());
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
