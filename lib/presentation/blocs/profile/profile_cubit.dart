import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  })  : _userRepository = userRepository,
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
      emit(ProfileError('Ошибка загрузки профиля: $e'));
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
    _profileSubscription = _userRepository.watchUserProfile(user.uid).listen(
      (profile) {
        if (profile != null) {
          emit(ProfileLoaded(profile));
        } else {
          emit(const ProfileNotFound());
        }
      },
      onError: (error) {
        emit(ProfileError('Ошибка синхронизации: $error'));
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
      emit(ProfileError('Ошибка обновления: $e'));
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
    final updatedProfile = currentProfile.copyWith(
      name: name,
      goals: goals,
      medicalProfile: MedicalProfile(
        age: age ?? currentProfile.medicalProfile.age,
        weight: weight ?? currentProfile.medicalProfile.weight,
        height: height ?? currentProfile.medicalProfile.height,
        gender: gender ?? currentProfile.medicalProfile.gender,
        activityLevel: activityLevel ?? currentProfile.medicalProfile.activityLevel,
        injuries: injuries ?? currentProfile.medicalProfile.injuries,
        contraindications: currentProfile.medicalProfile.contraindications,
      ),
      updatedAt: DateTime.now(),
    );

    await updateProfile(updatedProfile);
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
