part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state before profile is loaded
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading profile from Firestore
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile loaded successfully
class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Profile not found (user has not completed onboarding)
class ProfileNotFound extends ProfileState {
  const ProfileNotFound();
}

/// Error loading profile
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Profile is being updated
class ProfileUpdating extends ProfileState {
  final UserProfile currentProfile;

  const ProfileUpdating(this.currentProfile);

  @override
  List<Object?> get props => [currentProfile];
}
