import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../domain/repositories/i_user_repository.dart';

part 'auth_state.dart';

/// Cubit for managing authentication state
class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final IUserRepository _userRepository;

  AuthCubit({
    required FirebaseAuth auth,
    required IUserRepository userRepository,
  }) : _auth = auth,
       _userRepository = userRepository,
       super(const AuthInitial());

  /// Check current authentication status
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final user = _auth.currentUser;
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final hasProfile = await _userRepository.hasUserProfile(user.uid);
      emit(
        AuthAuthenticated(
          uid: user.uid,
          email: user.email,
          hasCompletedOnboarding: hasProfile,
        ),
      );
    } catch (e) {
      final mapped = ErrorMapper.toAppException(
        e,
        fallbackCode: 'AUTH_STATUS_FAILED',
      );
      emit(
        AuthError(
          errorCode: mapped.code ?? 'AUTH_STATUS_FAILED',
          debugMessage: mapped.message,
        ),
      );
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        final hasProfile = await _userRepository.hasUserProfile(
          credential.user!.uid,
        );
        emit(
          AuthAuthenticated(
            uid: credential.user!.uid,
            email: credential.user!.email,
            hasCompletedOnboarding: hasProfile,
          ),
        );
      } else {
        emit(const AuthError(errorCode: 'AUTH_SIGNIN_FAILED'));
      }
    } on FirebaseAuthException catch (e) {
      emit(
        AuthError(
          errorCode: _mapAuthErrorCode(
            e.code,
            defaultCode: 'AUTH_SIGNIN_FAILED',
          ),
          debugMessage: e.message,
        ),
      );
    } catch (e) {
      final mapped = ErrorMapper.toAppException(
        e,
        fallbackCode: 'AUTH_SIGNIN_FAILED',
      );
      emit(
        AuthError(
          errorCode: mapped.code ?? 'AUTH_SIGNIN_FAILED',
          debugMessage: mapped.message,
        ),
      );
    }
  }

  /// Register with email and password
  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        emit(
          AuthAuthenticated(
            uid: credential.user!.uid,
            email: credential.user!.email,
            hasCompletedOnboarding: false,
          ),
        );
      } else {
        emit(const AuthError(errorCode: 'AUTH_SIGNUP_FAILED'));
      }
    } on FirebaseAuthException catch (e) {
      emit(
        AuthError(
          errorCode: _mapAuthErrorCode(
            e.code,
            defaultCode: 'AUTH_SIGNUP_FAILED',
          ),
          debugMessage: e.message,
        ),
      );
    } catch (e) {
      final mapped = ErrorMapper.toAppException(
        e,
        fallbackCode: 'AUTH_SIGNUP_FAILED',
      );
      emit(
        AuthError(
          errorCode: mapped.code ?? 'AUTH_SIGNUP_FAILED',
          debugMessage: mapped.message,
        ),
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    emit(const AuthLoading());
    await _auth.signOut();
    emit(const AuthUnauthenticated());
  }

  /// Mark onboarding as completed
  void markOnboardingCompleted() {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      emit(
        AuthAuthenticated(
          uid: currentState.uid,
          email: currentState.email,
          hasCompletedOnboarding: true,
        ),
      );
    }
  }

  String _mapAuthErrorCode(String code, {required String defaultCode}) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'INVALID_CREDENTIALS';
      case 'email-already-in-use':
        return 'EMAIL_IN_USE';
      case 'weak-password':
        return 'WEAK_PASSWORD';
      case 'too-many-requests':
        return 'TOO_MANY_REQUESTS';
      case 'network-request-failed':
        return 'NO_CONNECTION';
      default:
        return defaultCode;
    }
  }
}
