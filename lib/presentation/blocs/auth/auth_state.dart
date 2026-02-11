part of 'auth_cubit.dart';

/// Authentication states
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking auth status
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - during auth operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state - user is logged in
class AuthAuthenticated extends AuthState {
  final String uid;
  final String? email;
  final bool hasCompletedOnboarding;

  const AuthAuthenticated({
    required this.uid,
    this.email,
    this.hasCompletedOnboarding = false,
  });

  @override
  List<Object?> get props => [uid, email, hasCompletedOnboarding];
}

/// Unauthenticated state - user is not logged in
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state - auth operation failed
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
