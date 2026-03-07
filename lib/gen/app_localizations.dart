import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('kk'),
    Locale('ru'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AI Health Coach'**
  String get appName;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal trainer'**
  String get splashSubtitle;

  /// No description provided for @onboardingErrorAuth.
  ///
  /// In en, this message translates to:
  /// **'Error: user not authenticated'**
  String get onboardingErrorAuth;

  /// No description provided for @onboardingErrorSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile. Try again later.'**
  String get onboardingErrorSave;

  /// No description provided for @onboardingRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get onboardingRetry;

  /// No description provided for @onboardingBtnBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBtnBack;

  /// No description provided for @onboardingBtnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingBtnNext;

  /// No description provided for @onboardingBtnFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingBtnFinish;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeText.
  ///
  /// In en, this message translates to:
  /// **'Let\'s create your personal health profile so that workouts are safe and effective.'**
  String get onboardingWelcomeText;

  /// No description provided for @onboardingBasicTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get onboardingBasicTitle;

  /// No description provided for @onboardingNameField.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get onboardingNameField;

  /// No description provided for @onboardingGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your gender'**
  String get onboardingGenderTitle;

  /// No description provided for @onboardingGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get onboardingGenderMale;

  /// No description provided for @onboardingGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get onboardingGenderFemale;

  /// No description provided for @onboardingGenderNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get onboardingGenderNotSpecified;

  /// No description provided for @onboardingAgeText.
  ///
  /// In en, this message translates to:
  /// **'Age: {age} years'**
  String onboardingAgeText(int age);

  /// No description provided for @onboardingWeightText.
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight} kg'**
  String onboardingWeightText(String weight);

  /// No description provided for @onboardingActivityLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get onboardingActivityLevelTitle;

  /// No description provided for @onboardingHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Health concerns'**
  String get onboardingHealthTitle;

  /// No description provided for @onboardingHealthText.
  ///
  /// In en, this message translates to:
  /// **'Select everything that applies to you. This will help avoid dangerous exercises.'**
  String get onboardingHealthText;

  /// No description provided for @onboardingHealthInfo.
  ///
  /// In en, this message translates to:
  /// **'If you have no health issues, just tap \"Next\"'**
  String get onboardingHealthInfo;

  /// No description provided for @onboardingGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your goals'**
  String get onboardingGoalsTitle;

  /// No description provided for @onboardingGoalsText.
  ///
  /// In en, this message translates to:
  /// **'What matters most to you right now?'**
  String get onboardingGoalsText;

  /// No description provided for @goalRelieveBackPain.
  ///
  /// In en, this message translates to:
  /// **'Relieve back pain'**
  String get goalRelieveBackPain;

  /// No description provided for @goalStrengthenCore.
  ///
  /// In en, this message translates to:
  /// **'Strengthen core muscles'**
  String get goalStrengthenCore;

  /// No description provided for @goalRecoverFromInjury.
  ///
  /// In en, this message translates to:
  /// **'Recover from injury'**
  String get goalRecoverFromInjury;

  /// No description provided for @goalImproveFlexibility.
  ///
  /// In en, this message translates to:
  /// **'Improve flexibility'**
  String get goalImproveFlexibility;

  /// No description provided for @goalMaintainGeneralTone.
  ///
  /// In en, this message translates to:
  /// **'Maintain general tone'**
  String get goalMaintainGeneralTone;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your workouts'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginRegisterLink;

  /// No description provided for @loginResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link has been sent'**
  String get loginResetSent;

  /// No description provided for @loginFillEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email first'**
  String get loginFillEmail;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to work with your coach'**
  String get registerSubtitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get registerNameLabel;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccount;

  /// No description provided for @registerLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get registerLoginLink;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerPasswordMismatch;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}!'**
  String homeGreeting(String name);

  /// No description provided for @homeGreetingDefault.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get homeGreetingDefault;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get homeSubtitle;

  /// No description provided for @homeStartCheckin.
  ///
  /// In en, this message translates to:
  /// **'Complete daily check-in'**
  String get homeStartCheckin;

  /// No description provided for @homeCheckinDone.
  ///
  /// In en, this message translates to:
  /// **'Check-in completed'**
  String get homeCheckinDone;

  /// No description provided for @homeSectionWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Quick workout'**
  String get homeSectionWorkouts;

  /// No description provided for @homeWorkoutLfk.
  ///
  /// In en, this message translates to:
  /// **'PT'**
  String get homeWorkoutLfk;

  /// No description provided for @homeWorkoutStretching.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get homeWorkoutStretching;

  /// No description provided for @homeWorkoutStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get homeWorkoutStrength;

  /// No description provided for @homeWorkoutCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get homeWorkoutCardio;

  /// No description provided for @homeCheckinNotice.
  ///
  /// In en, this message translates to:
  /// **'Complete the check-in before starting a workout'**
  String get homeCheckinNotice;

  /// No description provided for @homeProfileNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Profile not loaded. Try again later.'**
  String get homeProfileNotLoaded;

  /// No description provided for @checkinTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get checkinTitle;

  /// No description provided for @checkinMoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get checkinMoodLabel;

  /// No description provided for @checkinEnergyLabel.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get checkinEnergyLabel;

  /// No description provided for @checkinPainLabel.
  ///
  /// In en, this message translates to:
  /// **'Pain level'**
  String get checkinPainLabel;

  /// No description provided for @checkinSleepLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep quality'**
  String get checkinSleepLabel;

  /// No description provided for @checkinStressLabel.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get checkinStressLabel;

  /// No description provided for @checkinButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get checkinButton;

  /// No description provided for @checkinMoodHints.
  ///
  /// In en, this message translates to:
  /// **'Terrible;Bad;Normal;Good;Great'**
  String get checkinMoodHints;

  /// No description provided for @checkinEnergyHints.
  ///
  /// In en, this message translates to:
  /// **'Very low;Low;Normal;High;Full of energy'**
  String get checkinEnergyHints;

  /// No description provided for @checkinPainHints.
  ///
  /// In en, this message translates to:
  /// **'Very strong;Strong;Moderate;Mild;None'**
  String get checkinPainHints;

  /// No description provided for @checkinSleepHints.
  ///
  /// In en, this message translates to:
  /// **'Very bad;Bad;Normal;Good;Excellent'**
  String get checkinSleepHints;

  /// No description provided for @checkinStressHints.
  ///
  /// In en, this message translates to:
  /// **'Very high;High;Moderate;Low;None'**
  String get checkinStressHints;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyTabStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get historyTabStats;

  /// No description provided for @historyTabWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get historyTabWorkouts;

  /// No description provided for @historyWeekChart.
  ///
  /// In en, this message translates to:
  /// **'Workouts this week'**
  String get historyWeekChart;

  /// No description provided for @historyWorkoutsCount.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get historyWorkoutsCount;

  /// No description provided for @historyTotalMinutes.
  ///
  /// In en, this message translates to:
  /// **'Total minutes'**
  String get historyTotalMinutes;

  /// No description provided for @historyByType.
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get historyByType;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'History is empty'**
  String get historyEmpty;

  /// No description provided for @historyLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading history...'**
  String get historyLoading;

  /// No description provided for @historyOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.\nTry again after connecting.'**
  String get historyOffline;

  /// No description provided for @historyOfflineRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get historyOfflineRetry;

  /// No description provided for @historyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get historyLoadError;

  /// No description provided for @historyRecentWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get historyRecentWorkouts;

  /// No description provided for @historyTabWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get historyTabWeek;

  /// No description provided for @historyTabMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get historyTabMonth;

  /// No description provided for @historyWorkoutsLabel.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get historyWorkoutsLabel;

  /// No description provided for @historyMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get historyMinutesLabel;

  /// No description provided for @historyTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout types'**
  String get historyTypesTitle;

  /// No description provided for @historyMinShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get historyMinShort;

  /// No description provided for @historyTypeLfk.
  ///
  /// In en, this message translates to:
  /// **'PT'**
  String get historyTypeLfk;

  /// No description provided for @historyTypeStretching.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get historyTypeStretching;

  /// No description provided for @historyTypeStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get historyTypeStrength;

  /// No description provided for @historyTypeCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get historyTypeCardio;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsTooltip;

  /// No description provided for @profileSectionPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal info'**
  String get profileSectionPersonal;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileAgeValue.
  ///
  /// In en, this message translates to:
  /// **'{age} years'**
  String profileAgeValue(int age);

  /// No description provided for @profileHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get profileHeight;

  /// No description provided for @profileHeightValue.
  ///
  /// In en, this message translates to:
  /// **'{height} cm'**
  String profileHeightValue(String height);

  /// No description provided for @profileWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get profileWeight;

  /// No description provided for @profileWeightValue.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String profileWeightValue(String weight);

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileSectionHealth.
  ///
  /// In en, this message translates to:
  /// **'Health & Goals'**
  String get profileSectionHealth;

  /// No description provided for @profileActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get profileActivity;

  /// No description provided for @profileGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get profileGoal;

  /// No description provided for @profileLimitations.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get profileLimitations;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileLogout;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get profileLoadError;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get profileNotFound;

  /// No description provided for @profileNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete the survey or refresh the screen.'**
  String get profileNotFoundMessage;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get profileLoading;

  /// No description provided for @profileOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.\nTry again after connecting to the network.'**
  String get profileOffline;

  /// No description provided for @profileRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get profileRetry;

  /// No description provided for @profileGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileGenderMale;

  /// No description provided for @profileGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profileGenderFemale;

  /// No description provided for @profileGenderNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get profileGenderNotSpecified;

  /// No description provided for @profileActivityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get profileActivityLow;

  /// No description provided for @profileActivityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get profileActivityModerate;

  /// No description provided for @profileActivityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get profileActivityHigh;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileSectionBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get editProfileSectionBasic;

  /// No description provided for @editProfileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editProfileNameLabel;

  /// No description provided for @editProfileGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get editProfileGenderLabel;

  /// No description provided for @editProfileGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get editProfileGenderMale;

  /// No description provided for @editProfileGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get editProfileGenderFemale;

  /// No description provided for @editProfileGenderNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get editProfileGenderNotSpecified;

  /// No description provided for @editProfileSectionPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical parameters'**
  String get editProfileSectionPhysical;

  /// No description provided for @editProfileAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get editProfileAgeLabel;

  /// No description provided for @editProfileHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get editProfileHeightLabel;

  /// No description provided for @editProfileWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get editProfileWeightLabel;

  /// No description provided for @editProfileSectionGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals & Activity'**
  String get editProfileSectionGoals;

  /// No description provided for @editProfileActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get editProfileActivityLabel;

  /// No description provided for @editProfileActivityLow.
  ///
  /// In en, this message translates to:
  /// **'Low (sedentary)'**
  String get editProfileActivityLow;

  /// No description provided for @editProfileActivityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate (1-3 workouts)'**
  String get editProfileActivityModerate;

  /// No description provided for @editProfileActivityHigh.
  ///
  /// In en, this message translates to:
  /// **'High (3+ workouts)'**
  String get editProfileActivityHigh;

  /// No description provided for @editProfileGoalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get editProfileGoalsLabel;

  /// No description provided for @editProfileSectionInjuries.
  ///
  /// In en, this message translates to:
  /// **'Injuries & limitations'**
  String get editProfileSectionInjuries;

  /// No description provided for @editProfileAddInjuryLabel.
  ///
  /// In en, this message translates to:
  /// **'Add injury/limitation'**
  String get editProfileAddInjuryLabel;

  /// No description provided for @editProfileAddInjuryHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: knee pain'**
  String get editProfileAddInjuryHint;

  /// No description provided for @editProfileAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get editProfileAddButton;

  /// No description provided for @editProfileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get editProfileCancel;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editProfileSave;

  /// No description provided for @editProfileValidateName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get editProfileValidateName;

  /// No description provided for @editProfileValidateNameLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at most {max} characters'**
  String editProfileValidateNameLength(int max);

  /// No description provided for @editProfileValidateAge.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age'**
  String get editProfileValidateAge;

  /// No description provided for @editProfileValidateAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Age {min}-{max}'**
  String editProfileValidateAgeRange(int min, int max);

  /// No description provided for @editProfileValidateHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid height'**
  String get editProfileValidateHeight;

  /// No description provided for @editProfileValidateHeightRange.
  ///
  /// In en, this message translates to:
  /// **'Height {min}-{max} cm'**
  String editProfileValidateHeightRange(int min, int max);

  /// No description provided for @editProfileValidateWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight'**
  String get editProfileValidateWeight;

  /// No description provided for @editProfileValidateWeightRange.
  ///
  /// In en, this message translates to:
  /// **'Weight {min}-{max} kg'**
  String editProfileValidateWeightRange(int min, int max);

  /// No description provided for @editProfileValidateGoalsLength.
  ///
  /// In en, this message translates to:
  /// **'Goal must be at most {max} characters'**
  String editProfileValidateGoalsLength(int max);

  /// No description provided for @editProfileInjuryTooLong.
  ///
  /// In en, this message translates to:
  /// **'Limitation must be at most {max} characters'**
  String editProfileInjuryTooLong(int max);

  /// No description provided for @editProfileMaxInjuries.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {max} limitations'**
  String editProfileMaxInjuries(int max);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout reminders'**
  String get settingsReminderTitle;

  /// No description provided for @settingsReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set reminder time and days'**
  String get settingsReminderSubtitle;

  /// No description provided for @settingsReminderEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable reminders'**
  String get settingsReminderEnable;

  /// No description provided for @settingsReminderActive.
  ///
  /// In en, this message translates to:
  /// **'Reminders enabled'**
  String get settingsReminderActive;

  /// No description provided for @settingsReminderInactive.
  ///
  /// In en, this message translates to:
  /// **'Reminders disabled'**
  String get settingsReminderInactive;

  /// No description provided for @settingsReminderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied. Enable it in device settings.'**
  String get settingsReminderPermissionDenied;

  /// No description provided for @settingsTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsTimeTitle;

  /// No description provided for @settingsDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Days of the week'**
  String get settingsDaysTitle;

  /// No description provided for @settingsPresetWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get settingsPresetWeekdays;

  /// No description provided for @settingsPresetEveryday.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get settingsPresetEveryday;

  /// No description provided for @settingsPresetAlternate.
  ///
  /// In en, this message translates to:
  /// **'Alternate days'**
  String get settingsPresetAlternate;

  /// No description provided for @settingsDayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get settingsDayMon;

  /// No description provided for @settingsDaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get settingsDaySun;

  /// No description provided for @settingsDayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get settingsDayTue;

  /// No description provided for @settingsDayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get settingsDayWed;

  /// No description provided for @settingsDayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get settingsDayThu;

  /// No description provided for @settingsDayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get settingsDayFri;

  /// No description provided for @settingsDaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get settingsDaySat;

  /// No description provided for @workoutSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose workout'**
  String get workoutSelectionTitle;

  /// No description provided for @workoutSelectionQuestion.
  ///
  /// In en, this message translates to:
  /// **'What workout would you like today?'**
  String get workoutSelectionQuestion;

  /// No description provided for @workoutSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a type and AI will create a personal program'**
  String get workoutSelectionHint;

  /// No description provided for @workoutTypeLfk.
  ///
  /// In en, this message translates to:
  /// **'PT'**
  String get workoutTypeLfk;

  /// No description provided for @workoutTypeStretching.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get workoutTypeStretching;

  /// No description provided for @workoutTypeStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get workoutTypeStrength;

  /// No description provided for @workoutTypeCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get workoutTypeCardio;

  /// No description provided for @workoutDescLfk.
  ///
  /// In en, this message translates to:
  /// **'Physical therapy for recovery'**
  String get workoutDescLfk;

  /// No description provided for @workoutDescStretching.
  ///
  /// In en, this message translates to:
  /// **'Flexibility and stretching exercises'**
  String get workoutDescStretching;

  /// No description provided for @workoutDescStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength exercises to build muscle'**
  String get workoutDescStrength;

  /// No description provided for @workoutDescCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio for endurance'**
  String get workoutDescCardio;

  /// No description provided for @workoutRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get workoutRetry;

  /// No description provided for @workoutProfileNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Profile not loaded. Try again later.'**
  String get workoutProfileNotLoaded;

  /// No description provided for @workoutCheckinRequired.
  ///
  /// In en, this message translates to:
  /// **'Complete the health check-in first'**
  String get workoutCheckinRequired;

  /// No description provided for @workoutSavedWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Saved workouts'**
  String get workoutSavedWorkouts;

  /// No description provided for @workoutMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String workoutMinutesShort(int minutes);

  /// No description provided for @workoutSecondsUnitShort.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get workoutSecondsUnitShort;

  /// No description provided for @workoutRepsUnitShort.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get workoutRepsUnitShort;

  /// No description provided for @workoutIntensityRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get workoutIntensityRest;

  /// No description provided for @workoutIntensityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get workoutIntensityLight;

  /// No description provided for @workoutIntensityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get workoutIntensityModerate;

  /// No description provided for @workoutIntensityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get workoutIntensityHigh;

  /// No description provided for @workoutTimeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String workoutTimeAgoMinutes(int count);

  /// No description provided for @workoutTimeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String workoutTimeAgoHours(int count);

  /// No description provided for @workoutTimeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String workoutTimeAgoDays(int count);

  /// No description provided for @workoutSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Unfinished workout'**
  String get workoutSessionTitle;

  /// No description provided for @workoutSessionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have a saved workout'**
  String get workoutSessionSubtitle;

  /// No description provided for @workoutSessionSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved: {time}'**
  String workoutSessionSaved(String time);

  /// No description provided for @workoutSessionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue workout'**
  String get workoutSessionContinue;

  /// No description provided for @workoutSessionNew.
  ///
  /// In en, this message translates to:
  /// **'Start new'**
  String get workoutSessionNew;

  /// No description provided for @workoutGenerating.
  ///
  /// In en, this message translates to:
  /// **'Creating \"{label}\" workout'**
  String workoutGenerating(String label);

  /// No description provided for @workoutGeneratingAnalyzingProfile.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your profile and today’s status...'**
  String get workoutGeneratingAnalyzingProfile;

  /// No description provided for @workoutGeneratingSelectingSafeExercises.
  ///
  /// In en, this message translates to:
  /// **'Selecting safe exercises...'**
  String get workoutGeneratingSelectingSafeExercises;

  /// No description provided for @workoutGeneratingAdaptingIntensity.
  ///
  /// In en, this message translates to:
  /// **'Adapting intensity to your condition...'**
  String get workoutGeneratingAdaptingIntensity;

  /// No description provided for @workoutGeneratingCreatingProgram.
  ///
  /// In en, this message translates to:
  /// **'Building your personalized plan...'**
  String get workoutGeneratingCreatingProgram;

  /// No description provided for @workoutGeneratingValidatingSafety.
  ///
  /// In en, this message translates to:
  /// **'Validating workout safety...'**
  String get workoutGeneratingValidatingSafety;

  /// No description provided for @workoutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get workoutCancel;

  /// No description provided for @workoutPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your workout'**
  String get workoutPreviewTitle;

  /// No description provided for @workoutPreviewNotFound.
  ///
  /// In en, this message translates to:
  /// **'Workout not found'**
  String get workoutPreviewNotFound;

  /// No description provided for @workoutPreviewWarmup.
  ///
  /// In en, this message translates to:
  /// **'Warm-up'**
  String get workoutPreviewWarmup;

  /// No description provided for @workoutPreviewMain.
  ///
  /// In en, this message translates to:
  /// **'Main exercises'**
  String get workoutPreviewMain;

  /// No description provided for @workoutPreviewCooldown.
  ///
  /// In en, this message translates to:
  /// **'Cool-down'**
  String get workoutPreviewCooldown;

  /// No description provided for @workoutPreviewExercises.
  ///
  /// In en, this message translates to:
  /// **'{count} ex.'**
  String workoutPreviewExercises(int count);

  /// No description provided for @workoutPreviewStart.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get workoutPreviewStart;

  /// No description provided for @workoutPlanCreated.
  ///
  /// In en, this message translates to:
  /// **'Workout plan created'**
  String get workoutPlanCreated;

  /// No description provided for @workoutPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutPlayerTitle;

  /// No description provided for @workoutPlayerReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to go'**
  String get workoutPlayerReady;

  /// No description provided for @workoutPlayerWarmup.
  ///
  /// In en, this message translates to:
  /// **'Warm-up'**
  String get workoutPlayerWarmup;

  /// No description provided for @workoutPlayerMainPart.
  ///
  /// In en, this message translates to:
  /// **'Main part'**
  String get workoutPlayerMainPart;

  /// No description provided for @workoutPlayerCooldown.
  ///
  /// In en, this message translates to:
  /// **'Cool-down'**
  String get workoutPlayerCooldown;

  /// No description provided for @workoutPlayerStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get workoutPlayerStartWorkout;

  /// No description provided for @workoutPlayerSkipExercise.
  ///
  /// In en, this message translates to:
  /// **'Skip exercise'**
  String get workoutPlayerSkipExercise;

  /// No description provided for @workoutPlayerFinishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish workout'**
  String get workoutPlayerFinishWorkout;

  /// No description provided for @workoutPlayerPainButton.
  ///
  /// In en, this message translates to:
  /// **'Pain / Discomfort'**
  String get workoutPlayerPainButton;

  /// No description provided for @workoutPlayerExerciseOf.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} / {total}'**
  String workoutPlayerExerciseOf(int current, int total);

  /// No description provided for @workoutPlayerMinutes.
  ///
  /// In en, this message translates to:
  /// **'MINUTES'**
  String get workoutPlayerMinutes;

  /// No description provided for @workoutPlayerSeconds.
  ///
  /// In en, this message translates to:
  /// **'SECONDS'**
  String get workoutPlayerSeconds;

  /// No description provided for @workoutPlayerReps.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get workoutPlayerReps;

  /// No description provided for @workoutPlayerRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get workoutPlayerRest;

  /// No description provided for @workoutPlayerRestSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} sec'**
  String workoutPlayerRestSeconds(int seconds);

  /// No description provided for @workoutPlayerNextSet.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String workoutPlayerNextSet(String name);

  /// No description provided for @workoutPlayerAutoResume.
  ///
  /// In en, this message translates to:
  /// **'Exercise will resume automatically after the timer'**
  String get workoutPlayerAutoResume;

  /// No description provided for @workoutPlayerContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get workoutPlayerContinue;

  /// No description provided for @workoutPlayerAiInsight.
  ///
  /// In en, this message translates to:
  /// **'AI INSIGHT'**
  String get workoutPlayerAiInsight;

  /// No description provided for @workoutPlayerAiNote.
  ///
  /// In en, this message translates to:
  /// **'AI doctor\'s note'**
  String get workoutPlayerAiNote;

  /// No description provided for @workoutPlayerNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No additional description.'**
  String get workoutPlayerNoDescription;

  /// No description provided for @workoutPlayerAiLocalizedPending.
  ///
  /// In en, this message translates to:
  /// **'Adapting AI insight to your language...'**
  String get workoutPlayerAiLocalizedPending;

  /// No description provided for @workoutPlayerAiLocalizedUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Localized AI insight is temporarily unavailable.'**
  String get workoutPlayerAiLocalizedUnavailable;

  /// No description provided for @workoutPlayerGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get workoutPlayerGotIt;

  /// No description provided for @workoutPlayerClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get workoutPlayerClose;

  /// No description provided for @workoutPlayerExitTitle.
  ///
  /// In en, this message translates to:
  /// **'End workout?'**
  String get workoutPlayerExitTitle;

  /// No description provided for @workoutPlayerExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Progress will not be saved'**
  String get workoutPlayerExitMessage;

  /// No description provided for @workoutPlayerExitCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get workoutPlayerExitCancel;

  /// No description provided for @workoutPlayerExitConfirm.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get workoutPlayerExitConfirm;

  /// No description provided for @workoutPlayerSearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Video search link unavailable'**
  String get workoutPlayerSearchUnavailable;

  /// No description provided for @workoutPlayerAnimation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get workoutPlayerAnimation;

  /// No description provided for @painWhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Where does it hurt?'**
  String get painWhereTitle;

  /// No description provided for @painIntensityTitle.
  ///
  /// In en, this message translates to:
  /// **'How much does it hurt?'**
  String get painIntensityTitle;

  /// No description provided for @painActionTitle.
  ///
  /// In en, this message translates to:
  /// **'What do we do?'**
  String get painActionTitle;

  /// No description provided for @painSelectArea.
  ///
  /// In en, this message translates to:
  /// **'Select pain area'**
  String get painSelectArea;

  /// No description provided for @painCurrentExercise.
  ///
  /// In en, this message translates to:
  /// **'Current exercise: {name}'**
  String painCurrentExercise(String name);

  /// No description provided for @painCancelContinue.
  ///
  /// In en, this message translates to:
  /// **'Cancel, continue exercise'**
  String get painCancelContinue;

  /// No description provided for @painAreaText.
  ///
  /// In en, this message translates to:
  /// **'Area: {area}'**
  String painAreaText(String area);

  /// No description provided for @painRateIntensity.
  ///
  /// In en, this message translates to:
  /// **'Rate pain intensity'**
  String get painRateIntensity;

  /// No description provided for @painLevelText.
  ///
  /// In en, this message translates to:
  /// **'Pain level: {level}/10'**
  String painLevelText(int level);

  /// No description provided for @painLocationLowerBack.
  ///
  /// In en, this message translates to:
  /// **'Lower back'**
  String get painLocationLowerBack;

  /// No description provided for @painLocationUpperBack.
  ///
  /// In en, this message translates to:
  /// **'Upper back'**
  String get painLocationUpperBack;

  /// No description provided for @painLocationNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get painLocationNeck;

  /// No description provided for @painLocationKnees.
  ///
  /// In en, this message translates to:
  /// **'Knees'**
  String get painLocationKnees;

  /// No description provided for @painLocationShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get painLocationShoulders;

  /// No description provided for @painLocationWrists.
  ///
  /// In en, this message translates to:
  /// **'Wrists'**
  String get painLocationWrists;

  /// No description provided for @painLocationAnkle.
  ///
  /// In en, this message translates to:
  /// **'Ankle'**
  String get painLocationAnkle;

  /// No description provided for @painLocationHips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get painLocationHips;

  /// No description provided for @painIntensity1.
  ///
  /// In en, this message translates to:
  /// **'Mild discomfort'**
  String get painIntensity1;

  /// No description provided for @painIntensity1Sub.
  ///
  /// In en, this message translates to:
  /// **'Barely noticeable'**
  String get painIntensity1Sub;

  /// No description provided for @painIntensity2.
  ///
  /// In en, this message translates to:
  /// **'Slight pain'**
  String get painIntensity2;

  /// No description provided for @painIntensity2Sub.
  ///
  /// In en, this message translates to:
  /// **'Bearable'**
  String get painIntensity2Sub;

  /// No description provided for @painIntensity3.
  ///
  /// In en, this message translates to:
  /// **'Minor pain'**
  String get painIntensity3;

  /// No description provided for @painIntensity3Sub.
  ///
  /// In en, this message translates to:
  /// **'Noticeable but manageable'**
  String get painIntensity3Sub;

  /// No description provided for @painIntensity4.
  ///
  /// In en, this message translates to:
  /// **'Moderate pain'**
  String get painIntensity4;

  /// No description provided for @painIntensity4Sub.
  ///
  /// In en, this message translates to:
  /// **'Distracting'**
  String get painIntensity4Sub;

  /// No description provided for @painIntensity5.
  ///
  /// In en, this message translates to:
  /// **'Medium pain'**
  String get painIntensity5;

  /// No description provided for @painIntensity5Sub.
  ///
  /// In en, this message translates to:
  /// **'Need to adjust technique'**
  String get painIntensity5Sub;

  /// No description provided for @painIntensity6.
  ///
  /// In en, this message translates to:
  /// **'Noticeable pain'**
  String get painIntensity6;

  /// No description provided for @painIntensity6Sub.
  ///
  /// In en, this message translates to:
  /// **'Difficult to continue'**
  String get painIntensity6Sub;

  /// No description provided for @painIntensity7.
  ///
  /// In en, this message translates to:
  /// **'Strong pain'**
  String get painIntensity7;

  /// No description provided for @painIntensity7Sub.
  ///
  /// In en, this message translates to:
  /// **'Need a break'**
  String get painIntensity7Sub;

  /// No description provided for @painIntensity8.
  ///
  /// In en, this message translates to:
  /// **'Very strong pain'**
  String get painIntensity8;

  /// No description provided for @painIntensity8Sub.
  ///
  /// In en, this message translates to:
  /// **'Should stop'**
  String get painIntensity8Sub;

  /// No description provided for @painIntensity9.
  ///
  /// In en, this message translates to:
  /// **'Sharp pain'**
  String get painIntensity9;

  /// No description provided for @painIntensity9Sub.
  ///
  /// In en, this message translates to:
  /// **'Need rest'**
  String get painIntensity9Sub;

  /// No description provided for @painIntensity10.
  ///
  /// In en, this message translates to:
  /// **'Unbearable'**
  String get painIntensity10;

  /// No description provided for @painIntensity10Sub.
  ///
  /// In en, this message translates to:
  /// **'Need medical help'**
  String get painIntensity10Sub;

  /// No description provided for @painActionLightTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get painActionLightTitle;

  /// No description provided for @painActionLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mild discomfort - you can continue'**
  String get painActionLightSubtitle;

  /// No description provided for @painActionModerateTitle.
  ///
  /// In en, this message translates to:
  /// **'Caution recommended'**
  String get painActionModerateTitle;

  /// No description provided for @painActionModerateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We recommend replacing the exercise or resting'**
  String get painActionModerateSubtitle;

  /// No description provided for @painActionSevereTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest needed'**
  String get painActionSevereTitle;

  /// No description provided for @painActionSevereSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If it hurts a lot, it\'s better to stop or rest'**
  String get painActionSevereSubtitle;

  /// No description provided for @painActionDefault.
  ///
  /// In en, this message translates to:
  /// **'Choose an action'**
  String get painActionDefault;

  /// No description provided for @painContinueExercise.
  ///
  /// In en, this message translates to:
  /// **'Continue exercise'**
  String get painContinueExercise;

  /// No description provided for @painContinueSub.
  ///
  /// In en, this message translates to:
  /// **'Pain is bearable, continuing'**
  String get painContinueSub;

  /// No description provided for @painReplaceExercise.
  ///
  /// In en, this message translates to:
  /// **'Replace exercise'**
  String get painReplaceExercise;

  /// No description provided for @painReplaceSub.
  ///
  /// In en, this message translates to:
  /// **'AI will find a safe alternative'**
  String get painReplaceSub;

  /// No description provided for @painReplaceModSub.
  ///
  /// In en, this message translates to:
  /// **'Recommended for moderate pain'**
  String get painReplaceModSub;

  /// No description provided for @painBreak2min.
  ///
  /// In en, this message translates to:
  /// **'2-minute break'**
  String get painBreak2min;

  /// No description provided for @painBreak2minSub.
  ///
  /// In en, this message translates to:
  /// **'Short rest'**
  String get painBreak2minSub;

  /// No description provided for @painBreak5min.
  ///
  /// In en, this message translates to:
  /// **'5-minute break'**
  String get painBreak5min;

  /// No description provided for @painBreak5minSub.
  ///
  /// In en, this message translates to:
  /// **'Rest and listen to your body'**
  String get painBreak5minSub;

  /// No description provided for @painBreak10min.
  ///
  /// In en, this message translates to:
  /// **'10-minute break'**
  String get painBreak10min;

  /// No description provided for @painBreak10minSub.
  ///
  /// In en, this message translates to:
  /// **'Extended rest with tips'**
  String get painBreak10minSub;

  /// No description provided for @painEndWorkout.
  ///
  /// In en, this message translates to:
  /// **'End workout'**
  String get painEndWorkout;

  /// No description provided for @painEndWorkoutSaveSub.
  ///
  /// In en, this message translates to:
  /// **'We\'ll save your progress'**
  String get painEndWorkoutSaveSub;

  /// No description provided for @painEndWorkoutHealthSub.
  ///
  /// In en, this message translates to:
  /// **'Health comes first - rest today'**
  String get painEndWorkoutHealthSub;

  /// No description provided for @painSevereWarning.
  ///
  /// In en, this message translates to:
  /// **'If pain is severe, we recommend seeing a doctor'**
  String get painSevereWarning;

  /// No description provided for @painRestTitle.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get painRestTitle;

  /// No description provided for @painRestRemaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get painRestRemaining;

  /// No description provided for @painRestTips.
  ///
  /// In en, this message translates to:
  /// **'Rest tips:'**
  String get painRestTips;

  /// No description provided for @painRestContinueEarly.
  ///
  /// In en, this message translates to:
  /// **'Continue early'**
  String get painRestContinueEarly;

  /// No description provided for @painRestTipLight.
  ///
  /// In en, this message translates to:
  /// **'Take a deep breath in and out.\nRelax tense muscles.'**
  String get painRestTipLight;

  /// No description provided for @painRestTipModerate.
  ///
  /// In en, this message translates to:
  /// **'Gently massage the pain area.\nDrink water and breathe calmly.'**
  String get painRestTipModerate;

  /// No description provided for @painRestTipSevere.
  ///
  /// In en, this message translates to:
  /// **'Relax completely.\nIf pain doesn\'t subside, see a doctor.'**
  String get painRestTipSevere;

  /// No description provided for @painReplacingTitle.
  ///
  /// In en, this message translates to:
  /// **'Finding replacement'**
  String get painReplacingTitle;

  /// No description provided for @painReplacingText.
  ///
  /// In en, this message translates to:
  /// **'AI is searching for a safe replacement'**
  String get painReplacingText;

  /// No description provided for @painReplacingArea.
  ///
  /// In en, this message translates to:
  /// **'Pain area: {area}'**
  String painReplacingArea(String area);

  /// No description provided for @completionTitle.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get completionTitle;

  /// No description provided for @completionMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String completionMinutes(int minutes);

  /// No description provided for @completionExercises.
  ///
  /// In en, this message translates to:
  /// **'{count} ex.'**
  String completionExercises(int count);

  /// No description provided for @completionPainReports.
  ///
  /// In en, this message translates to:
  /// **'Pain reports: {count}'**
  String completionPainReports(int count);

  /// No description provided for @completionAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing your workout...'**
  String get completionAnalyzing;

  /// No description provided for @completionTips.
  ///
  /// In en, this message translates to:
  /// **'Tips ({count})'**
  String completionTips(int count);

  /// No description provided for @completionShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get completionShowAll;

  /// No description provided for @completionCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get completionCollapse;

  /// No description provided for @completionRecoveryPlan.
  ///
  /// In en, this message translates to:
  /// **'Recovery plan'**
  String get completionRecoveryPlan;

  /// No description provided for @completionRecoveryBrief.
  ///
  /// In en, this message translates to:
  /// **'Brief, without overload'**
  String get completionRecoveryBrief;

  /// No description provided for @completionRecoveryExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand to see the steps'**
  String get completionRecoveryExpand;

  /// No description provided for @completionRestDuration.
  ///
  /// In en, this message translates to:
  /// **'Rest: {duration}'**
  String completionRestDuration(String duration);

  /// No description provided for @completionHideSteps.
  ///
  /// In en, this message translates to:
  /// **'Hide steps'**
  String get completionHideSteps;

  /// No description provided for @completionMoreSteps.
  ///
  /// In en, this message translates to:
  /// **'More steps ({count})'**
  String completionMoreSteps(int count);

  /// No description provided for @completionNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get completionNutrition;

  /// No description provided for @completionSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get completionSleep;

  /// No description provided for @completionGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get completionGoHome;

  /// No description provided for @categoryBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get categoryBack;

  /// No description provided for @categoryLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get categoryLegs;

  /// No description provided for @categoryArms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get categoryArms;

  /// No description provided for @categoryCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get categoryCore;

  /// No description provided for @categoryNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get categoryNeck;

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get routeNotFound;

  /// No description provided for @checkinSummaryLight.
  ///
  /// In en, this message translates to:
  /// **'Light workout is recommended today.'**
  String get checkinSummaryLight;

  /// No description provided for @homeOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.\\nTry again after reconnecting.'**
  String get homeOffline;

  /// No description provided for @onboardingDefaultName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get onboardingDefaultName;

  /// No description provided for @homeUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get homeUser;

  /// No description provided for @profileRestrictions.
  ///
  /// In en, this message translates to:
  /// **'Restrictions'**
  String get profileRestrictions;

  /// No description provided for @settingsConfigureReminders.
  ///
  /// In en, this message translates to:
  /// **'Set reminder time and days'**
  String get settingsConfigureReminders;

  /// No description provided for @navExitPrompt.
  ///
  /// In en, this message translates to:
  /// **'Press \"Back\" again to exit'**
  String get navExitPrompt;

  /// No description provided for @energyVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get energyVeryHigh;

  /// No description provided for @checkinNoPain.
  ///
  /// In en, this message translates to:
  /// **'No pain'**
  String get checkinNoPain;

  /// No description provided for @homeLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get homeLoadingData;

  /// No description provided for @authHintPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get authHintPasswordMin;

  /// No description provided for @settingsWorkoutReminders.
  ///
  /// In en, this message translates to:
  /// **'Workout reminders'**
  String get settingsWorkoutReminders;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get homeProgress;

  /// No description provided for @checkinNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get checkinNotes;

  /// No description provided for @homeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get homeMinutes;

  /// No description provided for @videoSearchAvailable.
  ///
  /// In en, this message translates to:
  /// **'Video available via YouTube search'**
  String get videoSearchAvailable;

  /// No description provided for @checkinPainLevel.
  ///
  /// In en, this message translates to:
  /// **'Pain level'**
  String get checkinPainLevel;

  /// No description provided for @settingsDaysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Days of the week'**
  String get settingsDaysOfWeek;

  /// No description provided for @energyVeryLow.
  ///
  /// In en, this message translates to:
  /// **'Very low'**
  String get energyVeryLow;

  /// No description provided for @settingsRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders are disabled'**
  String get settingsRemindersOff;

  /// No description provided for @homeOfflineRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get homeOfflineRetry;

  /// No description provided for @checkinSummaryRest.
  ///
  /// In en, this message translates to:
  /// **'Rest and recovery are recommended today.'**
  String get checkinSummaryRest;

  /// No description provided for @homeTotalMinutes.
  ///
  /// In en, this message translates to:
  /// **'Total minutes'**
  String get homeTotalMinutes;

  /// No description provided for @checkinSymptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get checkinSymptomsTitle;

  /// No description provided for @profileKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get profileKg;

  /// No description provided for @settingsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied. Enable it in settings.'**
  String get settingsPermissionDenied;

  /// No description provided for @homeStartStreak.
  ///
  /// In en, this message translates to:
  /// **'Start your streak'**
  String get homeStartStreak;

  /// No description provided for @profileCm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get profileCm;

  /// No description provided for @checkinNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any additional symptoms or comments'**
  String get checkinNotesHint;

  /// No description provided for @authHintPasswordRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get authHintPasswordRepeat;

  /// No description provided for @checkinStrongPain.
  ///
  /// In en, this message translates to:
  /// **'Strong pain'**
  String get checkinStrongPain;

  /// No description provided for @checkinWhereHurts.
  ///
  /// In en, this message translates to:
  /// **'Where does it hurt?'**
  String get checkinWhereHurts;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActions;

  /// No description provided for @homeStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String homeStreakDays(int count);

  /// No description provided for @videoOpenSearch.
  ///
  /// In en, this message translates to:
  /// **'Open search in app'**
  String get videoOpenSearch;

  /// No description provided for @checkinToWorkout.
  ///
  /// In en, this message translates to:
  /// **'Go to workout'**
  String get checkinToWorkout;

  /// No description provided for @settingsRemindersActive.
  ///
  /// In en, this message translates to:
  /// **'Reminders are enabled'**
  String get settingsRemindersActive;

  /// No description provided for @navWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get navWorkout;

  /// No description provided for @checkinRedoSurvey.
  ///
  /// In en, this message translates to:
  /// **'Retake survey'**
  String get checkinRedoSurvey;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGoodEvening;

  /// No description provided for @checkinSummaryGreat.
  ///
  /// In en, this message translates to:
  /// **'Great state. You can do a full workout.'**
  String get checkinSummaryGreat;

  /// No description provided for @checkinBetterRest.
  ///
  /// In en, this message translates to:
  /// **'Better to rest and recover today'**
  String get checkinBetterRest;

  /// No description provided for @energyLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get energyLow;

  /// No description provided for @checkinSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get checkinSleep;

  /// No description provided for @checkinSleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep quality'**
  String get checkinSleepQuality;

  /// No description provided for @videoNetwork.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoNetwork;

  /// No description provided for @homeLoadingAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Loading analytics...'**
  String get homeLoadingAnalytics;

  /// No description provided for @checkinAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Today\'s check-in is already completed'**
  String get checkinAlreadyCompleted;

  /// No description provided for @profileYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get profileYears;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @homeTapForDetailedStats.
  ///
  /// In en, this message translates to:
  /// **'Tap to view detailed stats'**
  String get homeTapForDetailedStats;

  /// No description provided for @checkinRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get checkinRecommendation;

  /// No description provided for @settingsEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get settingsEveryDay;

  /// No description provided for @homeAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get homeAverage;

  /// No description provided for @checkinMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get checkinMood;

  /// No description provided for @energyHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get energyHigh;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTime;

  /// No description provided for @checkinRecommendedIntensity.
  ///
  /// In en, this message translates to:
  /// **'Recommended intensity: {intensity}'**
  String checkinRecommendedIntensity(String intensity);

  /// No description provided for @profileHealthGoals.
  ///
  /// In en, this message translates to:
  /// **'Health & Goals'**
  String get profileHealthGoals;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGoodAfternoon;

  /// No description provided for @settingsEnableReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable reminders'**
  String get settingsEnableReminders;

  /// No description provided for @homeStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get homeStatistics;

  /// No description provided for @checkinSleepBad.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get checkinSleepBad;

  /// No description provided for @videoYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube video'**
  String get videoYoutube;

  /// No description provided for @homeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeThisWeek;

  /// No description provided for @homeReadyForWorkout.
  ///
  /// In en, this message translates to:
  /// **'Ready for today\'s workout?'**
  String get homeReadyForWorkout;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGoodMorning;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @checkinTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get checkinTryAgain;

  /// No description provided for @checkinEnergyLevel.
  ///
  /// In en, this message translates to:
  /// **'Energy level'**
  String get checkinEnergyLevel;

  /// No description provided for @checkinSymptomsDescription.
  ///
  /// In en, this message translates to:
  /// **'Select all symptoms you feel today'**
  String get checkinSymptomsDescription;

  /// No description provided for @checkinMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Your mood'**
  String get checkinMoodTitle;

  /// No description provided for @profileMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get profileMyProfile;

  /// No description provided for @checkinPainDescription.
  ///
  /// In en, this message translates to:
  /// **'Rate your current pain level'**
  String get checkinPainDescription;

  /// No description provided for @checkinSleepGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get checkinSleepGreat;

  /// No description provided for @homeWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get homeWorkouts;

  /// No description provided for @homeAiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'AI recommendations'**
  String get homeAiRecommendations;

  /// No description provided for @checkinMoodDescription.
  ///
  /// In en, this message translates to:
  /// **'How is your emotional state today?'**
  String get checkinMoodDescription;

  /// No description provided for @checkinMoodHappy.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get checkinMoodHappy;

  /// No description provided for @checkinMoodEnergized.
  ///
  /// In en, this message translates to:
  /// **'Energized'**
  String get checkinMoodEnergized;

  /// No description provided for @checkinMoodNeutral.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get checkinMoodNeutral;

  /// No description provided for @checkinMoodTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get checkinMoodTired;

  /// No description provided for @checkinMoodStressed.
  ///
  /// In en, this message translates to:
  /// **'Stressed'**
  String get checkinMoodStressed;

  /// No description provided for @checkinSymptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get checkinSymptomHeadache;

  /// No description provided for @checkinSymptomBackPain.
  ///
  /// In en, this message translates to:
  /// **'Back pain'**
  String get checkinSymptomBackPain;

  /// No description provided for @checkinSymptomMuscleStiffness.
  ///
  /// In en, this message translates to:
  /// **'Muscle stiffness'**
  String get checkinSymptomMuscleStiffness;

  /// No description provided for @checkinSymptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get checkinSymptomFatigue;

  /// No description provided for @checkinSymptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get checkinSymptomNausea;

  /// No description provided for @checkinSymptomDizziness.
  ///
  /// In en, this message translates to:
  /// **'Dizziness'**
  String get checkinSymptomDizziness;

  /// No description provided for @checkinPainLocationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get checkinPainLocationOther;

  /// No description provided for @checkinSummaryModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate workout is recommended.'**
  String get checkinSummaryModerate;

  /// No description provided for @checkinEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get checkinEnergy;

  /// No description provided for @settingsWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get settingsWeekdays;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @energyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get energyMedium;

  /// No description provided for @settingsEveryOtherDay.
  ///
  /// In en, this message translates to:
  /// **'Every other day'**
  String get settingsEveryOtherDay;

  /// No description provided for @profilePersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get profilePersonalData;

  /// No description provided for @homeProgressStart.
  ///
  /// In en, this message translates to:
  /// **'Start your progress today'**
  String get homeProgressStart;

  /// No description provided for @videoUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get videoUnsupported;

  /// No description provided for @checkinEnergyDescription.
  ///
  /// In en, this message translates to:
  /// **'How much energy do you have right now?'**
  String get checkinEnergyDescription;

  /// No description provided for @activityLevelModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate activity'**
  String get activityLevelModerate;

  /// No description provided for @authErrorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get authErrorEmailInvalid;

  /// No description provided for @authErrorEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get authErrorEmailEmpty;

  /// No description provided for @injuryMeniscus.
  ///
  /// In en, this message translates to:
  /// **'Meniscus injury'**
  String get injuryMeniscus;

  /// No description provided for @injuryProtrusion.
  ///
  /// In en, this message translates to:
  /// **'Disc protrusion'**
  String get injuryProtrusion;

  /// No description provided for @injuryWrist.
  ///
  /// In en, this message translates to:
  /// **'Wrist injury'**
  String get injuryWrist;

  /// No description provided for @injuryKneeArthrosis.
  ///
  /// In en, this message translates to:
  /// **'Knee arthrosis'**
  String get injuryKneeArthrosis;

  /// No description provided for @authErrorPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get authErrorPasswordEmpty;

  /// No description provided for @authErrorPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authErrorPasswordShort;

  /// No description provided for @injuryShoulder.
  ///
  /// In en, this message translates to:
  /// **'Shoulder joint issues'**
  String get injuryShoulder;

  /// No description provided for @injuryScoliosis.
  ///
  /// In en, this message translates to:
  /// **'Scoliosis'**
  String get injuryScoliosis;

  /// No description provided for @injuryHernia.
  ///
  /// In en, this message translates to:
  /// **'Lumbar hernia (L4-L5, L5-S1)'**
  String get injuryHernia;

  /// No description provided for @injuryHipArthrosis.
  ///
  /// In en, this message translates to:
  /// **'Hip arthrosis'**
  String get injuryHipArthrosis;

  /// No description provided for @injuryNeckPain.
  ///
  /// In en, this message translates to:
  /// **'Neck pain'**
  String get injuryNeckPain;

  /// No description provided for @injuryOsteochondrosis.
  ///
  /// In en, this message translates to:
  /// **'Osteochondrosis'**
  String get injuryOsteochondrosis;

  /// No description provided for @activityLevelSedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary lifestyle'**
  String get activityLevelSedentary;

  /// No description provided for @activityLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High activity'**
  String get activityLevelHigh;

  /// No description provided for @authErrorPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get authErrorPasswordConfirm;

  /// No description provided for @activityLevelLight.
  ///
  /// In en, this message translates to:
  /// **'Light activity'**
  String get activityLevelLight;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Choose app language'**
  String get settingsLanguageHint;

  /// No description provided for @languageKk.
  ///
  /// In en, this message translates to:
  /// **'Kazakh'**
  String get languageKk;

  /// No description provided for @languageRu.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRu;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoConnection;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again later.'**
  String get errorTimeout;

  /// No description provided for @errorAIQuota.
  ///
  /// In en, this message translates to:
  /// **'AI quota exceeded. Please try again later.'**
  String get errorAIQuota;

  /// No description provided for @errorAIUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI service temporarily unavailable. Please try again later.'**
  String get errorAIUnavailable;

  /// No description provided for @errorAINotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI service not configured. Contact the administrator.'**
  String get errorAINotConfigured;

  /// No description provided for @errorAIEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty response from AI. Please try again.'**
  String get errorAIEmpty;

  /// No description provided for @errorAIParse.
  ///
  /// In en, this message translates to:
  /// **'Error processing AI response. Please try again.'**
  String get errorAIParse;

  /// No description provided for @errorGenerateWorkout.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate workout. Please try again later.'**
  String get errorGenerateWorkout;

  /// No description provided for @errorSaveCheckin.
  ///
  /// In en, this message translates to:
  /// **'Failed to save check-in. Please try again later.'**
  String get errorSaveCheckin;

  /// No description provided for @errorLoadCheckin.
  ///
  /// In en, this message translates to:
  /// **'Failed to load check-in. Check your connection.'**
  String get errorLoadCheckin;

  /// No description provided for @errorSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile. Please try again later.'**
  String get errorSaveProfile;

  /// No description provided for @errorLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile. Check your connection.'**
  String get errorLoadProfile;

  /// No description provided for @errorAuthStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify authentication status'**
  String get errorAuthStatus;

  /// No description provided for @errorAuthSignIn.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in. Please try again later.'**
  String get errorAuthSignIn;

  /// No description provided for @errorAuthSignUp.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign up. Please try again later.'**
  String get errorAuthSignUp;

  /// No description provided for @errorGeneral.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorGeneral;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Insufficient permissions for this operation'**
  String get errorPermissionDenied;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get errorTooManyRequests;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid login or password'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get errorEmailInUse;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errorWeakPassword;

  /// No description provided for @errorNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User is not authenticated'**
  String get errorNotAuthenticated;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
