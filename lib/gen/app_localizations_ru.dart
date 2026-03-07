// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'AI Health Coach';

  @override
  String get splashSubtitle => 'Ваш персональный тренер';

  @override
  String get onboardingErrorAuth => 'Ошибка: пользователь не авторизован';

  @override
  String get onboardingErrorSave =>
      'Не удалось сохранить профиль. Попробуйте позже.';

  @override
  String get onboardingRetry => 'Повторить';

  @override
  String get onboardingBtnBack => 'Назад';

  @override
  String get onboardingBtnNext => 'Далее';

  @override
  String get onboardingBtnFinish => 'Завершить';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать!';

  @override
  String get onboardingWelcomeText =>
      'Давайте создадим ваш индивидуальный профиль здоровья, чтобы тренировки были безопасными и эффективными.';

  @override
  String get onboardingBasicTitle => 'Расскажите о себе';

  @override
  String get onboardingNameField => 'Ваше имя';

  @override
  String get onboardingGenderTitle => 'Ваш пол';

  @override
  String get onboardingGenderMale => 'Мужской';

  @override
  String get onboardingGenderFemale => 'Женский';

  @override
  String get onboardingGenderNotSpecified => 'Не указывать';

  @override
  String onboardingAgeText(int age) {
    return 'Возраст: $age лет';
  }

  @override
  String onboardingWeightText(String weight) {
    return 'Вес: $weight кг';
  }

  @override
  String get onboardingActivityLevelTitle => 'Уровень активности';

  @override
  String get onboardingHealthTitle => 'Проблемы со здоровьем';

  @override
  String get onboardingHealthText =>
      'Выберите всё, что к вам относится. Это поможет избежать опасных упражнений.';

  @override
  String get onboardingHealthInfo => 'Если проблем нет, просто нажмите «Далее»';

  @override
  String get onboardingGoalsTitle => 'Ваши цели';

  @override
  String get onboardingGoalsText => 'Что для вас сейчас важнее всего?';

  @override
  String get goalRelieveBackPain => 'Избавиться от боли в спине';

  @override
  String get goalStrengthenCore => 'Укрепить мышечный корсет';

  @override
  String get goalRecoverFromInjury => 'Восстановиться после травмы';

  @override
  String get goalImproveFlexibility => 'Улучшить гибкость';

  @override
  String get goalMaintainGeneralTone => 'Поддержать общий тонус';

  @override
  String get loginTitle => 'С возвращением!';

  @override
  String get loginSubtitle => 'Войдите, чтобы продолжить тренировки';

  @override
  String get loginEmailLabel => 'Электронная почта';

  @override
  String get loginPasswordLabel => 'Пароль';

  @override
  String get loginForgotPassword => 'Забыли пароль?';

  @override
  String get loginButton => 'Войти';

  @override
  String get loginNoAccount => 'У вас нет учетной записи?';

  @override
  String get loginRegisterLink => 'Зарегистрироваться';

  @override
  String get loginResetSent => 'Ссылка для сброса пароля отправлена';

  @override
  String get loginFillEmail => 'Сначала введите email';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get registerSubtitle => 'Создайте аккаунт для работы с тренером';

  @override
  String get registerNameLabel => 'Имя';

  @override
  String get registerEmailLabel => 'Электронная почта';

  @override
  String get registerPasswordLabel => 'Пароль';

  @override
  String get registerConfirmPasswordLabel => 'Подтвердите пароль';

  @override
  String get registerButton => 'Зарегистрироваться';

  @override
  String get registerHaveAccount => 'У вас уже есть аккаунт?';

  @override
  String get registerLoginLink => 'Войти';

  @override
  String get registerPasswordMismatch => 'Пароли не совпадают';

  @override
  String homeGreeting(String name) {
    return 'Привет, $name! 👋';
  }

  @override
  String get homeGreetingDefault => 'Привет! 👋';

  @override
  String get homeSubtitle => 'Как ты себя чувствуешь сегодня?';

  @override
  String get homeStartCheckin => '✅  Пройти ежедневный опрос';

  @override
  String get homeCheckinDone => '✅  Опрос пройден';

  @override
  String get homeSectionWorkouts => 'Быстрая тренировка';

  @override
  String get homeWorkoutLfk => 'ЛФК';

  @override
  String get homeWorkoutStretching => 'Растяжка';

  @override
  String get homeWorkoutStrength => 'Силовая';

  @override
  String get homeWorkoutCardio => 'Кардио';

  @override
  String get homeCheckinNotice => 'Перед тренировкой пройдите опрос';

  @override
  String get homeProfileNotLoaded => 'Профиль не загружен. Попробуйте позже.';

  @override
  String get checkinTitle => 'Как вы себя чувствуете?';

  @override
  String get checkinMoodLabel => 'Настроение';

  @override
  String get checkinEnergyLabel => 'Энергия';

  @override
  String get checkinPainLabel => 'Уровень боли';

  @override
  String get checkinSleepLabel => 'Качество сна';

  @override
  String get checkinStressLabel => 'Стресс';

  @override
  String get checkinButton => 'Продолжить';

  @override
  String get checkinMoodHints => 'Ужасно;Плохо;Нормально;Хорошо;Отлично';

  @override
  String get checkinEnergyHints =>
      'Очень низкая;Низкая;Нормальная;Высокая;Полон энергии';

  @override
  String get checkinPainHints => 'Очень сильная;Сильная;Умеренная;Слабая;Нет';

  @override
  String get checkinSleepHints =>
      'Очень плохой;Плохой;Нормальный;Хороший;Отличный';

  @override
  String get checkinStressHints => 'Очень высокий;Высокий;Умеренный;Низкий;Нет';

  @override
  String get historyTitle => 'История';

  @override
  String get historyTabStats => 'Статистика';

  @override
  String get historyTabWorkouts => 'Тренировки';

  @override
  String get historyWeekChart => 'Тренировки за неделю';

  @override
  String get historyWorkoutsCount => 'Тренировки';

  @override
  String get historyTotalMinutes => 'Всего минут';

  @override
  String get historyByType => 'По типам';

  @override
  String get historyEmpty => 'История пуста';

  @override
  String get historyLoading => 'Загружаем историю...';

  @override
  String get historyOffline =>
      'Нет подключения к интернету.\nПовторите после подключения к интернету.';

  @override
  String get historyOfflineRetry => 'Повторить';

  @override
  String get historyLoadError => 'Не удалось загрузить историю';

  @override
  String get historyRecentWorkouts => 'Последние тренировки';

  @override
  String get historyTabWeek => 'Неделя';

  @override
  String get historyTabMonth => 'Месяц';

  @override
  String get historyWorkoutsLabel => 'Тренировок';

  @override
  String get historyMinutesLabel => 'Минут';

  @override
  String get historyTypesTitle => 'Типы тренировок';

  @override
  String get historyMinShort => 'мин';

  @override
  String get historyTypeLfk => 'ЛФК';

  @override
  String get historyTypeStretching => 'Растяжка';

  @override
  String get historyTypeStrength => 'Силовая';

  @override
  String get historyTypeCardio => 'Кардио';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileSettingsTooltip => 'Настройки';

  @override
  String get profileSectionPersonal => 'Личные данные';

  @override
  String get profileAge => 'Возраст';

  @override
  String profileAgeValue(int age) {
    return '$age лет';
  }

  @override
  String get profileHeight => 'Рост';

  @override
  String profileHeightValue(String height) {
    return '$height см';
  }

  @override
  String get profileWeight => 'Вес';

  @override
  String profileWeightValue(String weight) {
    return '$weight кг';
  }

  @override
  String get profileGender => 'Пол';

  @override
  String get profileSectionHealth => 'Здоровье и Цели';

  @override
  String get profileActivity => 'Активность';

  @override
  String get profileGoal => 'Цель';

  @override
  String get profileLimitations => 'Ограничения';

  @override
  String get profileLogout => 'Выйти из аккаунта';

  @override
  String get profileLoadError => 'Не удалось загрузить профиль';

  @override
  String get profileNotFound => 'Профиль не найден';

  @override
  String get profileNotFoundMessage => 'Пройдите анкету или обновите экран.';

  @override
  String get profileLoading => 'Загрузка профиля...';

  @override
  String get profileOffline =>
      'Нет подключения к интернету.\nПопробуйте после подключения к сети.';

  @override
  String get profileRetry => 'Повторить';

  @override
  String get profileGenderMale => 'Мужской';

  @override
  String get profileGenderFemale => 'Женский';

  @override
  String get profileGenderNotSpecified => 'Не указан';

  @override
  String get profileActivityLow => 'Низкая';

  @override
  String get profileActivityModerate => 'Умеренная';

  @override
  String get profileActivityHigh => 'Высокая';

  @override
  String get editProfileTitle => 'Редактировать профиль';

  @override
  String get editProfileSectionBasic => 'Основное';

  @override
  String get editProfileNameLabel => 'Имя';

  @override
  String get editProfileGenderLabel => 'Пол';

  @override
  String get editProfileGenderMale => 'Мужской';

  @override
  String get editProfileGenderFemale => 'Женский';

  @override
  String get editProfileGenderNotSpecified => 'Не указан';

  @override
  String get editProfileSectionPhysical => 'Физические показатели';

  @override
  String get editProfileAgeLabel => 'Возраст';

  @override
  String get editProfileHeightLabel => 'Рост (см)';

  @override
  String get editProfileWeightLabel => 'Вес (кг)';

  @override
  String get editProfileSectionGoals => 'Цели и Активность';

  @override
  String get editProfileActivityLabel => 'Уровень активности';

  @override
  String get editProfileActivityLow => 'Низкая (сидячий)';

  @override
  String get editProfileActivityModerate => 'Умеренная (1-3 тренировки)';

  @override
  String get editProfileActivityHigh => 'Высокая (3+ тренировки)';

  @override
  String get editProfileGoalsLabel => 'Цели';

  @override
  String get editProfileSectionInjuries => 'Травмы и ограничения';

  @override
  String get editProfileAddInjuryLabel => 'Добавить травму/ограничение';

  @override
  String get editProfileAddInjuryHint => 'Например: боль в колене';

  @override
  String get editProfileAddButton => 'Добавить';

  @override
  String get editProfileCancel => 'Отмена';

  @override
  String get editProfileSave => 'Сохранить';

  @override
  String get editProfileValidateName => 'Введите ваше имя';

  @override
  String editProfileValidateNameLength(int max) {
    return 'Имя не более $max символов';
  }

  @override
  String get editProfileValidateAge => 'Введите корректный возраст';

  @override
  String editProfileValidateAgeRange(int min, int max) {
    return 'Возраст $min-$max';
  }

  @override
  String get editProfileValidateHeight => 'Введите корректный рост';

  @override
  String editProfileValidateHeightRange(int min, int max) {
    return 'Рост $min-$max см';
  }

  @override
  String get editProfileValidateWeight => 'Введите корректный вес';

  @override
  String editProfileValidateWeightRange(int min, int max) {
    return 'Вес $min-$max кг';
  }

  @override
  String editProfileValidateGoalsLength(int max) {
    return 'Цель не более $max символов';
  }

  @override
  String editProfileInjuryTooLong(int max) {
    return 'Ограничение не более $max символов';
  }

  @override
  String editProfileMaxInjuries(int max) {
    return 'Можно добавить до $max ограничений';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsReminderTitle => 'Напоминания о тренировках';

  @override
  String get settingsReminderSubtitle => 'Настройте время и дни напоминаний';

  @override
  String get settingsReminderEnable => 'Включить напоминания';

  @override
  String get settingsReminderActive => 'Напоминания включены';

  @override
  String get settingsReminderInactive => 'Напоминания отключены';

  @override
  String get settingsReminderPermissionDenied =>
      'Разрешение на уведомления не предоставлено. Включите в настройках устройства.';

  @override
  String get settingsTimeTitle => 'Время напоминания';

  @override
  String get settingsDaysTitle => 'Дни недели';

  @override
  String get settingsPresetWeekdays => 'Будни';

  @override
  String get settingsPresetEveryday => 'Каждый день';

  @override
  String get settingsPresetAlternate => 'Через день';

  @override
  String get settingsDayMon => 'Пн';

  @override
  String get settingsDaySun => 'Вс';

  @override
  String get settingsDayTue => 'Вт';

  @override
  String get settingsDayWed => 'Ср';

  @override
  String get settingsDayThu => 'Чт';

  @override
  String get settingsDayFri => 'Пт';

  @override
  String get settingsDaySat => 'Сб';

  @override
  String get workoutSelectionTitle => 'Выбор тренировки';

  @override
  String get workoutSelectionQuestion =>
      'Какую тренировку вы бы хотели сегодня?';

  @override
  String get workoutSelectionHint =>
      'Выберите тип, AI создаст персональную программу';

  @override
  String get workoutTypeLfk => 'ЛФК';

  @override
  String get workoutTypeStretching => 'Растяжка';

  @override
  String get workoutTypeStrength => 'Силовая';

  @override
  String get workoutTypeCardio => 'Кардио';

  @override
  String get workoutDescLfk => 'Лечебная физкультура для восстановления';

  @override
  String get workoutDescStretching => 'Упражнения на гибкость и растяжку';

  @override
  String get workoutDescStrength => 'Силовые упражнения для укрепления мышц';

  @override
  String get workoutDescCardio => 'Кардио для выносливости';

  @override
  String get workoutRetry => 'Повторить';

  @override
  String get workoutProfileNotLoaded =>
      'Профиль не загружен. Попробуйте позже.';

  @override
  String get workoutCheckinRequired => 'Сначала пройдите опрос о здоровье';

  @override
  String get workoutSavedWorkouts => 'Сохранённые тренировки';

  @override
  String workoutMinutesShort(int minutes) {
    return '$minutes мин';
  }

  @override
  String get workoutSecondsUnitShort => 'сек';

  @override
  String get workoutRepsUnitShort => 'повт';

  @override
  String get workoutIntensityRest => 'Отдых';

  @override
  String get workoutIntensityLight => 'Лёгкая';

  @override
  String get workoutIntensityModerate => 'Умеренная';

  @override
  String get workoutIntensityHigh => 'Высокая';

  @override
  String workoutTimeAgoMinutes(int count) {
    return '$count мин назад';
  }

  @override
  String workoutTimeAgoHours(int count) {
    return '$count ч назад';
  }

  @override
  String workoutTimeAgoDays(int count) {
    return '$count дн назад';
  }

  @override
  String get workoutSessionTitle => 'Незавершённая тренировка';

  @override
  String get workoutSessionSubtitle => 'У вас есть сохранённая тренировка';

  @override
  String workoutSessionSaved(String time) {
    return 'Сохранено: $time';
  }

  @override
  String get workoutSessionContinue => 'Продолжить тренировку';

  @override
  String get workoutSessionNew => 'Начать новую';

  @override
  String workoutGenerating(String label) {
    return 'Создаём тренировку \"$label\"';
  }

  @override
  String get workoutGeneratingAnalyzingProfile =>
      'Анализируем ваш профиль и состояние...';

  @override
  String get workoutGeneratingSelectingSafeExercises =>
      'Подбираем безопасные упражнения...';

  @override
  String get workoutGeneratingAdaptingIntensity =>
      'Адаптируем интенсивность под самочувствие...';

  @override
  String get workoutGeneratingCreatingProgram =>
      'Собираем персональную программу...';

  @override
  String get workoutGeneratingValidatingSafety =>
      'Проверяем безопасность плана...';

  @override
  String get workoutCancel => 'Отмена';

  @override
  String get workoutPreviewTitle => 'Ваша тренировка';

  @override
  String get workoutPreviewNotFound => 'Тренировка не найдена';

  @override
  String get workoutPreviewWarmup => 'Разминка';

  @override
  String get workoutPreviewMain => 'Основные упражнения';

  @override
  String get workoutPreviewCooldown => 'Заминка';

  @override
  String workoutPreviewExercises(int count) {
    return '$count упр.';
  }

  @override
  String get workoutPreviewStart => 'Начать тренировку';

  @override
  String get workoutPlanCreated => 'План тренировок создан';

  @override
  String get workoutPlayerTitle => 'Тренировка';

  @override
  String get workoutPlayerReady => 'Готово к старту';

  @override
  String get workoutPlayerWarmup => 'Разминка';

  @override
  String get workoutPlayerMainPart => 'Основная часть';

  @override
  String get workoutPlayerCooldown => 'Заминка';

  @override
  String get workoutPlayerStartWorkout => 'Начать тренировку';

  @override
  String get workoutPlayerSkipExercise => 'Пропустить упражнение';

  @override
  String get workoutPlayerFinishWorkout => 'Завершить тренировку';

  @override
  String get workoutPlayerPainButton => 'Боль / Дискомфорт';

  @override
  String workoutPlayerExerciseOf(int current, int total) {
    return 'Упражнение $current / $total';
  }

  @override
  String get workoutPlayerMinutes => 'МИНУТЫ';

  @override
  String get workoutPlayerSeconds => 'СЕКУНДЫ';

  @override
  String get workoutPlayerReps => 'ПОВТОРЕНИЯ';

  @override
  String get workoutPlayerRest => 'Отдых';

  @override
  String workoutPlayerRestSeconds(int seconds) {
    return '$seconds сек';
  }

  @override
  String workoutPlayerNextSet(String name) {
    return 'Далее: $name';
  }

  @override
  String get workoutPlayerAutoResume =>
      'Упражнение продолжится автоматически после таймера';

  @override
  String get workoutPlayerContinue => 'Продолжить';

  @override
  String get workoutPlayerAiInsight => 'ИИ-ИНСАЙТ';

  @override
  String get workoutPlayerAiNote => 'Заметка AI-доктора';

  @override
  String get workoutPlayerNoDescription =>
      'Дополнительное описание отсутствует.';

  @override
  String get workoutPlayerAiLocalizedPending =>
      'Адаптируем AI-пояснение под текущий язык...';

  @override
  String get workoutPlayerAiLocalizedUnavailable =>
      'Локализованное AI-пояснение временно недоступно.';

  @override
  String get workoutPlayerGotIt => 'Понятно';

  @override
  String get workoutPlayerClose => 'Закрыть';

  @override
  String get workoutPlayerExitTitle => 'Завершить тренировку?';

  @override
  String get workoutPlayerExitMessage => 'Прогресс не будет сохранён';

  @override
  String get workoutPlayerExitCancel => 'Отмена';

  @override
  String get workoutPlayerExitConfirm => 'Завершить';

  @override
  String get workoutPlayerSearchUnavailable =>
      'Ссылка для поиска видео недоступна';

  @override
  String get workoutPlayerAnimation => 'Анимация';

  @override
  String get painWhereTitle => 'Где болит?';

  @override
  String get painIntensityTitle => 'Насколько это больно?';

  @override
  String get painActionTitle => 'Что нам делать?';

  @override
  String get painSelectArea => 'Выберите зону боли';

  @override
  String painCurrentExercise(String name) {
    return 'Текущее упражнение: $name';
  }

  @override
  String get painCancelContinue => 'Отменить, продолжить упражнение';

  @override
  String painAreaText(String area) {
    return 'Зона: $area';
  }

  @override
  String get painRateIntensity => 'Оцените интенсивность боли';

  @override
  String painLevelText(int level) {
    return 'Уровень боли: $level/10';
  }

  @override
  String get painLocationLowerBack => 'Поясница';

  @override
  String get painLocationUpperBack => 'Спина (верхняя)';

  @override
  String get painLocationNeck => 'Шея';

  @override
  String get painLocationKnees => 'Колени';

  @override
  String get painLocationShoulders => 'Плечи';

  @override
  String get painLocationWrists => 'Запястья';

  @override
  String get painLocationAnkle => 'Голеностоп';

  @override
  String get painLocationHips => 'Бёдра/тазобедренный';

  @override
  String get painIntensity1 => 'Лёгкий дискомфорт';

  @override
  String get painIntensity1Sub => 'Почти не мешает';

  @override
  String get painIntensity2 => 'Слабая боль';

  @override
  String get painIntensity2Sub => 'Терпимо';

  @override
  String get painIntensity3 => 'Небольшая боль';

  @override
  String get painIntensity3Sub => 'Заметно, но можно продолжить';

  @override
  String get painIntensity4 => 'Умеренная боль';

  @override
  String get painIntensity4Sub => 'Отвлекает внимание';

  @override
  String get painIntensity5 => 'Средняя боль';

  @override
  String get painIntensity5Sub => 'Нужно изменить технику';

  @override
  String get painIntensity6 => 'Ощутимая боль';

  @override
  String get painIntensity6Sub => 'Трудно продолжать';

  @override
  String get painIntensity7 => 'Сильная боль';

  @override
  String get painIntensity7Sub => 'Нужен перерыв';

  @override
  String get painIntensity8 => 'Очень сильная боль';

  @override
  String get painIntensity8Sub => 'Лучше остановиться';

  @override
  String get painIntensity9 => 'Резкая боль';

  @override
  String get painIntensity9Sub => 'Необходим отдых';

  @override
  String get painIntensity10 => 'Невыносимо';

  @override
  String get painIntensity10Sub => 'Нужна помощь врача';

  @override
  String get painActionLightTitle => 'Что бы вы хотели сделать?';

  @override
  String get painActionLightSubtitle => 'Лёгкий дискомфорт — можно продолжить';

  @override
  String get painActionModerateTitle => 'Рекомендуем осторожность';

  @override
  String get painActionModerateSubtitle =>
      'Рекомендуем заменить упражнение или отдохнуть';

  @override
  String get painActionSevereTitle => '⚠️ Нужен отдых';

  @override
  String get painActionSevereSubtitle =>
      'При сильной боли лучше остановиться или отдохнуть';

  @override
  String get painActionDefault => 'Выберите действие';

  @override
  String get painContinueExercise => 'Продолжить упражнение';

  @override
  String get painContinueSub => 'Боль терпимая, продолжаю';

  @override
  String get painReplaceExercise => 'Заменить упражнение';

  @override
  String get painReplaceSub => 'AI подберёт безопасную альтернативу';

  @override
  String get painReplaceModSub => 'Рекомендуется при умеренной боли';

  @override
  String get painBreak2min => 'Перерыв 2 минуты';

  @override
  String get painBreak2minSub => 'Короткий отдых';

  @override
  String get painBreak5min => 'Перерыв 5 минут';

  @override
  String get painBreak5minSub => 'Отдохните и прислушайтесь к телу';

  @override
  String get painBreak10min => 'Перерыв 10 минут';

  @override
  String get painBreak10minSub => 'Длительный отдых с советами';

  @override
  String get painEndWorkout => 'Завершить тренировку';

  @override
  String get painEndWorkoutSaveSub => 'Сохраним прогресс';

  @override
  String get painEndWorkoutHealthSub => 'Здоровье важнее — отдохните сегодня';

  @override
  String get painSevereWarning =>
      'При сильной боли рекомендуем обратиться к врачу';

  @override
  String get painRestTitle => 'Перерыв';

  @override
  String get painRestRemaining => 'осталось';

  @override
  String get painRestTips => 'Советы для отдыха:';

  @override
  String get painRestContinueEarly => 'Продолжить раньше';

  @override
  String get painRestTipLight =>
      'Глубоко вдохните и выдохните.\nРасслабьте напряжённые мышцы.';

  @override
  String get painRestTipModerate =>
      'Плавно помассируйте зону боли.\nВыпейте воды и спокойно дышите.';

  @override
  String get painRestTipSevere =>
      'Полностью расслабьтесь.\nЕсли боль не стихает, обратитесь к врачу.';

  @override
  String get painReplacingTitle => 'Поиск замены';

  @override
  String get painReplacingText => 'AI ищет безопасную замену';

  @override
  String painReplacingArea(String area) {
    return 'Зона боли: $area';
  }

  @override
  String get completionTitle => 'Отличная работа!';

  @override
  String completionMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String completionExercises(int count) {
    return '$count упр.';
  }

  @override
  String completionPainReports(int count) {
    return 'Жалоб на боль: $count';
  }

  @override
  String get completionAnalyzing => 'AI анализирует вашу тренировку...';

  @override
  String completionTips(int count) {
    return 'Советы ($count)';
  }

  @override
  String get completionShowAll => 'Показать все';

  @override
  String get completionCollapse => 'Свернуть';

  @override
  String get completionRecoveryPlan => 'План восстановления';

  @override
  String get completionRecoveryBrief => 'Кратко, без перегруза';

  @override
  String get completionRecoveryExpand => 'Откройте, чтобы посмотреть шаги';

  @override
  String completionRestDuration(String duration) {
    return 'Отдых: $duration';
  }

  @override
  String get completionHideSteps => 'Скрыть шаги';

  @override
  String completionMoreSteps(int count) {
    return 'Ещё шаги ($count)';
  }

  @override
  String get completionNutrition => 'Питание';

  @override
  String get completionSleep => 'Сон';

  @override
  String get completionGoHome => 'На главную';

  @override
  String get categoryBack => 'Спина';

  @override
  String get categoryLegs => 'Ноги';

  @override
  String get categoryArms => 'Руки';

  @override
  String get categoryCore => 'Кор';

  @override
  String get categoryNeck => 'Шея';

  @override
  String get categoryGeneral => 'Общее';

  @override
  String get routeNotFound => 'Страница не найдена';

  @override
  String get checkinSummaryLight => 'Сегодня рекомендуется легкая тренировка.';

  @override
  String get homeOffline =>
      'Нет подключения к интернету.\nПовторите после подключения к интернету.';

  @override
  String get onboardingDefaultName => 'Пользователь';

  @override
  String get homeUser => 'Пользователь';

  @override
  String get profileRestrictions => 'Ограничения';

  @override
  String get settingsConfigureReminders => 'Установите время и дни напоминания';

  @override
  String get navExitPrompt => 'Нажмите \"Назад\" еще раз для выхода';

  @override
  String get energyVeryHigh => 'Очень высокий';

  @override
  String get checkinNoPain => 'Нет боли';

  @override
  String get homeLoadingData => 'Загрузка данных...';

  @override
  String get authHintPasswordMin => 'Минимум 6 символов';

  @override
  String get settingsWorkoutReminders => 'Напоминания о тренировках';

  @override
  String get navProfile => 'Профиль';

  @override
  String get homeProgress => 'Прогресс';

  @override
  String get checkinNotes => 'Примечания';

  @override
  String get homeMinutes => 'Минуты';

  @override
  String get videoSearchAvailable => 'Видео доступно через поиск на YouTube';

  @override
  String get checkinPainLevel => 'Уровень боли';

  @override
  String get settingsDaysOfWeek => 'Дни недели';

  @override
  String get energyVeryLow => 'Очень низкий';

  @override
  String get settingsRemindersOff => 'Напоминания отключены';

  @override
  String get homeOfflineRetry => 'Повторить';

  @override
  String get checkinSummaryRest =>
      'Сегодня рекомендуется отдых и восстановление.';

  @override
  String get homeTotalMinutes => 'Всего минут';

  @override
  String get checkinSymptomsTitle => 'Симптомы';

  @override
  String get profileKg => 'кг';

  @override
  String get settingsPermissionDenied =>
      'Разрешение на уведомление отклонено. Включите его в настройках.';

  @override
  String get homeStartStreak => 'Начни свою серию';

  @override
  String get profileCm => 'см';

  @override
  String get checkinNotesHint =>
      'Любые дополнительные симптомы или комментарии';

  @override
  String get authHintPasswordRepeat => 'Повторите пароль';

  @override
  String get checkinStrongPain => 'Сильная боль';

  @override
  String get checkinWhereHurts => 'Где болит?';

  @override
  String get homeQuickActions => 'Быстрые действия';

  @override
  String homeStreakDays(int count) {
    return '$count-дневная серия';
  }

  @override
  String get videoOpenSearch => 'Открыть поиск в приложении';

  @override
  String get checkinToWorkout => 'Перейти на тренировку';

  @override
  String get settingsRemindersActive => 'Напоминания включены';

  @override
  String get navWorkout => 'Тренировка';

  @override
  String get checkinRedoSurvey => 'Повторно пройти опрос';

  @override
  String get homeGoodEvening => 'Добрый вечер';

  @override
  String get checkinSummaryGreat =>
      'Отличное государство. Вы можете провести полноценную тренировку.';

  @override
  String get checkinBetterRest => 'Лучше сегодня отдохнуть и восстановиться';

  @override
  String get energyLow => 'Низкий';

  @override
  String get checkinSleep => 'Спать';

  @override
  String get checkinSleepQuality => 'Качество сна';

  @override
  String get videoNetwork => 'Видео';

  @override
  String get homeLoadingAnalytics => 'Загрузка аналитики...';

  @override
  String get checkinAlreadyCompleted => 'Сегодняшняя регистрация уже завершена';

  @override
  String get profileYears => 'годы';

  @override
  String get navHome => 'Главная';

  @override
  String get homeTapForDetailedStats =>
      'Нажмите, чтобы просмотреть подробную статистику';

  @override
  String get checkinRecommendation => 'Рекомендация';

  @override
  String get settingsEveryDay => 'Каждый день';

  @override
  String get homeAverage => 'Средний';

  @override
  String get checkinMood => 'Настроение';

  @override
  String get energyHigh => 'Высокий';

  @override
  String get settingsReminderTime => 'Время напоминания';

  @override
  String checkinRecommendedIntensity(String intensity) {
    return 'Рекомендуемая интенсивность: $intensity';
  }

  @override
  String get profileHealthGoals => 'Здоровье и цели';

  @override
  String get homeGoodAfternoon => 'Добрый день';

  @override
  String get settingsEnableReminders => 'Включить напоминания';

  @override
  String get homeStatistics => 'Статистика';

  @override
  String get checkinSleepBad => 'Плохо';

  @override
  String get videoYoutube => 'видео на YouTube';

  @override
  String get homeThisWeek => 'На этой неделе';

  @override
  String get homeReadyForWorkout => 'Готовы к сегодняшней тренировке?';

  @override
  String get homeGoodMorning => 'Доброе утро';

  @override
  String get navHistory => 'История';

  @override
  String get checkinTryAgain => 'Попробуйте еще раз';

  @override
  String get checkinEnergyLevel => 'Уровень энергии';

  @override
  String get checkinSymptomsDescription =>
      'Выберите все симптомы, которые вы чувствуете сегодня';

  @override
  String get checkinMoodTitle => 'Ваше настроение';

  @override
  String get profileMyProfile => 'Мой профиль';

  @override
  String get checkinPainDescription => 'Оцените свой текущий уровень боли';

  @override
  String get checkinSleepGreat => 'Большой';

  @override
  String get homeWorkouts => 'Тренировки';

  @override
  String get homeAiRecommendations => 'Рекомендации ИИ';

  @override
  String get checkinMoodDescription =>
      'Как ваше эмоциональное состояние сегодня?';

  @override
  String get checkinMoodHappy => 'Отлично';

  @override
  String get checkinMoodEnergized => 'Энергичный';

  @override
  String get checkinMoodNeutral => 'Нормально';

  @override
  String get checkinMoodTired => 'Устал';

  @override
  String get checkinMoodStressed => 'Стресс';

  @override
  String get checkinSymptomHeadache => 'Головная боль';

  @override
  String get checkinSymptomBackPain => 'Боль в спине';

  @override
  String get checkinSymptomMuscleStiffness => 'Скованность в мышцах';

  @override
  String get checkinSymptomFatigue => 'Усталость';

  @override
  String get checkinSymptomNausea => 'Тошнота';

  @override
  String get checkinSymptomDizziness => 'Головокружение';

  @override
  String get checkinPainLocationOther => 'Другое';

  @override
  String get checkinSummaryModerate => 'Рекомендуется умеренная тренировка.';

  @override
  String get checkinEnergy => 'Энергия';

  @override
  String get settingsWeekdays => 'Будни';

  @override
  String get profileSignOut => 'выход';

  @override
  String get energyMedium => 'Середина';

  @override
  String get settingsEveryOtherDay => 'Через день';

  @override
  String get profilePersonalData => 'Персональные данные';

  @override
  String get homeProgressStart => 'Начните свой прогресс сегодня';

  @override
  String get videoUnsupported => 'Видео недоступно';

  @override
  String get checkinEnergyDescription => 'Сколько у вас энергии сейчас?';

  @override
  String get activityLevelModerate => 'Умеренная активность';

  @override
  String get authErrorEmailInvalid => 'Неверный формат email';

  @override
  String get authErrorEmailEmpty => 'Введите email';

  @override
  String get injuryMeniscus => 'Травма мениска';

  @override
  String get injuryProtrusion => 'Протрузия межпозвонковых дисков';

  @override
  String get injuryWrist => 'Травма запястья';

  @override
  String get injuryKneeArthrosis => 'Артроз коленного сустава';

  @override
  String get authErrorPasswordEmpty => 'Введите пароль';

  @override
  String get authErrorPasswordShort => 'Пароль должен быть не менее 6 символов';

  @override
  String get injuryShoulder => 'Проблемы с плечевым суставом';

  @override
  String get injuryScoliosis => 'Сколиоз';

  @override
  String get injuryHernia => 'Грыжа поясничного отдела (L4-L5, L5-S1)';

  @override
  String get injuryHipArthrosis => 'Артроз тазобедренного сустава';

  @override
  String get injuryNeckPain => 'Боли в шейном отделе';

  @override
  String get injuryOsteochondrosis => 'Остеохондроз';

  @override
  String get activityLevelSedentary => 'Сидячий образ жизни';

  @override
  String get activityLevelHigh => 'Высокая активность';

  @override
  String get authErrorPasswordConfirm => 'Подтвердите пароль';

  @override
  String get activityLevelLight => 'Легкая активность';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageHint => 'Выберите язык приложения';

  @override
  String get languageKk => 'Казахский';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageEn => 'Английский';

  @override
  String get errorNoConnection => 'Нет подключения к интернету';

  @override
  String get errorTimeout => 'Превышено время ожидания. Попробуйте позже.';

  @override
  String get errorAIQuota => 'Квота AI исчерпана. Попробуйте позже.';

  @override
  String get errorAIUnavailable =>
      'AI-сервис временно недоступен. Попробуйте позже.';

  @override
  String get errorAINotConfigured =>
      'AI-сервис не настроен. Обратитесь к администратору.';

  @override
  String get errorAIEmpty => 'Пустой ответ от AI. Попробуйте снова.';

  @override
  String get errorAIParse => 'Ошибка обработки ответа AI. Попробуйте снова.';

  @override
  String get errorGenerateWorkout =>
      'Не удалось сгенерировать тренировку. Попробуйте позже.';

  @override
  String get errorSaveCheckin =>
      'Не удалось сохранить опрос. Попробуйте позже.';

  @override
  String get errorLoadCheckin =>
      'Не удалось загрузить опрос. Проверьте соединение.';

  @override
  String get errorSaveProfile =>
      'Не удалось обновить профиль. Попробуйте позже.';

  @override
  String get errorLoadProfile =>
      'Не удалось загрузить профиль. Проверьте соединение.';

  @override
  String get errorAuthStatus => 'Не удалось проверить статус авторизации';

  @override
  String get errorAuthSignIn => 'Не удалось выполнить вход. Попробуйте позже.';

  @override
  String get errorAuthSignUp =>
      'Не удалось зарегистрироваться. Попробуйте позже.';

  @override
  String get errorGeneral => 'Произошла ошибка. Попробуйте ещё раз.';

  @override
  String get errorPermissionDenied =>
      'Недостаточно прав для выполнения операции';

  @override
  String get errorTooManyRequests => 'Слишком много попыток. Попробуйте позже.';

  @override
  String get errorInvalidCredentials => 'Неверный логин или пароль';

  @override
  String get errorEmailInUse => 'Этот email уже зарегистрирован';

  @override
  String get errorWeakPassword => 'Пароль должен содержать минимум 6 символов';

  @override
  String get errorNotAuthenticated => 'Пользователь не авторизован';
}
