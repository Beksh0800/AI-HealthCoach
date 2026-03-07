// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'AI Health Coach';

  @override
  String get splashSubtitle => 'Сенің жеке жаттықтырушың';

  @override
  String get onboardingErrorAuth => 'Қате: пайдаланушы жүйеге кірмеген';

  @override
  String get onboardingErrorSave =>
      'Профильді сақтау мүмкін болмады. Кейінірек қайталаңыз.';

  @override
  String get onboardingRetry => 'Қайталау';

  @override
  String get onboardingBtnBack => 'Артқа';

  @override
  String get onboardingBtnNext => 'Алға';

  @override
  String get onboardingBtnFinish => 'Аяқтау';

  @override
  String get onboardingWelcomeTitle => 'Қош келдіңіз!';

  @override
  String get onboardingWelcomeText =>
      'Жаттығулар қауіпсіз әрі тиімді болуы үшін сіздің жеке денсаулық профиліңізді жасайық.';

  @override
  String get onboardingBasicTitle => 'Өзіңіз туралы айтыңыз';

  @override
  String get onboardingNameField => 'Атыңыз';

  @override
  String get onboardingGenderTitle => 'Жынысыңыз';

  @override
  String get onboardingGenderMale => 'Ер';

  @override
  String get onboardingGenderFemale => 'Әйел';

  @override
  String get onboardingGenderNotSpecified => 'Көрсетпеу';

  @override
  String onboardingAgeText(int age) {
    return 'Жасы: $age жас';
  }

  @override
  String onboardingWeightText(String weight) {
    return 'Салмағы: $weight кг';
  }

  @override
  String get onboardingActivityLevelTitle => 'Белсенділік деңгейі';

  @override
  String get onboardingHealthTitle => 'Денсаулыққа қатысты мәселелер';

  @override
  String get onboardingHealthText =>
      'Өзіңізге қатыстысының барлығын таңдаңыз. Бұл қауіпті жаттығуларды болдырмауға көмектеседі.';

  @override
  String get onboardingHealthInfo =>
      'Егер денсаулығыңызда ақау жоқ болса, жай ғана \"Алға\" түймесін басыңыз';

  @override
  String get onboardingGoalsTitle => 'Сіздің мақсатыңыз';

  @override
  String get onboardingGoalsText => 'Дәл қазір сізге не маңызды?';

  @override
  String get goalRelieveBackPain => 'Арқа ауруынан құтылу';

  @override
  String get goalStrengthenCore => 'Бұлшықет корсетін қатайту';

  @override
  String get goalRecoverFromInjury => 'Жарақаттан кейін қалпына келу';

  @override
  String get goalImproveFlexibility => 'Икемділікті жақсарту';

  @override
  String get goalMaintainGeneralTone => 'Жалпы тонусты сақтау';

  @override
  String get loginTitle => 'Қайта оралуыңызбен!';

  @override
  String get loginSubtitle => 'Жаттығуды жалғастыру үшін кіріңіз';

  @override
  String get loginEmailLabel => 'Электрондық пошта';

  @override
  String get loginPasswordLabel => 'Құпия сөз';

  @override
  String get loginForgotPassword => 'Құпия сөзді ұмыттыңыз ба?';

  @override
  String get loginButton => 'Кіру';

  @override
  String get loginNoAccount => 'Есептік жазбаңыз жоқ па?';

  @override
  String get loginRegisterLink => 'Тіркелу';

  @override
  String get loginResetSent =>
      'Құпия сөзді қалпына келтіру сілтемесі жіберілді';

  @override
  String get loginFillEmail => 'Алдымен email енгізіңіз';

  @override
  String get registerTitle => 'Тіркелу';

  @override
  String get registerSubtitle => 'Тренеріңізбен танысу үшін тіркеліңіз';

  @override
  String get registerNameLabel => 'Аты';

  @override
  String get registerEmailLabel => 'Электрондық пошта';

  @override
  String get registerPasswordLabel => 'Құпия сөз';

  @override
  String get registerConfirmPasswordLabel => 'Құпия сөзді қайталаңыз';

  @override
  String get registerButton => 'Тіркелу';

  @override
  String get registerHaveAccount => 'Есептік жазбаңыз бар ма?';

  @override
  String get registerLoginLink => 'Кіру';

  @override
  String get registerPasswordMismatch => 'Құпия сөздер сәйкес келмейді';

  @override
  String homeGreeting(String name) {
    return 'Сәлем, $name! 👋';
  }

  @override
  String get homeGreetingDefault => 'Сәлем! 👋';

  @override
  String get homeSubtitle => 'Бүгін көңіл күйіңіз қалай?';

  @override
  String get homeStartCheckin => '✅  Бүгінгі сауалнамадан өту';

  @override
  String get homeCheckinDone => '✅  Сауалнама аяқталды';

  @override
  String get homeSectionWorkouts => 'Жылдам тренировка';

  @override
  String get homeWorkoutLfk => 'ЕДШ';

  @override
  String get homeWorkoutStretching => 'Созылу';

  @override
  String get homeWorkoutStrength => 'Күштік';

  @override
  String get homeWorkoutCardio => 'Кардио';

  @override
  String get homeCheckinNotice =>
      'Жаттығуды бастау алдында сауалнамадан өтіңіз';

  @override
  String get homeProfileNotLoaded =>
      'Профиль жүктелмеді. Кейінірек қайталаңыз.';

  @override
  String get checkinTitle => 'Өзіңізді қалай сезінесіз?';

  @override
  String get checkinMoodLabel => 'Көңіл-күй';

  @override
  String get checkinEnergyLabel => 'Энергия';

  @override
  String get checkinPainLabel => 'Ауру деңгейі';

  @override
  String get checkinSleepLabel => 'Ұйқы сапасы';

  @override
  String get checkinStressLabel => 'Стресс';

  @override
  String get checkinButton => 'Жалғастыру';

  @override
  String get checkinMoodHints => 'Жаман;Нашар;Қалыпты;Жақсы;Тамаша';

  @override
  String get checkinEnergyHints =>
      'Өте төмен;Төмен;Қалыпты;Жоғары;Толы энергия';

  @override
  String get checkinPainHints => 'Өте қатты;Қатты;Орташа;Аздап;Жоқ';

  @override
  String get checkinSleepHints => 'Өте нашар;Нашар;Қалыпты;Жақсы;Тамаша';

  @override
  String get checkinStressHints => 'Өте жоғары;Жоғары;Орташа;Төмен;Жоқ';

  @override
  String get historyTitle => 'Тарих';

  @override
  String get historyTabStats => 'Статистика';

  @override
  String get historyTabWorkouts => 'Жаттығулар';

  @override
  String get historyWeekChart => 'Аптадағы тренировкалар';

  @override
  String get historyWorkoutsCount => 'Жаттығулар';

  @override
  String get historyTotalMinutes => 'Жалпы минут';

  @override
  String get historyByType => 'Түрлер бойынша';

  @override
  String get historyEmpty => 'Тарих бос';

  @override
  String get historyLoading => 'Тарих жүктелуде...';

  @override
  String get historyOffline =>
      'Интернетке қосылым жоқ.\\nИнтернетке қосылғаннан кейін қайталаңыз.';

  @override
  String get historyOfflineRetry => 'Қайталау';

  @override
  String get historyLoadError => 'Тарихты жүктеу мүмкін болмады';

  @override
  String get historyRecentWorkouts => 'Соңғы жаттығулар';

  @override
  String get historyTabWeek => 'Апта';

  @override
  String get historyTabMonth => 'Ай';

  @override
  String get historyWorkoutsLabel => 'Тренировка';

  @override
  String get historyMinutesLabel => 'Минут';

  @override
  String get historyTypesTitle => 'Жаттығу түрлері';

  @override
  String get historyMinShort => 'мин';

  @override
  String get historyTypeLfk => 'ЕДШ';

  @override
  String get historyTypeStretching => 'Созылу';

  @override
  String get historyTypeStrength => 'Күштік';

  @override
  String get historyTypeCardio => 'Кардио';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileSettingsTooltip => 'Баптаулар';

  @override
  String get profileSectionPersonal => 'Жеке деректер';

  @override
  String get profileAge => 'Жасы';

  @override
  String profileAgeValue(int age) {
    return '$age жас';
  }

  @override
  String get profileHeight => 'Бойы';

  @override
  String profileHeightValue(String height) {
    return '$height см';
  }

  @override
  String get profileWeight => 'Салмағы';

  @override
  String profileWeightValue(String weight) {
    return '$weight кг';
  }

  @override
  String get profileGender => 'Жынысы';

  @override
  String get profileSectionHealth => 'Денсаулық және Мақсаттар';

  @override
  String get profileActivity => 'Белсенділік';

  @override
  String get profileGoal => 'Мақсат';

  @override
  String get profileLimitations => 'Шектеулер';

  @override
  String get profileLogout => 'Аккаунттан шығу';

  @override
  String get profileLoadError => 'Профильді жүктеу мүмкін болмады';

  @override
  String get profileNotFound => 'Профиль табылмады';

  @override
  String get profileNotFoundMessage =>
      'Сауалнаманы толтырыңыз немесе экранды жаңартыңыз.';

  @override
  String get profileLoading => 'Профиль жүктелуде...';

  @override
  String get profileOffline =>
      'Интернетке қосылым жоқ.\\nИнтернетке қосылғаннан кейін қайталаңыз.';

  @override
  String get profileRetry => 'Қайталау';

  @override
  String get profileGenderMale => 'Ер';

  @override
  String get profileGenderFemale => 'Әйел';

  @override
  String get profileGenderNotSpecified => 'Көрсетілмеген';

  @override
  String get profileActivityLow => 'Төмен';

  @override
  String get profileActivityModerate => 'Орташа';

  @override
  String get profileActivityHigh => 'Жоғары';

  @override
  String get editProfileTitle => 'Профильді өзгерту';

  @override
  String get editProfileSectionBasic => 'Негізгі';

  @override
  String get editProfileNameLabel => 'Аты';

  @override
  String get editProfileGenderLabel => 'Жынысы';

  @override
  String get editProfileGenderMale => 'Ер';

  @override
  String get editProfileGenderFemale => 'Әйел';

  @override
  String get editProfileGenderNotSpecified => 'Көрсетілмеген';

  @override
  String get editProfileSectionPhysical => 'Дене көрсеткіштері';

  @override
  String get editProfileAgeLabel => 'Жасы';

  @override
  String get editProfileHeightLabel => 'Бойы (см)';

  @override
  String get editProfileWeightLabel => 'Салмағы (кг)';

  @override
  String get editProfileSectionGoals => 'Мақсаттар мен Белсенділік';

  @override
  String get editProfileActivityLabel => 'Белсенділік деңгейі';

  @override
  String get editProfileActivityLow => 'Төмен (отырыс)';

  @override
  String get editProfileActivityModerate => 'Орташа (1-3 жаттығу)';

  @override
  String get editProfileActivityHigh => 'Жоғары (3+ жаттығу)';

  @override
  String get editProfileGoalsLabel => 'Мақсаттар';

  @override
  String get editProfileSectionInjuries => 'Жарақаттар мен шектеулер';

  @override
  String get editProfileAddInjuryLabel => 'Жарақат/шектеу қосу';

  @override
  String get editProfileAddInjuryHint => 'Мысалы: тізедегі ауру';

  @override
  String get editProfileAddButton => 'Қосу';

  @override
  String get editProfileCancel => 'Болдырмау';

  @override
  String get editProfileSave => 'Сақтау';

  @override
  String get editProfileValidateName => 'Атыңызды енгізіңіз';

  @override
  String editProfileValidateNameLength(int max) {
    return 'Аты $max таңбадан аспауы керек';
  }

  @override
  String get editProfileValidateAge => 'Дұрыс жасты енгізіңіз';

  @override
  String editProfileValidateAgeRange(int min, int max) {
    return 'Жасы $min-$max';
  }

  @override
  String get editProfileValidateHeight => 'Дұрыс бойды енгізіңіз';

  @override
  String editProfileValidateHeightRange(int min, int max) {
    return 'Бой $min-$max см';
  }

  @override
  String get editProfileValidateWeight => 'Дұрыс салмақты енгізіңіз';

  @override
  String editProfileValidateWeightRange(int min, int max) {
    return 'Салмақ $min-$max кг';
  }

  @override
  String editProfileValidateGoalsLength(int max) {
    return 'Мақсат $max таңбадан аспауы керек';
  }

  @override
  String editProfileInjuryTooLong(int max) {
    return 'Шектеу $max таңбадан аспауы керек';
  }

  @override
  String editProfileMaxInjuries(int max) {
    return '$max шектеуге дейін қосуға болады';
  }

  @override
  String get settingsTitle => 'Баптаулар';

  @override
  String get settingsReminderTitle => 'Жаттығу еске салулары';

  @override
  String get settingsReminderSubtitle =>
      'Еске салу уақыты мен күндерін баптаңыз';

  @override
  String get settingsReminderEnable => 'Еске салуларды қосу';

  @override
  String get settingsReminderActive => 'Еске салулар қосылған';

  @override
  String get settingsReminderInactive => 'Еске салулар өшірілген';

  @override
  String get settingsReminderPermissionDenied =>
      'Хабарлама рұқсаты берілмеген. Құрылғы баптауларынан қосыңыз.';

  @override
  String get settingsTimeTitle => 'Еске салу уақыты';

  @override
  String get settingsDaysTitle => 'Апта күндері';

  @override
  String get settingsPresetWeekdays => 'Жұмыс күндері';

  @override
  String get settingsPresetEveryday => 'Күн сайын';

  @override
  String get settingsPresetAlternate => 'Күн арқылы';

  @override
  String get settingsDayMon => 'Дс';

  @override
  String get settingsDaySun => 'Жс';

  @override
  String get settingsDayTue => 'Сс';

  @override
  String get settingsDayWed => 'Ср';

  @override
  String get settingsDayThu => 'Бс';

  @override
  String get settingsDayFri => 'Жм';

  @override
  String get settingsDaySat => 'Сб';

  @override
  String get workoutSelectionTitle => 'Жаттығу таңдау';

  @override
  String get workoutSelectionQuestion => 'Бүгін қандай жаттығуды қалайсыз?';

  @override
  String get workoutSelectionHint =>
      'Жаттығу түрін таңдаңыз, AI жеке бағдарлама жасайды';

  @override
  String get workoutTypeLfk => 'ЕДШ';

  @override
  String get workoutTypeStretching => 'Созылу';

  @override
  String get workoutTypeStrength => 'Күштік';

  @override
  String get workoutTypeCardio => 'Кардио';

  @override
  String get workoutDescLfk =>
      'Қалпына келтіруге арналған емдік дене шынықтыру';

  @override
  String get workoutDescStretching => 'Икемділік пен созылу жаттығулары';

  @override
  String get workoutDescStrength =>
      'Бұлшықетті нығайтуға арналған күш жаттығулары';

  @override
  String get workoutDescCardio => 'Шыдамдылыққа арналған кардио';

  @override
  String get workoutRetry => 'Қайталау';

  @override
  String get workoutProfileNotLoaded =>
      'Профиль жүктелмеді. Кейінірек қайталаңыз.';

  @override
  String get workoutCheckinRequired =>
      'Алдымен денсаулық сауалнамасынан өтіңіз';

  @override
  String get workoutSavedWorkouts => 'Сақталған жаттығулар';

  @override
  String workoutMinutesShort(int minutes) {
    return '$minutes мин';
  }

  @override
  String get workoutSecondsUnitShort => 'сек';

  @override
  String get workoutRepsUnitShort => 'рет';

  @override
  String get workoutIntensityRest => 'Демалыс';

  @override
  String get workoutIntensityLight => 'Жеңіл';

  @override
  String get workoutIntensityModerate => 'Орташа';

  @override
  String get workoutIntensityHigh => 'Жоғары';

  @override
  String workoutTimeAgoMinutes(int count) {
    return '$count мин бұрын';
  }

  @override
  String workoutTimeAgoHours(int count) {
    return '$count сағ бұрын';
  }

  @override
  String workoutTimeAgoDays(int count) {
    return '$count күн бұрын';
  }

  @override
  String get workoutSessionTitle => 'Аяқталмаған жаттығу';

  @override
  String get workoutSessionSubtitle => 'Сізде сақталған жаттығу бар';

  @override
  String workoutSessionSaved(String time) {
    return 'Сақталды: $time';
  }

  @override
  String get workoutSessionContinue => 'Жаттығуды жалғастыру';

  @override
  String get workoutSessionNew => 'Жаңасын бастау';

  @override
  String workoutGenerating(String label) {
    return 'Жаттығу жасалуда \"$label\"';
  }

  @override
  String get workoutGeneratingAnalyzingProfile =>
      'Профиль мен ағымдағы жағдай талданып жатыр...';

  @override
  String get workoutGeneratingSelectingSafeExercises =>
      'Қауіпсіз жаттығулар таңдалып жатыр...';

  @override
  String get workoutGeneratingAdaptingIntensity =>
      'Қарқын жағдайыңызға бейімделіп жатыр...';

  @override
  String get workoutGeneratingCreatingProgram =>
      'Жеке бағдарлама құрылып жатыр...';

  @override
  String get workoutGeneratingValidatingSafety =>
      'Жоспар қауіпсіздігі тексеріліп жатыр...';

  @override
  String get workoutCancel => 'Болдырмау';

  @override
  String get workoutPreviewTitle => 'Сіздің жаттығуыңыз';

  @override
  String get workoutPreviewNotFound => 'Жаттығу табылмады';

  @override
  String get workoutPreviewWarmup => 'Қыздыру';

  @override
  String get workoutPreviewMain => 'Негізгі жаттығулар';

  @override
  String get workoutPreviewCooldown => 'Сабырлану';

  @override
  String workoutPreviewExercises(int count) {
    return '$count жатт.';
  }

  @override
  String get workoutPreviewStart => 'Жаттығуды бастау';

  @override
  String get workoutPlanCreated => 'Жаттығу жоспары құрылды';

  @override
  String get workoutPlayerTitle => 'Жаттығу';

  @override
  String get workoutPlayerReady => 'Бастауға дайын';

  @override
  String get workoutPlayerWarmup => 'Қыздыру';

  @override
  String get workoutPlayerMainPart => 'Негізгі бөлім';

  @override
  String get workoutPlayerCooldown => 'Сабырлану';

  @override
  String get workoutPlayerStartWorkout => 'Жаттығуды бастау';

  @override
  String get workoutPlayerSkipExercise => 'Жаттығуды өткізіп жіберу';

  @override
  String get workoutPlayerFinishWorkout => 'Жаттығуды аяқтау';

  @override
  String get workoutPlayerPainButton => 'Ауру / Ыңғайсыздық';

  @override
  String workoutPlayerExerciseOf(int current, int total) {
    return 'Жаттығу $current / $total';
  }

  @override
  String get workoutPlayerMinutes => 'МИНУТТАР';

  @override
  String get workoutPlayerSeconds => 'СЕКУНДТАР';

  @override
  String get workoutPlayerReps => 'ҚАЙТАЛАУ';

  @override
  String get workoutPlayerRest => 'Демалыс';

  @override
  String workoutPlayerRestSeconds(int seconds) {
    return '$seconds сек';
  }

  @override
  String workoutPlayerNextSet(String name) {
    return 'Келесі қадам: $name';
  }

  @override
  String get workoutPlayerAutoResume =>
      'Таймерден кейін жаттығу автоматты түрде жалғасады';

  @override
  String get workoutPlayerContinue => 'Жалғастыру';

  @override
  String get workoutPlayerAiInsight => 'AI ТҮСІНДІРМЕСІ';

  @override
  String get workoutPlayerAiNote => 'AI дәрігер жазбасы';

  @override
  String get workoutPlayerNoDescription => 'Қосымша сипаттама жоқ.';

  @override
  String get workoutPlayerAiLocalizedPending =>
      'AI түсіндірмесін ағымдағы тілге бейімдеп жатырмыз...';

  @override
  String get workoutPlayerAiLocalizedUnavailable =>
      'Локализацияланған AI түсіндірмесі уақытша қолжетімсіз.';

  @override
  String get workoutPlayerGotIt => 'Түсіндім';

  @override
  String get workoutPlayerClose => 'Жабу';

  @override
  String get workoutPlayerExitTitle => 'Жаттығу аяқталды ма?';

  @override
  String get workoutPlayerExitMessage => 'Прогресс сақталмайды';

  @override
  String get workoutPlayerExitCancel => 'Болдырмау';

  @override
  String get workoutPlayerExitConfirm => 'Аяқтау';

  @override
  String get workoutPlayerSearchUnavailable =>
      'Бейне іздеу сілтемесі қолжетімсіз';

  @override
  String get workoutPlayerAnimation => 'Анимация';

  @override
  String get painWhereTitle => 'Ол қай жерде ауырады?';

  @override
  String get painIntensityTitle => 'Қанша ауырады?';

  @override
  String get painActionTitle => 'Біз не істейміз?';

  @override
  String get painSelectArea => 'Ауру аймағын таңдаңыз';

  @override
  String painCurrentExercise(String name) {
    return 'Ағымдағы жаттығу: $name';
  }

  @override
  String get painCancelContinue => 'Бас тарту, жаттығуды жалғастыру';

  @override
  String painAreaText(String area) {
    return 'Аймақ: $area';
  }

  @override
  String get painRateIntensity => 'Ауру қарқындылығын бағалаңыз';

  @override
  String painLevelText(int level) {
    return 'Ауру деңгейі: $level/10';
  }

  @override
  String get painLocationLowerBack => 'Арқа (бел)';

  @override
  String get painLocationUpperBack => 'Арқа (жоғарғы)';

  @override
  String get painLocationNeck => 'Мойын';

  @override
  String get painLocationKnees => 'Тізелер';

  @override
  String get painLocationShoulders => 'Иықтар';

  @override
  String get painLocationWrists => 'Білектер';

  @override
  String get painLocationAnkle => 'Тобық';

  @override
  String get painLocationHips => 'Жамбас/сан';

  @override
  String get painIntensity1 => 'Жеңіл ыңғайсыздық';

  @override
  String get painIntensity1Sub => 'Дерлік кедергі жоқ';

  @override
  String get painIntensity2 => 'Әлсіз ауру';

  @override
  String get painIntensity2Sub => 'Шыдауға болады';

  @override
  String get painIntensity3 => 'Аздаған ауру';

  @override
  String get painIntensity3Sub => 'Байқалады, бірақ жалғастыруға болады';

  @override
  String get painIntensity4 => 'Орташа ауру';

  @override
  String get painIntensity4Sub => 'Зейінге кедергі';

  @override
  String get painIntensity5 => 'Орташа ауру';

  @override
  String get painIntensity5Sub => 'Техниканы өзгерту керек';

  @override
  String get painIntensity6 => 'Байқалатын ауру';

  @override
  String get painIntensity6Sub => 'Жалғастыру қиын';

  @override
  String get painIntensity7 => 'Қатты ауру';

  @override
  String get painIntensity7Sub => 'Үзіліс қажет';

  @override
  String get painIntensity8 => 'Өте қатты ауру';

  @override
  String get painIntensity8Sub => 'Тоқтаған жөн';

  @override
  String get painIntensity9 => 'Өткір ауру';

  @override
  String get painIntensity9Sub => 'Демалыс қажет';

  @override
  String get painIntensity10 => 'Шыдамсыз';

  @override
  String get painIntensity10Sub => 'Дәрігер қажет';

  @override
  String get painActionLightTitle => 'Сіз не істегіңіз келеді?';

  @override
  String get painActionLightSubtitle =>
      'Жеңіл ыңғайсыздық — жалғастыруға болады';

  @override
  String get painActionModerateTitle => 'Сақтық ұсынылады';

  @override
  String get painActionModerateSubtitle =>
      'Жаттығуды ауыстыруды немесе демалуды ұсынамыз';

  @override
  String get painActionSevereTitle => '⚠️ Демалыс қажет';

  @override
  String get painActionSevereSubtitle =>
      'Қатты ауырса тоқтаған немесе демалған жөн';

  @override
  String get painActionDefault => 'Әрекетті таңдаңыз';

  @override
  String get painContinueExercise => 'Жаттығуды жалғастыру';

  @override
  String get painContinueSub => 'Ауру шыдамды, жалғастырамын';

  @override
  String get painReplaceExercise => 'Жаттығуды ауыстыру';

  @override
  String get painReplaceSub => 'AI қауіпсіз балама таңдайды';

  @override
  String get painReplaceModSub => 'Орташа ауырғанда ұсынылады';

  @override
  String get painBreak2min => '2 минут үзіліс';

  @override
  String get painBreak2minSub => 'Қысқа демалыс';

  @override
  String get painBreak5min => '5 минут үзіліс';

  @override
  String get painBreak5minSub => 'Демалыңыз және денеңізді тыңдаңыз';

  @override
  String get painBreak10min => '10 минут үзіліс';

  @override
  String get painBreak10minSub => 'Ұзақ демалыс кеңестермен';

  @override
  String get painEndWorkout => 'Жаттығуды аяқтау';

  @override
  String get painEndWorkoutSaveSub => 'Прогресті сақтаймыз';

  @override
  String get painEndWorkoutHealthSub =>
      'Денсаулық маңыздырақ — бүгін демалыңыз';

  @override
  String get painSevereWarning => 'Қатты ауырса дәрігерге жүгінуді ұсынамыз';

  @override
  String get painRestTitle => 'Үзіліс';

  @override
  String get painRestRemaining => 'қалды';

  @override
  String get painRestTips => 'Демалыс кеңестері:';

  @override
  String get painRestContinueEarly => 'Ертерек жалғастыру';

  @override
  String get painRestTipLight =>
      'Терең дем алыңыз және шығарыңыз.\nКерілген бұлшықеттерді босаңсытыңыз.';

  @override
  String get painRestTipModerate =>
      'Ауру аймағын ақырын уқалаңыз.\nСу ішіңіз және тыныш тыныс алыңыз.';

  @override
  String get painRestTipSevere =>
      'Толық босаңсыңыз.\nАуру басылмаса, дәрігерге жүгініңіз.';

  @override
  String get painReplacingTitle => 'Балама іздеу';

  @override
  String get painReplacingText => 'AI қауіпсіз ауыстыру іздеуде';

  @override
  String painReplacingArea(String area) {
    return 'Ауру аймағы: $area';
  }

  @override
  String get completionTitle => 'Тамаша жұмыс!';

  @override
  String completionMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String completionExercises(int count) {
    return '$count жатт.';
  }

  @override
  String completionPainReports(int count) {
    return 'Ауру шағымдары: $count';
  }

  @override
  String get completionAnalyzing => 'AI жаттығуыңызды талдауда...';

  @override
  String completionTips(int count) {
    return 'Кеңестер ($count)';
  }

  @override
  String get completionShowAll => 'Барлығын көрсету';

  @override
  String get completionCollapse => 'Жинау';

  @override
  String get completionRecoveryPlan => 'Қалпына келтіру жоспары';

  @override
  String get completionRecoveryBrief => 'Қысқаша, шамадан тыс жүктемесіз';

  @override
  String get completionRecoveryExpand => 'Қадамдарды көру үшін ашыңыз';

  @override
  String completionRestDuration(String duration) {
    return 'Демалыс: $duration';
  }

  @override
  String get completionHideSteps => 'Қадамдарды жасыру';

  @override
  String completionMoreSteps(int count) {
    return 'Тағы қадамдар ($count)';
  }

  @override
  String get completionNutrition => 'Тамақтану';

  @override
  String get completionSleep => 'Ұйқы';

  @override
  String get completionGoHome => 'Басты бетке';

  @override
  String get categoryBack => 'Арқа';

  @override
  String get categoryLegs => 'Аяқтар';

  @override
  String get categoryArms => 'Қолдар';

  @override
  String get categoryCore => 'Кор';

  @override
  String get categoryNeck => 'Мойын';

  @override
  String get categoryGeneral => 'Жалпы';

  @override
  String get routeNotFound => 'Бет табылмады';

  @override
  String get checkinSummaryLight => 'Бүгін жеңіл жаттығу ұсынылады.';

  @override
  String get homeOffline =>
      'Интернетке қосылу жоқ.\\nИнтернетке қосылғаннан кейін қайталаңыз.';

  @override
  String get onboardingDefaultName => 'Пайдаланушы';

  @override
  String get homeUser => 'Пайдаланушы';

  @override
  String get profileRestrictions => 'Шектеулер';

  @override
  String get settingsConfigureReminders =>
      'Еске салғыштың уақыты мен күндерін орнатыңыз';

  @override
  String get navExitPrompt =>
      'Шығу үшін \"Артқа\" түймесін тағы бір рет басыңыз';

  @override
  String get energyVeryHigh => 'Өте жоғары';

  @override
  String get checkinNoPain => 'Ауыруы жоқ';

  @override
  String get homeLoadingData => 'Деректер жүктелуде...';

  @override
  String get authHintPasswordMin => 'Кемінде 6 таңба';

  @override
  String get settingsWorkoutReminders => 'Жаттығу туралы еске салғыштар';

  @override
  String get navProfile => 'Профиль';

  @override
  String get homeProgress => 'Прогресс';

  @override
  String get checkinNotes => 'Ескертпелер';

  @override
  String get homeMinutes => 'Минут';

  @override
  String get videoSearchAvailable => 'Бейне YouTube іздеу арқылы қолжетімді';

  @override
  String get checkinPainLevel => 'Ауырсыну деңгейі';

  @override
  String get settingsDaysOfWeek => 'Аптаның күндері';

  @override
  String get energyVeryLow => 'Өте төмен';

  @override
  String get settingsRemindersOff => 'Еске салғыштар өшірілген';

  @override
  String get homeOfflineRetry => 'Қайталау';

  @override
  String get checkinSummaryRest =>
      'Бүгін демалу және қалпына келтіру ұсынылады.';

  @override
  String get homeTotalMinutes => 'Жалпы минуттар';

  @override
  String get checkinSymptomsTitle => 'Симптомдары';

  @override
  String get profileKg => 'кг';

  @override
  String get settingsPermissionDenied =>
      'Хабарландыру рұқсаты қабылданбады. Оны параметрлерде қосыңыз.';

  @override
  String get homeStartStreak => 'Жолыңызды бастаңыз';

  @override
  String get profileCm => 'см';

  @override
  String get checkinNotesHint =>
      'Кез келген қосымша белгілер немесе түсініктемелер';

  @override
  String get authHintPasswordRepeat => 'Құпия сөзді қайталаңыз';

  @override
  String get checkinStrongPain => 'Қатты ауырсыну';

  @override
  String get checkinWhereHurts => 'Ол қай жерде ауырады?';

  @override
  String get homeQuickActions => 'Жылдам әрекеттер';

  @override
  String homeStreakDays(int count) {
    return '$count-күндік кезең';
  }

  @override
  String get videoOpenSearch => 'Қолданбада іздеуді ашыңыз';

  @override
  String get checkinToWorkout => 'Жаттығуға барыңыз';

  @override
  String get settingsRemindersActive => 'Еске салғыштар қосылды';

  @override
  String get navWorkout => 'Жаттығу';

  @override
  String get checkinRedoSurvey => 'Сауалнаманы қайталаңыз';

  @override
  String get homeGoodEvening => 'Қайырлы кеш';

  @override
  String get checkinSummaryGreat =>
      'Ұлы мемлекет. Сіз толық жаттығу жасай аласыз.';

  @override
  String get checkinBetterRest => 'Бүгін демалып, қалпына келген дұрыс';

  @override
  String get energyLow => 'Төмен';

  @override
  String get checkinSleep => 'Ұйқы';

  @override
  String get checkinSleepQuality => 'Ұйқы сапасы';

  @override
  String get videoNetwork => 'Бейне';

  @override
  String get homeLoadingAnalytics => 'Аналитика жүктелуде...';

  @override
  String get checkinAlreadyCompleted =>
      'Бүгінгі тіркелу қазірдің өзінде аяқталды';

  @override
  String get profileYears => 'жылдар';

  @override
  String get navHome => 'Басты бет';

  @override
  String get homeTapForDetailedStats =>
      'Егжей-тегжейлі статистиканы көру үшін түртіңіз';

  @override
  String get checkinRecommendation => 'Ұсыныс';

  @override
  String get settingsEveryDay => 'Күн сайын';

  @override
  String get homeAverage => 'Орташа';

  @override
  String get checkinMood => 'Көңіл-күй';

  @override
  String get energyHigh => 'Жоғары';

  @override
  String get settingsReminderTime => 'Еске салу уақыты';

  @override
  String checkinRecommendedIntensity(String intensity) {
    return 'Ұсынылатын қарқындылық: $intensity';
  }

  @override
  String get profileHealthGoals => 'Денсаулық және мақсаттар';

  @override
  String get homeGoodAfternoon => 'Қайырлы күн';

  @override
  String get settingsEnableReminders => 'Еске салғыштарды қосыңыз';

  @override
  String get homeStatistics => 'Статистика';

  @override
  String get checkinSleepBad => 'Нашар';

  @override
  String get videoYoutube => 'YouTube бейне';

  @override
  String get homeThisWeek => 'Осы аптада';

  @override
  String get homeReadyForWorkout => 'Бүгінгі жаттығуға дайынсыз ба?';

  @override
  String get homeGoodMorning => 'Қайырлы таң';

  @override
  String get navHistory => 'Тарих';

  @override
  String get checkinTryAgain => 'Қайтадан байқап көріңіз';

  @override
  String get checkinEnergyLevel => 'Энергия деңгейі';

  @override
  String get checkinSymptomsDescription =>
      'Бүгін сезінген барлық белгілерді таңдаңыз';

  @override
  String get checkinMoodTitle => 'Сіздің көңіл-күйіңіз';

  @override
  String get profileMyProfile => 'Менің профилім';

  @override
  String get checkinPainDescription => 'Ағымдағы ауырсыну деңгейін бағалаңыз';

  @override
  String get checkinSleepGreat => 'Тамаша';

  @override
  String get homeWorkouts => 'Жаттығулар';

  @override
  String get homeAiRecommendations => 'AI ұсыныстары';

  @override
  String get checkinMoodDescription => 'Бүгінгі эмоционалдық жағдайыңыз қалай?';

  @override
  String get checkinMoodHappy => 'Тамаша';

  @override
  String get checkinMoodEnergized => 'Қуатты';

  @override
  String get checkinMoodNeutral => 'Қалыпты';

  @override
  String get checkinMoodTired => 'Шаршадым';

  @override
  String get checkinMoodStressed => 'Күйзеліс';

  @override
  String get checkinSymptomHeadache => 'Бас ауруы';

  @override
  String get checkinSymptomBackPain => 'Арқа ауруы';

  @override
  String get checkinSymptomMuscleStiffness => 'Бұлшықет қаттылығы';

  @override
  String get checkinSymptomFatigue => 'Шаршау';

  @override
  String get checkinSymptomNausea => 'Жүрек айну';

  @override
  String get checkinSymptomDizziness => 'Бас айналу';

  @override
  String get checkinPainLocationOther => 'Басқа';

  @override
  String get checkinSummaryModerate => 'Орташа жаттығу ұсынылады.';

  @override
  String get checkinEnergy => 'Энергия';

  @override
  String get settingsWeekdays => 'Жұмыс күндері';

  @override
  String get profileSignOut => 'Шығу';

  @override
  String get energyMedium => 'Орташа';

  @override
  String get settingsEveryOtherDay => 'Екі күн сайын';

  @override
  String get profilePersonalData => 'Жеке деректер';

  @override
  String get homeProgressStart => 'Прогрессіңізді бүгін бастаңыз';

  @override
  String get videoUnsupported => 'Бейне қолжетімді емес';

  @override
  String get checkinEnergyDescription => 'Дәл қазір сізде қанша энергия бар?';

  @override
  String get activityLevelModerate => 'Орташа белсенділік';

  @override
  String get authErrorEmailInvalid => 'Email форматы қате';

  @override
  String get authErrorEmailEmpty => 'Email енгізіңіз';

  @override
  String get injuryMeniscus => 'Мениск жарақаты';

  @override
  String get injuryProtrusion => 'Омыртқааралық дискілердің протрузиясы';

  @override
  String get injuryWrist => 'Білек жарақаты';

  @override
  String get injuryKneeArthrosis => 'Тізе буынының артрозы';

  @override
  String get authErrorPasswordEmpty => 'Құпия сөзді енгізіңіз';

  @override
  String get authErrorPasswordShort =>
      'Құпия сөз кемінде 6 таңбадан тұруы керек';

  @override
  String get injuryShoulder => 'Иық буынының проблемалары';

  @override
  String get injuryScoliosis => 'Сколиоз';

  @override
  String get injuryHernia => 'Бел омыртқа жарығы (L4-L5, L5-S1)';

  @override
  String get injuryHipArthrosis => 'Жамбас буынының артрозы';

  @override
  String get injuryNeckPain => 'Мойын аймағындағы ауырсыну';

  @override
  String get injuryOsteochondrosis => 'Остеохондроз';

  @override
  String get activityLevelSedentary => 'Отырықшы өмір салты';

  @override
  String get activityLevelHigh => 'Жоғары белсенділік';

  @override
  String get authErrorPasswordConfirm => 'Құпия сөзді растаңыз';

  @override
  String get activityLevelLight => 'Жеңіл белсенділік';

  @override
  String get settingsLanguage => 'Тіл';

  @override
  String get settingsLanguageHint => 'Қолданба тілін таңдаңыз';

  @override
  String get languageKk => 'Қазақша';

  @override
  String get languageRu => 'Орысша';

  @override
  String get languageEn => 'Ағылшынша';

  @override
  String get errorNoConnection => 'Интернетке қосылым жоқ';

  @override
  String get errorTimeout => 'Күту уақыты асты. Кейінірек қайталаңыз.';

  @override
  String get errorAIQuota => 'AI квотасы таусыпты. Кейінірек қайталаңыз.';

  @override
  String get errorAIUnavailable =>
      'AI-қызмет уақыша қолжетімсіз. Кейінірек қайталаңыз.';

  @override
  String get errorAINotConfigured =>
      'AI-қызмет бапталмаған. Әкімшіге хабарласыңыз.';

  @override
  String get errorAIEmpty => 'AI-дан бос жауап. Қайталаңыз.';

  @override
  String get errorAIParse => 'AI жауабын өңдеу қатесі. Қайталаңыз.';

  @override
  String get errorGenerateWorkout =>
      'Жаттығуды жасау мүмкін болмады. Кейінірек қайталаңыз.';

  @override
  String get errorSaveCheckin =>
      'Сауалнаманы сақтау мүмкін болмады. Кейінірек қайталаңыз.';

  @override
  String get errorLoadCheckin =>
      'Сауалнаманы жүктеу мүмкін болмады. Қосылымды тексеріңіз.';

  @override
  String get errorSaveProfile =>
      'Профильді жаңарту мүмкін болмады. Кейінірек қайталаңыз.';

  @override
  String get errorLoadProfile =>
      'Профильді жүктеу мүмкін болмады. Қосылымды тексеріңіз.';

  @override
  String get errorAuthStatus => 'Авторизация мәртебін тексеру мүмкін болмады';

  @override
  String get errorAuthSignIn => 'Кіру мүмкін болмады. Кейінірек қайталаңыз.';

  @override
  String get errorAuthSignUp => 'Тіркелу мүмкін болмады. Кейінірек қайталаңыз.';

  @override
  String get errorGeneral => 'Қате орын алды. Қайталаңыз.';

  @override
  String get errorPermissionDenied =>
      'Әрекетті орындау үшін құқықтар жеткіліксіз';

  @override
  String get errorTooManyRequests =>
      'Өтінірек көп әрекет. Кейінірек қайталаңыз.';

  @override
  String get errorInvalidCredentials => 'Жүйе немесе құпия сөз қате';

  @override
  String get errorEmailInUse => 'Бұл email қазірдең тіркелген';

  @override
  String get errorWeakPassword => 'Құпия сөз кемінде 6 таңбадан тұруы керек';

  @override
  String get errorNotAuthenticated => 'Пайдаланушы авторизацияланбаған';
}
