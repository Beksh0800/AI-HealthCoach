import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../domain/repositories/i_user_repository.dart';

part 'auth_state.dart';

/// Cubit for managing authentication state
class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final IUserRepository _userRepository;

  AuthCubit({
    required FirebaseAuth auth,
    required IUserRepository userRepository,
  })  : _auth = auth,
        _userRepository = userRepository,
        super(const AuthInitial());

  /// Check current authentication status
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final user = _auth.currentUser;
    if (user != null) {
      // Check if user has completed onboarding
      final hasProfile = await _userRepository.hasUserProfile(user.uid);
      emit(AuthAuthenticated(
        uid: user.uid,
        email: user.email,
        hasCompletedOnboarding: hasProfile,
      ));
    } else {
      emit(const AuthUnauthenticated());
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
        final hasProfile = await _userRepository.hasUserProfile(credential.user!.uid);
        emit(AuthAuthenticated(
          uid: credential.user!.uid,
          email: credential.user!.email,
          hasCompletedOnboarding: hasProfile,
        ));
      } else {
        emit(const AuthError('Не удалось войти'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError('Произошла ошибка: $e'));
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
        emit(AuthAuthenticated(
          uid: credential.user!.uid,
          email: credential.user!.email,
          hasCompletedOnboarding: false,
        ));
      } else {
        emit(const AuthError('Не удалось зарегистрироваться'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError('Произошла ошибка: $e'));
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
      emit(AuthAuthenticated(
        uid: currentState.uid,
        email: currentState.email,
        hasCompletedOnboarding: true,
      ));
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'email-already-in-use':
        return 'Email уже используется';
      case 'weak-password':
        return 'Слишком слабый пароль';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-disabled':
        return 'Аккаунт заблокирован';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      default:
        return 'Ошибка авторизации: $code';
    }
  }
}
