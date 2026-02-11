import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ai_health_coach/presentation/blocs/auth/auth_cubit.dart';
import 'package:ai_health_coach/data/repositories/user_repository.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserRepository extends Mock implements UserRepository {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late AuthCubit authCubit;
  late MockFirebaseAuth mockAuth;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserRepository = MockUserRepository();
    authCubit = AuthCubit(
      auth: mockAuth,
      userRepository: mockUserRepository,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(authCubit.state, const AuthInitial());
    });

    group('checkAuthStatus', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when no user is logged in',
        build: () {
          when(() => mockAuth.currentUser).thenReturn(null);
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is logged in with profile',
        build: () {
          final mockUser = MockUser();
          when(() => mockUser.uid).thenReturn('test-uid');
          when(() => mockUser.email).thenReturn('test@example.com');
          when(() => mockAuth.currentUser).thenReturn(mockUser);
          when(() => mockUserRepository.hasUserProfile('test-uid'))
              .thenAnswer((_) async => true);
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(
            uid: 'test-uid',
            email: 'test@example.com',
            hasCompletedOnboarding: true,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] with hasCompletedOnboarding=false when no profile',
        build: () {
          final mockUser = MockUser();
          when(() => mockUser.uid).thenReturn('test-uid');
          when(() => mockUser.email).thenReturn('test@example.com');
          when(() => mockAuth.currentUser).thenReturn(mockUser);
          when(() => mockUserRepository.hasUserProfile('test-uid'))
              .thenAnswer((_) async => false);
          return authCubit;
        },
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(
            uid: 'test-uid',
            email: 'test@example.com',
            hasCompletedOnboarding: false,
          ),
        ],
      );
    });

    group('signOut', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] on signOut',
        build: () {
          when(() => mockAuth.signOut()).thenAnswer((_) async {});
          return authCubit;
        },
        act: (cubit) => cubit.signOut(),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );
    });

    group('markOnboardingCompleted', () {
      blocTest<AuthCubit, AuthState>(
        'updates hasCompletedOnboarding to true when authenticated',
        build: () => authCubit,
        seed: () => const AuthAuthenticated(
          uid: 'test-uid',
          email: 'test@email.com',
          hasCompletedOnboarding: false,
        ),
        act: (cubit) => cubit.markOnboardingCompleted(),
        expect: () => [
          const AuthAuthenticated(
            uid: 'test-uid',
            email: 'test@email.com',
            hasCompletedOnboarding: true,
          ),
        ],
      );
    });
  });
}
