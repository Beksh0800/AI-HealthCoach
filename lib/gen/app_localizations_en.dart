// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AI Health Coach';

  @override
  String get splashSubtitle => 'Your personal trainer';

  @override
  String get onboardingErrorAuth => 'Error: user not authenticated';

  @override
  String get onboardingErrorSave => 'Failed to save profile. Try again later.';

  @override
  String get onboardingRetry => 'Retry';

  @override
  String get onboardingBtnBack => 'Back';

  @override
  String get onboardingBtnNext => 'Next';

  @override
  String get onboardingBtnFinish => 'Finish';

  @override
  String get onboardingWelcomeTitle => 'Welcome!';

  @override
  String get onboardingWelcomeText =>
      'Let\'s create your personal health profile so that workouts are safe and effective.';

  @override
  String get onboardingBasicTitle => 'Tell us about yourself';

  @override
  String get onboardingNameField => 'Your name';

  @override
  String get onboardingGenderTitle => 'Your gender';

  @override
  String get onboardingGenderMale => 'Male';

  @override
  String get onboardingGenderFemale => 'Female';

  @override
  String get onboardingGenderNotSpecified => 'Prefer not to say';

  @override
  String onboardingAgeText(int age) {
    return 'Age: $age years';
  }

  @override
  String onboardingWeightText(String weight) {
    return 'Weight: $weight kg';
  }

  @override
  String get onboardingActivityLevelTitle => 'Activity level';

  @override
  String get onboardingHealthTitle => 'Health concerns';

  @override
  String get onboardingHealthText =>
      'Select everything that applies to you. This will help avoid dangerous exercises.';

  @override
  String get onboardingHealthInfo =>
      'If you have no health issues, just tap \"Next\"';

  @override
  String get onboardingGoalsTitle => 'Your goals';

  @override
  String get onboardingGoalsText => 'What matters most to you right now?';

  @override
  String get goalRelieveBackPain => 'Relieve back pain';

  @override
  String get goalStrengthenCore => 'Strengthen core muscles';

  @override
  String get goalRecoverFromInjury => 'Recover from injury';

  @override
  String get goalImproveFlexibility => 'Improve flexibility';

  @override
  String get goalMaintainGeneralTone => 'Maintain general tone';

  @override
  String get loginTitle => 'Welcome back!';

  @override
  String get loginSubtitle => 'Sign in to continue your workouts';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginRegisterLink => 'Sign Up';

  @override
  String get loginResetSent => 'Password reset link has been sent';

  @override
  String get loginFillEmail => 'Enter your email first';

  @override
  String get registerTitle => 'Sign Up';

  @override
  String get registerSubtitle => 'Create an account to work with your coach';

  @override
  String get registerNameLabel => 'Name';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerButton => 'Sign Up';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get registerLoginLink => 'Sign In';

  @override
  String get registerPasswordMismatch => 'Passwords do not match';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get homeGreetingDefault => 'Hello!';

  @override
  String get homeSubtitle => 'How are you feeling today?';

  @override
  String get homeStartCheckin => 'Complete daily check-in';

  @override
  String get homeCheckinDone => 'Check-in completed';

  @override
  String get homeSectionWorkouts => 'Quick workout';

  @override
  String get homeWorkoutLfk => 'PT';

  @override
  String get homeWorkoutStretching => 'Stretching';

  @override
  String get homeWorkoutStrength => 'Strength';

  @override
  String get homeWorkoutCardio => 'Cardio';

  @override
  String get homeCheckinNotice =>
      'Complete the check-in before starting a workout';

  @override
  String get homeProfileNotLoaded => 'Profile not loaded. Try again later.';

  @override
  String get checkinTitle => 'How are you feeling?';

  @override
  String get checkinMoodLabel => 'Mood';

  @override
  String get checkinEnergyLabel => 'Energy';

  @override
  String get checkinPainLabel => 'Pain level';

  @override
  String get checkinSleepLabel => 'Sleep quality';

  @override
  String get checkinStressLabel => 'Stress';

  @override
  String get checkinButton => 'Continue';

  @override
  String get checkinMoodHints => 'Terrible;Bad;Normal;Good;Great';

  @override
  String get checkinEnergyHints => 'Very low;Low;Normal;High;Full of energy';

  @override
  String get checkinPainHints => 'Very strong;Strong;Moderate;Mild;None';

  @override
  String get checkinSleepHints => 'Very bad;Bad;Normal;Good;Excellent';

  @override
  String get checkinStressHints => 'Very high;High;Moderate;Low;None';

  @override
  String get historyTitle => 'History';

  @override
  String get historyTabStats => 'Statistics';

  @override
  String get historyTabWorkouts => 'Workouts';

  @override
  String get historyWeekChart => 'Workouts this week';

  @override
  String get historyWorkoutsCount => 'Workouts';

  @override
  String get historyTotalMinutes => 'Total minutes';

  @override
  String get historyByType => 'By type';

  @override
  String get historyEmpty => 'History is empty';

  @override
  String get historyLoading => 'Loading history...';

  @override
  String get historyOffline =>
      'No internet connection.\nTry again after connecting.';

  @override
  String get historyOfflineRetry => 'Retry';

  @override
  String get historyLoadError => 'Failed to load history';

  @override
  String get historyRecentWorkouts => 'Recent workouts';

  @override
  String get historyTabWeek => 'Week';

  @override
  String get historyTabMonth => 'Month';

  @override
  String get historyWorkoutsLabel => 'Workouts';

  @override
  String get historyMinutesLabel => 'Minutes';

  @override
  String get historyTypesTitle => 'Workout types';

  @override
  String get historyMinShort => 'min';

  @override
  String get historyTypeLfk => 'PT';

  @override
  String get historyTypeStretching => 'Stretching';

  @override
  String get historyTypeStrength => 'Strength';

  @override
  String get historyTypeCardio => 'Cardio';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSettingsTooltip => 'Settings';

  @override
  String get profileSectionPersonal => 'Personal info';

  @override
  String get profileAge => 'Age';

  @override
  String profileAgeValue(int age) {
    return '$age years';
  }

  @override
  String get profileHeight => 'Height';

  @override
  String profileHeightValue(String height) {
    return '$height cm';
  }

  @override
  String get profileWeight => 'Weight';

  @override
  String profileWeightValue(String weight) {
    return '$weight kg';
  }

  @override
  String get profileGender => 'Gender';

  @override
  String get profileSectionHealth => 'Health & Goals';

  @override
  String get profileActivity => 'Activity';

  @override
  String get profileGoal => 'Goal';

  @override
  String get profileLimitations => 'Limitations';

  @override
  String get profileLogout => 'Sign out';

  @override
  String get profileLoadError => 'Failed to load profile';

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get profileNotFoundMessage =>
      'Complete the survey or refresh the screen.';

  @override
  String get profileLoading => 'Loading profile...';

  @override
  String get profileOffline =>
      'No internet connection.\nTry again after connecting to the network.';

  @override
  String get profileRetry => 'Retry';

  @override
  String get profileGenderMale => 'Male';

  @override
  String get profileGenderFemale => 'Female';

  @override
  String get profileGenderNotSpecified => 'Not specified';

  @override
  String get profileActivityLow => 'Low';

  @override
  String get profileActivityModerate => 'Moderate';

  @override
  String get profileActivityHigh => 'High';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileSectionBasic => 'Basic';

  @override
  String get editProfileNameLabel => 'Name';

  @override
  String get editProfileGenderLabel => 'Gender';

  @override
  String get editProfileGenderMale => 'Male';

  @override
  String get editProfileGenderFemale => 'Female';

  @override
  String get editProfileGenderNotSpecified => 'Not specified';

  @override
  String get editProfileSectionPhysical => 'Physical parameters';

  @override
  String get editProfileAgeLabel => 'Age';

  @override
  String get editProfileHeightLabel => 'Height (cm)';

  @override
  String get editProfileWeightLabel => 'Weight (kg)';

  @override
  String get editProfileSectionGoals => 'Goals & Activity';

  @override
  String get editProfileActivityLabel => 'Activity level';

  @override
  String get editProfileActivityLow => 'Low (sedentary)';

  @override
  String get editProfileActivityModerate => 'Moderate (1-3 workouts)';

  @override
  String get editProfileActivityHigh => 'High (3+ workouts)';

  @override
  String get editProfileGoalsLabel => 'Goals';

  @override
  String get editProfileSectionInjuries => 'Injuries & limitations';

  @override
  String get editProfileAddInjuryLabel => 'Add injury/limitation';

  @override
  String get editProfileAddInjuryHint => 'E.g.: knee pain';

  @override
  String get editProfileAddButton => 'Add';

  @override
  String get editProfileCancel => 'Cancel';

  @override
  String get editProfileSave => 'Save';

  @override
  String get editProfileValidateName => 'Enter your name';

  @override
  String editProfileValidateNameLength(int max) {
    return 'Name must be at most $max characters';
  }

  @override
  String get editProfileValidateAge => 'Enter a valid age';

  @override
  String editProfileValidateAgeRange(int min, int max) {
    return 'Age $min-$max';
  }

  @override
  String get editProfileValidateHeight => 'Enter a valid height';

  @override
  String editProfileValidateHeightRange(int min, int max) {
    return 'Height $min-$max cm';
  }

  @override
  String get editProfileValidateWeight => 'Enter a valid weight';

  @override
  String editProfileValidateWeightRange(int min, int max) {
    return 'Weight $min-$max kg';
  }

  @override
  String editProfileValidateGoalsLength(int max) {
    return 'Goal must be at most $max characters';
  }

  @override
  String editProfileInjuryTooLong(int max) {
    return 'Limitation must be at most $max characters';
  }

  @override
  String editProfileMaxInjuries(int max) {
    return 'You can add up to $max limitations';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsReminderTitle => 'Workout reminders';

  @override
  String get settingsReminderSubtitle => 'Set reminder time and days';

  @override
  String get settingsReminderEnable => 'Enable reminders';

  @override
  String get settingsReminderActive => 'Reminders enabled';

  @override
  String get settingsReminderInactive => 'Reminders disabled';

  @override
  String get settingsReminderPermissionDenied =>
      'Notification permission denied. Enable it in device settings.';

  @override
  String get settingsTimeTitle => 'Reminder time';

  @override
  String get settingsDaysTitle => 'Days of the week';

  @override
  String get settingsPresetWeekdays => 'Weekdays';

  @override
  String get settingsPresetEveryday => 'Every day';

  @override
  String get settingsPresetAlternate => 'Alternate days';

  @override
  String get settingsDayMon => 'Mon';

  @override
  String get settingsDaySun => 'Sun';

  @override
  String get settingsDayTue => 'Tue';

  @override
  String get settingsDayWed => 'Wed';

  @override
  String get settingsDayThu => 'Thu';

  @override
  String get settingsDayFri => 'Fri';

  @override
  String get settingsDaySat => 'Sat';

  @override
  String get workoutSelectionTitle => 'Choose workout';

  @override
  String get workoutSelectionQuestion => 'What workout would you like today?';

  @override
  String get workoutSelectionHint =>
      'Choose a type and AI will create a personal program';

  @override
  String get workoutTypeLfk => 'PT';

  @override
  String get workoutTypeStretching => 'Stretching';

  @override
  String get workoutTypeStrength => 'Strength';

  @override
  String get workoutTypeCardio => 'Cardio';

  @override
  String get workoutDescLfk => 'Physical therapy for recovery';

  @override
  String get workoutDescStretching => 'Flexibility and stretching exercises';

  @override
  String get workoutDescStrength => 'Strength exercises to build muscle';

  @override
  String get workoutDescCardio => 'Cardio for endurance';

  @override
  String get workoutRetry => 'Retry';

  @override
  String get workoutProfileNotLoaded => 'Profile not loaded. Try again later.';

  @override
  String get workoutCheckinRequired => 'Complete the health check-in first';

  @override
  String get workoutSavedWorkouts => 'Saved workouts';

  @override
  String workoutMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get workoutSecondsUnitShort => 'sec';

  @override
  String get workoutRepsUnitShort => 'reps';

  @override
  String get workoutIntensityRest => 'Rest';

  @override
  String get workoutIntensityLight => 'Light';

  @override
  String get workoutIntensityModerate => 'Moderate';

  @override
  String get workoutIntensityHigh => 'High';

  @override
  String workoutTimeAgoMinutes(int count) {
    return '$count min ago';
  }

  @override
  String workoutTimeAgoHours(int count) {
    return '$count h ago';
  }

  @override
  String workoutTimeAgoDays(int count) {
    return '$count d ago';
  }

  @override
  String get workoutSessionTitle => 'Unfinished workout';

  @override
  String get workoutSessionSubtitle => 'You have a saved workout';

  @override
  String workoutSessionSaved(String time) {
    return 'Saved: $time';
  }

  @override
  String get workoutSessionContinue => 'Continue workout';

  @override
  String get workoutSessionNew => 'Start new';

  @override
  String workoutGenerating(String label) {
    return 'Creating \"$label\" workout';
  }

  @override
  String get workoutGeneratingAnalyzingProfile =>
      'Analyzing your profile and today’s status...';

  @override
  String get workoutGeneratingSelectingSafeExercises =>
      'Selecting safe exercises...';

  @override
  String get workoutGeneratingAdaptingIntensity =>
      'Adapting intensity to your condition...';

  @override
  String get workoutGeneratingCreatingProgram =>
      'Building your personalized plan...';

  @override
  String get workoutGeneratingValidatingSafety =>
      'Validating workout safety...';

  @override
  String get workoutCancel => 'Cancel';

  @override
  String get workoutPreviewTitle => 'Your workout';

  @override
  String get workoutPreviewNotFound => 'Workout not found';

  @override
  String get workoutPreviewWarmup => 'Warm-up';

  @override
  String get workoutPreviewMain => 'Main exercises';

  @override
  String get workoutPreviewCooldown => 'Cool-down';

  @override
  String workoutPreviewExercises(int count) {
    return '$count ex.';
  }

  @override
  String get workoutPreviewStart => 'Start workout';

  @override
  String get workoutPlanCreated => 'Workout plan created';

  @override
  String get workoutPlayerTitle => 'Workout';

  @override
  String get workoutPlayerReady => 'Ready to go';

  @override
  String get workoutPlayerWarmup => 'Warm-up';

  @override
  String get workoutPlayerMainPart => 'Main part';

  @override
  String get workoutPlayerCooldown => 'Cool-down';

  @override
  String get workoutPlayerStartWorkout => 'Start workout';

  @override
  String get workoutPlayerSkipExercise => 'Skip exercise';

  @override
  String get workoutPlayerFinishWorkout => 'Finish workout';

  @override
  String get workoutPlayerPainButton => 'Pain / Discomfort';

  @override
  String workoutPlayerExerciseOf(int current, int total) {
    return 'Exercise $current / $total';
  }

  @override
  String get workoutPlayerMinutes => 'MINUTES';

  @override
  String get workoutPlayerSeconds => 'SECONDS';

  @override
  String get workoutPlayerReps => 'REPS';

  @override
  String get workoutPlayerRest => 'Rest';

  @override
  String workoutPlayerRestSeconds(int seconds) {
    return '$seconds sec';
  }

  @override
  String workoutPlayerNextSet(String name) {
    return 'Next: $name';
  }

  @override
  String get workoutPlayerAutoResume =>
      'Exercise will resume automatically after the timer';

  @override
  String get workoutPlayerContinue => 'Continue';

  @override
  String get workoutPlayerAiInsight => 'AI INSIGHT';

  @override
  String get workoutPlayerAiNote => 'AI doctor\'s note';

  @override
  String get workoutPlayerNoDescription => 'No additional description.';

  @override
  String get workoutPlayerAiLocalizedPending =>
      'Adapting AI insight to your language...';

  @override
  String get workoutPlayerAiLocalizedUnavailable =>
      'Localized AI insight is temporarily unavailable.';

  @override
  String get workoutPlayerGotIt => 'Got it';

  @override
  String get workoutPlayerClose => 'Close';

  @override
  String get workoutPlayerExitTitle => 'End workout?';

  @override
  String get workoutPlayerExitMessage => 'Progress will not be saved';

  @override
  String get workoutPlayerExitCancel => 'Cancel';

  @override
  String get workoutPlayerExitConfirm => 'End';

  @override
  String get workoutPlayerSearchUnavailable => 'Video search link unavailable';

  @override
  String get workoutPlayerAnimation => 'Animation';

  @override
  String get painWhereTitle => 'Where does it hurt?';

  @override
  String get painIntensityTitle => 'How much does it hurt?';

  @override
  String get painActionTitle => 'What do we do?';

  @override
  String get painSelectArea => 'Select pain area';

  @override
  String painCurrentExercise(String name) {
    return 'Current exercise: $name';
  }

  @override
  String get painCancelContinue => 'Cancel, continue exercise';

  @override
  String painAreaText(String area) {
    return 'Area: $area';
  }

  @override
  String get painRateIntensity => 'Rate pain intensity';

  @override
  String painLevelText(int level) {
    return 'Pain level: $level/10';
  }

  @override
  String get painLocationLowerBack => 'Lower back';

  @override
  String get painLocationUpperBack => 'Upper back';

  @override
  String get painLocationNeck => 'Neck';

  @override
  String get painLocationKnees => 'Knees';

  @override
  String get painLocationShoulders => 'Shoulders';

  @override
  String get painLocationWrists => 'Wrists';

  @override
  String get painLocationAnkle => 'Ankle';

  @override
  String get painLocationHips => 'Hips';

  @override
  String get painIntensity1 => 'Mild discomfort';

  @override
  String get painIntensity1Sub => 'Barely noticeable';

  @override
  String get painIntensity2 => 'Slight pain';

  @override
  String get painIntensity2Sub => 'Bearable';

  @override
  String get painIntensity3 => 'Minor pain';

  @override
  String get painIntensity3Sub => 'Noticeable but manageable';

  @override
  String get painIntensity4 => 'Moderate pain';

  @override
  String get painIntensity4Sub => 'Distracting';

  @override
  String get painIntensity5 => 'Medium pain';

  @override
  String get painIntensity5Sub => 'Need to adjust technique';

  @override
  String get painIntensity6 => 'Noticeable pain';

  @override
  String get painIntensity6Sub => 'Difficult to continue';

  @override
  String get painIntensity7 => 'Strong pain';

  @override
  String get painIntensity7Sub => 'Need a break';

  @override
  String get painIntensity8 => 'Very strong pain';

  @override
  String get painIntensity8Sub => 'Should stop';

  @override
  String get painIntensity9 => 'Sharp pain';

  @override
  String get painIntensity9Sub => 'Need rest';

  @override
  String get painIntensity10 => 'Unbearable';

  @override
  String get painIntensity10Sub => 'Need medical help';

  @override
  String get painActionLightTitle => 'What would you like to do?';

  @override
  String get painActionLightSubtitle => 'Mild discomfort - you can continue';

  @override
  String get painActionModerateTitle => 'Caution recommended';

  @override
  String get painActionModerateSubtitle =>
      'We recommend replacing the exercise or resting';

  @override
  String get painActionSevereTitle => 'Rest needed';

  @override
  String get painActionSevereSubtitle =>
      'If it hurts a lot, it\'s better to stop or rest';

  @override
  String get painActionDefault => 'Choose an action';

  @override
  String get painContinueExercise => 'Continue exercise';

  @override
  String get painContinueSub => 'Pain is bearable, continuing';

  @override
  String get painReplaceExercise => 'Replace exercise';

  @override
  String get painReplaceSub => 'AI will find a safe alternative';

  @override
  String get painReplaceModSub => 'Recommended for moderate pain';

  @override
  String get painBreak2min => '2-minute break';

  @override
  String get painBreak2minSub => 'Short rest';

  @override
  String get painBreak5min => '5-minute break';

  @override
  String get painBreak5minSub => 'Rest and listen to your body';

  @override
  String get painBreak10min => '10-minute break';

  @override
  String get painBreak10minSub => 'Extended rest with tips';

  @override
  String get painEndWorkout => 'End workout';

  @override
  String get painEndWorkoutSaveSub => 'We\'ll save your progress';

  @override
  String get painEndWorkoutHealthSub => 'Health comes first - rest today';

  @override
  String get painSevereWarning =>
      'If pain is severe, we recommend seeing a doctor';

  @override
  String get painRestTitle => 'Break';

  @override
  String get painRestRemaining => 'remaining';

  @override
  String get painRestTips => 'Rest tips:';

  @override
  String get painRestContinueEarly => 'Continue early';

  @override
  String get painRestTipLight =>
      'Take a deep breath in and out.\nRelax tense muscles.';

  @override
  String get painRestTipModerate =>
      'Gently massage the pain area.\nDrink water and breathe calmly.';

  @override
  String get painRestTipSevere =>
      'Relax completely.\nIf pain doesn\'t subside, see a doctor.';

  @override
  String get painReplacingTitle => 'Finding replacement';

  @override
  String get painReplacingText => 'AI is searching for a safe replacement';

  @override
  String painReplacingArea(String area) {
    return 'Pain area: $area';
  }

  @override
  String get completionTitle => 'Great job!';

  @override
  String completionMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String completionExercises(int count) {
    return '$count ex.';
  }

  @override
  String completionPainReports(int count) {
    return 'Pain reports: $count';
  }

  @override
  String get completionAnalyzing => 'AI is analyzing your workout...';

  @override
  String completionTips(int count) {
    return 'Tips ($count)';
  }

  @override
  String get completionShowAll => 'Show all';

  @override
  String get completionCollapse => 'Collapse';

  @override
  String get completionRecoveryPlan => 'Recovery plan';

  @override
  String get completionRecoveryBrief => 'Brief, without overload';

  @override
  String get completionRecoveryExpand => 'Expand to see the steps';

  @override
  String completionRestDuration(String duration) {
    return 'Rest: $duration';
  }

  @override
  String get completionHideSteps => 'Hide steps';

  @override
  String completionMoreSteps(int count) {
    return 'More steps ($count)';
  }

  @override
  String get completionNutrition => 'Nutrition';

  @override
  String get completionSleep => 'Sleep';

  @override
  String get completionGoHome => 'Go home';

  @override
  String get categoryBack => 'Back';

  @override
  String get categoryLegs => 'Legs';

  @override
  String get categoryArms => 'Arms';

  @override
  String get categoryCore => 'Core';

  @override
  String get categoryNeck => 'Neck';

  @override
  String get categoryGeneral => 'General';

  @override
  String get routeNotFound => 'Page not found';

  @override
  String get checkinSummaryLight => 'Light workout is recommended today.';

  @override
  String get homeOffline =>
      'No internet connection.\\nTry again after reconnecting.';

  @override
  String get onboardingDefaultName => 'User';

  @override
  String get homeUser => 'User';

  @override
  String get profileRestrictions => 'Restrictions';

  @override
  String get settingsConfigureReminders => 'Set reminder time and days';

  @override
  String get navExitPrompt => 'Press \"Back\" again to exit';

  @override
  String get energyVeryHigh => 'Very high';

  @override
  String get checkinNoPain => 'No pain';

  @override
  String get homeLoadingData => 'Loading data...';

  @override
  String get authHintPasswordMin => 'Minimum 6 characters';

  @override
  String get settingsWorkoutReminders => 'Workout reminders';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeProgress => 'Progress';

  @override
  String get checkinNotes => 'Notes';

  @override
  String get homeMinutes => 'Minutes';

  @override
  String get videoSearchAvailable => 'Video available via YouTube search';

  @override
  String get checkinPainLevel => 'Pain level';

  @override
  String get settingsDaysOfWeek => 'Days of the week';

  @override
  String get energyVeryLow => 'Very low';

  @override
  String get settingsRemindersOff => 'Reminders are disabled';

  @override
  String get homeOfflineRetry => 'Retry';

  @override
  String get checkinSummaryRest => 'Rest and recovery are recommended today.';

  @override
  String get homeTotalMinutes => 'Total minutes';

  @override
  String get checkinSymptomsTitle => 'Symptoms';

  @override
  String get profileKg => 'kg';

  @override
  String get settingsPermissionDenied =>
      'Notification permission denied. Enable it in settings.';

  @override
  String get homeStartStreak => 'Start your streak';

  @override
  String get profileCm => 'cm';

  @override
  String get checkinNotesHint => 'Any additional symptoms or comments';

  @override
  String get authHintPasswordRepeat => 'Repeat your password';

  @override
  String get checkinStrongPain => 'Strong pain';

  @override
  String get checkinWhereHurts => 'Where does it hurt?';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String homeStreakDays(int count) {
    return '$count-day streak';
  }

  @override
  String get videoOpenSearch => 'Open search in app';

  @override
  String get checkinToWorkout => 'Go to workout';

  @override
  String get settingsRemindersActive => 'Reminders are enabled';

  @override
  String get navWorkout => 'Workout';

  @override
  String get checkinRedoSurvey => 'Retake survey';

  @override
  String get homeGoodEvening => 'Good evening';

  @override
  String get checkinSummaryGreat => 'Great state. You can do a full workout.';

  @override
  String get checkinBetterRest => 'Better to rest and recover today';

  @override
  String get energyLow => 'Low';

  @override
  String get checkinSleep => 'Sleep';

  @override
  String get checkinSleepQuality => 'Sleep quality';

  @override
  String get videoNetwork => 'Video';

  @override
  String get homeLoadingAnalytics => 'Loading analytics...';

  @override
  String get checkinAlreadyCompleted =>
      'Today\'s check-in is already completed';

  @override
  String get profileYears => 'years';

  @override
  String get navHome => 'Home';

  @override
  String get homeTapForDetailedStats => 'Tap to view detailed stats';

  @override
  String get checkinRecommendation => 'Recommendation';

  @override
  String get settingsEveryDay => 'Every day';

  @override
  String get homeAverage => 'Average';

  @override
  String get checkinMood => 'Mood';

  @override
  String get energyHigh => 'High';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String checkinRecommendedIntensity(String intensity) {
    return 'Recommended intensity: $intensity';
  }

  @override
  String get profileHealthGoals => 'Health & Goals';

  @override
  String get homeGoodAfternoon => 'Good afternoon';

  @override
  String get settingsEnableReminders => 'Enable reminders';

  @override
  String get homeStatistics => 'Statistics';

  @override
  String get checkinSleepBad => 'Poor';

  @override
  String get videoYoutube => 'YouTube video';

  @override
  String get homeThisWeek => 'This week';

  @override
  String get homeReadyForWorkout => 'Ready for today\'s workout?';

  @override
  String get homeGoodMorning => 'Good morning';

  @override
  String get navHistory => 'History';

  @override
  String get checkinTryAgain => 'Try again';

  @override
  String get checkinEnergyLevel => 'Energy level';

  @override
  String get checkinSymptomsDescription => 'Select all symptoms you feel today';

  @override
  String get checkinMoodTitle => 'Your mood';

  @override
  String get profileMyProfile => 'My profile';

  @override
  String get checkinPainDescription => 'Rate your current pain level';

  @override
  String get checkinSleepGreat => 'Great';

  @override
  String get homeWorkouts => 'Workouts';

  @override
  String get homeAiRecommendations => 'AI recommendations';

  @override
  String get checkinMoodDescription => 'How is your emotional state today?';

  @override
  String get checkinMoodHappy => 'Excellent';

  @override
  String get checkinMoodEnergized => 'Energized';

  @override
  String get checkinMoodNeutral => 'Normal';

  @override
  String get checkinMoodTired => 'Tired';

  @override
  String get checkinMoodStressed => 'Stressed';

  @override
  String get checkinSymptomHeadache => 'Headache';

  @override
  String get checkinSymptomBackPain => 'Back pain';

  @override
  String get checkinSymptomMuscleStiffness => 'Muscle stiffness';

  @override
  String get checkinSymptomFatigue => 'Fatigue';

  @override
  String get checkinSymptomNausea => 'Nausea';

  @override
  String get checkinSymptomDizziness => 'Dizziness';

  @override
  String get checkinPainLocationOther => 'Other';

  @override
  String get checkinSummaryModerate => 'Moderate workout is recommended.';

  @override
  String get checkinEnergy => 'Energy';

  @override
  String get settingsWeekdays => 'Weekdays';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get energyMedium => 'Medium';

  @override
  String get settingsEveryOtherDay => 'Every other day';

  @override
  String get profilePersonalData => 'Personal data';

  @override
  String get homeProgressStart => 'Start your progress today';

  @override
  String get videoUnsupported => 'Video unavailable';

  @override
  String get checkinEnergyDescription =>
      'How much energy do you have right now?';

  @override
  String get activityLevelModerate => 'Moderate activity';

  @override
  String get authErrorEmailInvalid => 'Invalid email format';

  @override
  String get authErrorEmailEmpty => 'Enter email';

  @override
  String get injuryMeniscus => 'Meniscus injury';

  @override
  String get injuryProtrusion => 'Disc protrusion';

  @override
  String get injuryWrist => 'Wrist injury';

  @override
  String get injuryKneeArthrosis => 'Knee arthrosis';

  @override
  String get authErrorPasswordEmpty => 'Enter password';

  @override
  String get authErrorPasswordShort => 'Password must be at least 6 characters';

  @override
  String get injuryShoulder => 'Shoulder joint issues';

  @override
  String get injuryScoliosis => 'Scoliosis';

  @override
  String get injuryHernia => 'Lumbar hernia (L4-L5, L5-S1)';

  @override
  String get injuryHipArthrosis => 'Hip arthrosis';

  @override
  String get injuryNeckPain => 'Neck pain';

  @override
  String get injuryOsteochondrosis => 'Osteochondrosis';

  @override
  String get activityLevelSedentary => 'Sedentary lifestyle';

  @override
  String get activityLevelHigh => 'High activity';

  @override
  String get authErrorPasswordConfirm => 'Confirm your password';

  @override
  String get activityLevelLight => 'Light activity';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageHint => 'Choose app language';

  @override
  String get languageKk => 'Kazakh';

  @override
  String get languageRu => 'Russian';

  @override
  String get languageEn => 'English';

  @override
  String get errorNoConnection => 'No internet connection';

  @override
  String get errorTimeout => 'Request timed out. Please try again later.';

  @override
  String get errorAIQuota => 'AI quota exceeded. Please try again later.';

  @override
  String get errorAIUnavailable =>
      'AI service temporarily unavailable. Please try again later.';

  @override
  String get errorAINotConfigured =>
      'AI service not configured. Contact the administrator.';

  @override
  String get errorAIEmpty => 'Empty response from AI. Please try again.';

  @override
  String get errorAIParse => 'Error processing AI response. Please try again.';

  @override
  String get errorGenerateWorkout =>
      'Failed to generate workout. Please try again later.';

  @override
  String get errorSaveCheckin =>
      'Failed to save check-in. Please try again later.';

  @override
  String get errorLoadCheckin =>
      'Failed to load check-in. Check your connection.';

  @override
  String get errorSaveProfile =>
      'Failed to update profile. Please try again later.';

  @override
  String get errorLoadProfile =>
      'Failed to load profile. Check your connection.';

  @override
  String get errorAuthStatus => 'Failed to verify authentication status';

  @override
  String get errorAuthSignIn => 'Failed to sign in. Please try again later.';

  @override
  String get errorAuthSignUp => 'Failed to sign up. Please try again later.';

  @override
  String get errorGeneral => 'An error occurred. Please try again.';

  @override
  String get errorPermissionDenied =>
      'Insufficient permissions for this operation';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get errorInvalidCredentials => 'Invalid login or password';

  @override
  String get errorEmailInUse => 'This email is already registered';

  @override
  String get errorWeakPassword => 'Password must be at least 6 characters';

  @override
  String get errorNotAuthenticated => 'User is not authenticated';
}
