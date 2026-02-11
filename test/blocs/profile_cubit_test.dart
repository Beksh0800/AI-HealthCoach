import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ai_health_coach/presentation/blocs/profile/profile_cubit.dart';
import 'package:ai_health_coach/data/repositories/user_repository.dart';
import 'package:ai_health_coach/data/models/user_profile_model.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserRepository extends Mock implements UserRepository {}
class MockUser extends Mock implements User {}

// Test data
final testProfile = UserProfile(
  uid: 'test-uid',
  name: 'Test User',
  email: 'test@example.com',
  goals: 'Test goals',
  medicalProfile: MedicalProfile(
    age: 30,
    weight: 70.0,
    activityLevel: 'moderate',
    injuries: ['knee'],
    contraindications: [],
  ),
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
);

void main() {
  late ProfileCubit profileCubit;
  late MockFirebaseAuth mockAuth;
  late MockUserRepository mockUserRepository;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserRepository = MockUserRepository();
    mockUser = MockUser();
    
    when(() => mockUser.uid).thenReturn('test-uid');
    
    profileCubit = ProfileCubit(
      userRepository: mockUserRepository,
      auth: mockAuth,
    );
  });

  setUpAll(() {
    registerFallbackValue(testProfile);
  });

  tearDown(() {
    profileCubit.close();
  });

  group('ProfileCubit', () {
    test('initial state is ProfileInitial', () {
      expect(profileCubit.state, const ProfileInitial());
    });

    group('loadProfile', () {
      blocTest<ProfileCubit, ProfileState>(
        'emits [ProfileNotFound] when no user is logged in',
        build: () {
          when(() => mockAuth.currentUser).thenReturn(null);
          return profileCubit;
        },
        act: (cubit) => cubit.loadProfile(),
        expect: () => [const ProfileNotFound()],
      );

      blocTest<ProfileCubit, ProfileState>(
        'emits [ProfileLoading, ProfileLoaded] when profile exists',
        build: () {
          when(() => mockAuth.currentUser).thenReturn(mockUser);
          when(() => mockUserRepository.getUserProfile('test-uid'))
              .thenAnswer((_) async => testProfile);
          return profileCubit;
        },
        act: (cubit) => cubit.loadProfile(),
        expect: () => [
          const ProfileLoading(),
          ProfileLoaded(testProfile),
        ],
      );

      blocTest<ProfileCubit, ProfileState>(
        'emits [ProfileLoading, ProfileNotFound] when profile does not exist',
        build: () {
          when(() => mockAuth.currentUser).thenReturn(mockUser);
          when(() => mockUserRepository.getUserProfile('test-uid'))
              .thenAnswer((_) async => null);
          return profileCubit;
        },
        act: (cubit) => cubit.loadProfile(),
        expect: () => [
          const ProfileLoading(),
          const ProfileNotFound(),
        ],
      );

      blocTest<ProfileCubit, ProfileState>(
        'emits [ProfileLoading, ProfileError] on error',
        build: () {
          when(() => mockAuth.currentUser).thenReturn(mockUser);
          when(() => mockUserRepository.getUserProfile('test-uid'))
              .thenThrow(Exception('Network error'));
          return profileCubit;
        },
        act: (cubit) => cubit.loadProfile(),
        expect: () => [
          const ProfileLoading(),
          isA<ProfileError>(),
        ],
      );
    });

    group('updateProfile', () {
      final updatedProfile = testProfile.copyWith(name: 'Updated Name');

      blocTest<ProfileCubit, ProfileState>(
        'emits [ProfileUpdating, ProfileLoaded] on successful update',
        build: () {
          when(() => mockUserRepository.updateUserProfile(any()))
              .thenAnswer((_) async {});
          return profileCubit;
        },
        seed: () => ProfileLoaded(testProfile),
        act: (cubit) => cubit.updateProfile(updatedProfile),
        expect: () => [
          ProfileUpdating(testProfile),
          ProfileLoaded(updatedProfile),
        ],
      );
    });

    group('clearProfile', () {
      blocTest<ProfileCubit, ProfileState>(
        'emits [ProfileInitial] when clearing profile',
        build: () => profileCubit,
        seed: () => ProfileLoaded(testProfile),
        act: (cubit) => cubit.clearProfile(),
        expect: () => [const ProfileInitial()],
      );
    });
  });
}
