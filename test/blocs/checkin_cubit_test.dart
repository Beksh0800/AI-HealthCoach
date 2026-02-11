import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ai_health_coach/presentation/blocs/checkin/checkin_cubit.dart';
import 'package:ai_health_coach/data/repositories/checkin_repository.dart';
import 'package:ai_health_coach/data/models/daily_checkin_model.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockCheckInRepository extends Mock implements CheckInRepository {}
class MockUser extends Mock implements User {}

// Test data
final testCheckIn = DailyCheckIn(
  id: 'test-checkin-id',
  odUid: 'test-uid',
  date: DateTime(2024, 1, 15),
  painLevel: 3,
  painLocation: 'knee',
  energyLevel: 7,
  sleepQuality: 8,
  mood: 'good',
  currentSymptoms: ['fatigue'],
  notes: 'Test notes',
);

void main() {
  late CheckInCubit checkInCubit;
  late MockFirebaseAuth mockAuth;
  late MockCheckInRepository mockCheckInRepository;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockCheckInRepository = MockCheckInRepository();
    mockUser = MockUser();
    
    when(() => mockUser.uid).thenReturn('test-uid');
    
    checkInCubit = CheckInCubit(
      checkInRepository: mockCheckInRepository,
      auth: mockAuth,
    );
  });

  setUpAll(() {
    registerFallbackValue(testCheckIn);
  });

  tearDown(() {
    checkInCubit.close();
  });

  group('CheckInCubit', () {
    test('initial state is CheckInInitial', () {
      expect(checkInCubit.state, const CheckInInitial());
    });

    group('checkTodayStatus', () {
      blocTest<CheckInCubit, CheckInState>(
        'emits [CheckInError] when user is not logged in',
        build: () {
          when(() => mockAuth.currentUser).thenReturn(null);
          return checkInCubit;
        },
        act: (cubit) => cubit.checkTodayStatus(),
        expect: () => [isA<CheckInError>()],
      );

      blocTest<CheckInCubit, CheckInState>(
        'emits [CheckInLoading, CheckInAlreadyCompleted] when today check-in exists',
        build: () {
          when(() => mockAuth.currentUser).thenReturn(mockUser);
          when(() => mockCheckInRepository.getTodayCheckIn('test-uid'))
              .thenAnswer((_) async => testCheckIn);
          return checkInCubit;
        },
        act: (cubit) => cubit.checkTodayStatus(),
        expect: () => [
          const CheckInLoading(),
          CheckInAlreadyCompleted(testCheckIn),
        ],
      );

      blocTest<CheckInCubit, CheckInState>(
        'emits [CheckInLoading, CheckInInProgress] when no check-in today',
        build: () {
          when(() => mockAuth.currentUser).thenReturn(mockUser);
          when(() => mockCheckInRepository.getTodayCheckIn('test-uid'))
              .thenAnswer((_) async => null);
          return checkInCubit;
        },
        act: (cubit) => cubit.checkTodayStatus(),
        expect: () => [
          const CheckInLoading(),
          const CheckInInProgress(),
        ],
      );
    });

    group('updatePainLevel', () {
      blocTest<CheckInCubit, CheckInState>(
        'updates painLevel in CheckInInProgress state',
        build: () => checkInCubit,
        seed: () => const CheckInInProgress(),
        act: (cubit) => cubit.updatePainLevel(5),
        expect: () => [const CheckInInProgress(painLevel: 5)],
      );
    });

    group('updateEnergyLevel', () {
      blocTest<CheckInCubit, CheckInState>(
        'updates energyLevel in CheckInInProgress state',
        build: () => checkInCubit,
        seed: () => const CheckInInProgress(),
        act: (cubit) => cubit.updateEnergyLevel(8),
        expect: () => [const CheckInInProgress(energyLevel: 8)],
      );
    });

    group('updateMood', () {
      blocTest<CheckInCubit, CheckInState>(
        'updates mood in CheckInInProgress state',
        build: () => checkInCubit,
        seed: () => const CheckInInProgress(),
        act: (cubit) => cubit.updateMood('great'),
        expect: () => [const CheckInInProgress(mood: 'great')],
      );
    });

    group('toggleSymptom', () {
      blocTest<CheckInCubit, CheckInState>(
        'adds symptom when not present',
        build: () => checkInCubit,
        seed: () => const CheckInInProgress(),
        act: (cubit) => cubit.toggleSymptom('headache'),
        expect: () => [const CheckInInProgress(symptoms: ['headache'])],
      );

      blocTest<CheckInCubit, CheckInState>(
        'removes symptom when already present',
        build: () => checkInCubit,
        seed: () => const CheckInInProgress(symptoms: ['headache', 'fatigue']),
        act: (cubit) => cubit.toggleSymptom('headache'),
        expect: () => [const CheckInInProgress(symptoms: ['fatigue'])],
      );
    });

    group('navigation', () {
      blocTest<CheckInCubit, CheckInState>(
        'nextStep increments currentStep',
        build: () => checkInCubit,
        seed: () => const CheckInInProgress(currentStep: 0),
        act: (cubit) => cubit.nextStep(),
        expect: () => [const CheckInInProgress(currentStep: 1)],
      );

      blocTest<CheckInCubit, CheckInState>(
        'previousStep decrements currentStep',
        build: () => checkInCubit,
        seed: () => const CheckInInProgress(currentStep: 2),
        act: (cubit) => cubit.previousStep(),
        expect: () => [const CheckInInProgress(currentStep: 1)],
      );

      blocTest<CheckInCubit, CheckInState>(
        'nextStep does not exceed max step',
        build: () => checkInCubit,
        seed: () => const CheckInInProgress(currentStep: 3),
        act: (cubit) => cubit.nextStep(),
        expect: () => [],
      );

      blocTest<CheckInCubit, CheckInState>(
        'previousStep does not go below 0',
        build: () => checkInCubit,
        seed: () => const CheckInInProgress(currentStep: 0),
        act: (cubit) => cubit.previousStep(),
        expect: () => [],
      );
    });

    group('reset', () {
      blocTest<CheckInCubit, CheckInState>(
        'resets to CheckInInProgress',
        build: () => checkInCubit,
        seed: () => CheckInCompleted(testCheckIn),
        act: (cubit) => cubit.reset(),
        expect: () => [const CheckInInProgress()],
      );
    });
  });
}
