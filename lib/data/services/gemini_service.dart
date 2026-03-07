import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/services/i_ai_service.dart';
import '../models/user_profile_model.dart';
import '../models/daily_checkin_model.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../models/recovery_plan_model.dart';
import '../models/ai_feedback_models.dart';
import 'openrouter_service.dart';
import 'ai_prompts.dart';

typedef ProviderExecutor =
    Future<String> Function({
      required String prompt,
      bool jsonMode,
      int maxTokens,
      double temperature,
      int maxRetries,
    });

/// Service for generating workouts using Gemini AI or OpenRouter fallback
///
/// Uses a unified [_executeWithProvider] method for all AI calls:
/// OpenRouter (with multi-model fallback) → Gemini → retry on transient errors.
class GeminiService implements IAiService {
  static const int _workoutGenerationMaxTokens = 2200;

  GenerativeModel? _model;
  GenerativeModel? _textModel; // For non-JSON responses
  final OpenRouterService _openRouter;
  final ProviderExecutor? _providerExecutorOverride;
  bool _preferOpenRouter = true;

  GeminiService({
    OpenRouterService? openRouter,
    ProviderExecutor? providerExecutorOverride,
  }) : _openRouter = openRouter ?? OpenRouterService(),
       _providerExecutorOverride = providerExecutorOverride {
    _initModel();
  }

  void _initModel() {
    String? apiKey;
    try {
      if (dotenv.isInitialized) {
        apiKey = dotenv.env['GEMINI_API_KEY'];
      }
    } catch (e) {
      debugPrint(
        'GeminiService: dotenv not initialized or error accessing env: $e',
      );
    }

    if (apiKey != null && apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topP: 0.9,
          maxOutputTokens: 4096,
          responseMimeType: 'application/json',
        ),
      );
      _textModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 500,
        ),
      );
    }

    if (_openRouter.isConfigured) {
      debugPrint(
        'GeminiService: OpenRouter configured (PRIMARY), Gemini enabled as fallback',
      );
    }
    if (_model != null) {
      debugPrint('GeminiService: Gemini API key detected (fallback available)');
    }
  }

  /// Check if any AI provider is configured
  @override
  bool get isConfigured =>
      _providerExecutorOverride != null ||
      _model != null ||
      _openRouter.isConfigured;

  /// Use OpenRouter as primary provider (Gemini remains fallback).
  void useOpenRouter() {
    _preferOpenRouter = true;
    debugPrint('GeminiService: OpenRouter is primary, Gemini fallback enabled');
  }

  /// Use Gemini as primary provider (OpenRouter fallback).
  void useGemini() {
    _preferOpenRouter = false;
    debugPrint('GeminiService: Gemini is primary, OpenRouter fallback enabled');
  }

  // ---------------------------------------------------------------------------
  // Unified provider execution with retry + fallback
  // ---------------------------------------------------------------------------

  /// Execute an AI request with provider fallback and retry.
  ///
  /// Flow: OpenRouter (multi-model) → Gemini → retry once on transient errors.
  /// Returns the raw response text from the AI.
  Future<String> _executeWithProvider({
    required String prompt,
    String languageCode = 'ru',
    bool jsonMode = false,
    int maxTokens = 4096,
    double temperature = 0.7,
    int maxRetries = 1,
  }) async {
    Exception? lastError;
    Exception? openRouterError;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      if (attempt > 0) {
        // Exponential backoff: 1s, 2s, ...
        await Future.delayed(Duration(seconds: attempt));
        debugPrint('GeminiService: Retry attempt $attempt');
      }

      // Optional Gemini-first branch (when explicitly requested).
      if (!_preferOpenRouter && _model != null) {
        try {
          final model = jsonMode ? _model! : (_textModel ?? _model!);
          final response = await model
              .generateContent([Content.text(prompt)])
              .timeout(const Duration(seconds: 30));
          final responseText = response.text;
          if (responseText != null && responseText.isNotEmpty) {
            return responseText;
          }
          lastError = Exception('Gemini returned empty response');
        } catch (e) {
          debugPrint('GeminiService: Gemini failed: $e');
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('quota') || errorStr.contains('exceeded')) {
            lastError = Exception(
              'Квота Gemini API исчерпана. Проверьте OpenRouter (модели/баланс).',
            );
            // Don't retry quota errors
            break;
          }
          lastError = e is Exception ? e : Exception(e.toString());
        }
      }

      // OpenRouter path (default primary, or fallback when Gemini-first fails).
      if (_openRouter.isConfigured) {
        try {
          final responseText = await _openRouter.generateCompletionWithFallback(
            prompt: prompt,
            systemPrompt: AiPrompts.systemPrompt(languageCode: languageCode),
            jsonMode: jsonMode,
            maxTokens: maxTokens,
            temperature: temperature,
          );
          if (responseText != null && responseText.isNotEmpty) {
            return responseText;
          }
          lastError = Exception('OpenRouter returned empty response');
        } catch (e) {
          debugPrint('GeminiService: OpenRouter failed: $e');
          openRouterError = e is Exception ? e : Exception(e.toString());
          lastError = openRouterError;
        }
      }

      // Gemini fallback for default OpenRouter-first flow.
      if (_preferOpenRouter && _model != null) {
        try {
          final model = jsonMode ? _model! : (_textModel ?? _model!);
          final response = await model
              .generateContent([Content.text(prompt)])
              .timeout(const Duration(seconds: 30));
          final responseText = response.text;

          if (responseText != null && responseText.isNotEmpty) {
            return responseText;
          }
          lastError = Exception('Gemini returned empty response');
        } catch (e) {
          debugPrint('GeminiService: Gemini fallback failed: $e');
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('quota') || errorStr.contains('exceeded')) {
            if (openRouterError != null) {
              lastError = Exception(
                'Квота Gemini исчерпана, и OpenRouter недоступен: ${openRouterError.toString()}',
              );
            } else {
              lastError = Exception(
                'Квота Gemini API исчерпана. Проверьте OpenRouter (модели/баланс).',
              );
            }
            // Don't retry quota errors
            break;
          }
          lastError = e is Exception ? e : Exception(e.toString());
        }
      }
    }

    throw lastError ??
        Exception(
          'AI не настроен. Добавьте OPENROUTER_API_KEY или GEMINI_API_KEY в .env',
        );
  }

  Future<String> _requestWithProvider({
    required String prompt,
    String languageCode = 'ru',
    bool jsonMode = false,
    int maxTokens = 4096,
    double temperature = 0.7,
    int maxRetries = 1,
  }) {
    if (_providerExecutorOverride != null) {
      return _providerExecutorOverride(
        prompt: prompt,
        jsonMode: jsonMode,
        maxTokens: maxTokens,
        temperature: temperature,
        maxRetries: maxRetries,
      );
    }
    return _executeWithProvider(
      prompt: prompt,
      languageCode: languageCode,
      jsonMode: jsonMode,
      maxTokens: maxTokens,
      temperature: temperature,
      maxRetries: maxRetries,
    );
  }

  String _normalizeLanguageCode(String languageCode) {
    final normalized = languageCode.trim().toLowerCase();
    if (normalized.startsWith('en')) return 'en';
    if (normalized.startsWith('kk')) return 'kk';
    return 'ru';
  }

  String _localizedText({
    required String languageCode,
    required String ru,
    required String kk,
    required String en,
  }) {
    switch (_normalizeLanguageCode(languageCode)) {
      case 'en':
        return en;
      case 'kk':
        return kk;
      default:
        return ru;
    }
  }

  bool _isLikelyParseError(Object error) {
    if (error is FormatException) return true;
    final text = error.toString().toLowerCase();
    return text.contains('formatexception') ||
        text.contains('ошибка парсинга ответа') ||
        text.contains('unexpected character') ||
        text.contains('invalid json');
  }

  String _buildStrictJsonRetryPrompt(String basePrompt) {
    return '''
$basePrompt

ВАЖНО: Верни строго валидный JSON.
Не используй неэкранированные двойные кавычки внутри строковых значений.
Если нужны кавычки внутри текста, используй «...» или экранирование \\"...\\".
Ответ только JSON, без markdown и без пояснений.
''';
  }

  // ---------------------------------------------------------------------------
  // Contraindications & exercise filtering
  // ---------------------------------------------------------------------------

  /// Convert user injuries to contraindication codes
  List<String> _mapInjuriesToContraindications(List<String> injuries) {
    final mapping = <String, List<String>>{
      'Грыжа поясничного отдела': [Contraindications.lumbarHernia],
      'Грыжа шейного отдела': [Contraindications.cervicalHernia],
      'Грыжа грудного отдела': [Contraindications.thoracicHernia],
      'Протрузия': [Contraindications.lumbarHernia],
      'Травма колена': [Contraindications.kneeInjury],
      'Травма мениска': [Contraindications.kneeInjury],
      'Травма голеностопа': [Contraindications.ankleInjury],
      'Травма плеча': [Contraindications.shoulderInjury],
      'Травма запястья': [Contraindications.wristInjury],
      'Травма тазобедренного сустава': [Contraindications.hipInjury],
      'Сколиоз': [Contraindications.scoliosis],
      'Гипертония': [Contraindications.hypertension],
      'Проблемы с сердцем': [Contraindications.heartProblems],
      'Беременность': [Contraindications.pregnancy],
      'Варикоз': [Contraindications.varicose],
      'Остеопороз': [Contraindications.osteoporosis],
    };

    final result = <String>{};
    for (final injury in injuries) {
      final codes = mapping[injury];
      if (codes != null) {
        result.addAll(codes);
      }
    }
    return result.toList();
  }

  /// Filter exercises based on user contraindications
  List<Exercise> _filterSafeExercises(
    List<Exercise> exercises,
    List<String> userContraindications,
  ) {
    return exercises.where((e) => e.isSafeFor(userContraindications)).toList();
  }

  // ---------------------------------------------------------------------------
  // IAiService implementation
  // ---------------------------------------------------------------------------

  @override
  Future<Workout> generateWorkout({
    required UserProfile profile,
    required DailyCheckIn checkIn,
    required String workoutType,
    required List<Exercise> availableExercises,
    String? targetIntensity,
    String languageCode = 'ru',
  }) async {
    if (!isConfigured) {
      throw Exception(
        'AI API не настроен. Добавьте GEMINI_API_KEY или OPENROUTER_API_KEY в .env',
      );
    }

    final userContraindications = _mapInjuriesToContraindications(
      profile.medicalProfile.injuries,
    );
    final safeExercises = _filterSafeExercises(
      availableExercises,
      userContraindications,
    );

    final prompt = AiPrompts.workoutGeneration(
      profile: profile,
      checkIn: checkIn,
      workoutType: workoutType,
      exercises: safeExercises,
      targetIntensity: targetIntensity,
      languageCode: languageCode,
    );

    final responseText = await _requestWithProvider(
      prompt: prompt,
      languageCode: languageCode,
      jsonMode: true,
      maxTokens: _workoutGenerationMaxTokens,
    );

    try {
      return parseWorkoutResponse(
        responseText,
        profile.uid,
        checkIn.id,
        workoutType,
        languageCode: languageCode,
      );
    } catch (e) {
      if (!_isLikelyParseError(e)) rethrow;
      debugPrint(
        'GeminiService: parse failed, retrying once with stricter JSON prompt',
      );
    }

    final retryResponseText = await _requestWithProvider(
      prompt: _buildStrictJsonRetryPrompt(prompt),
      languageCode: languageCode,
      jsonMode: true,
      maxTokens: _workoutGenerationMaxTokens,
      temperature: 0.2,
      maxRetries: 0,
    );

    return parseWorkoutResponse(
      retryResponseText,
      profile.uid,
      checkIn.id,
      workoutType,
      languageCode: languageCode,
    );
  }

  @override
  Future<WorkoutExercise?> replaceExercise({
    required WorkoutExercise currentExercise,
    required String painLocation,
    required UserProfile profile,
    required List<Exercise> availableExercises,
    String languageCode = 'ru',
  }) async {
    if (!isConfigured) return null;

    final userContraindications = _mapInjuriesToContraindications(
      profile.medicalProfile.injuries,
    );

    final painContraindication = _painLocationToContraindication(painLocation);
    if (painContraindication.isNotEmpty) {
      userContraindications.add(painContraindication);
    }

    final safeExercises = _filterSafeExercises(
      availableExercises,
      userContraindications,
    );

    final prompt = AiPrompts.exerciseReplacement(
      currentExercise: currentExercise,
      painLocation: painLocation,
      safeExercises: safeExercises,
      languageCode: languageCode,
    );

    try {
      final responseText = await _requestWithProvider(
        prompt: prompt,
        languageCode: languageCode,
        jsonMode: true,
        maxTokens: 1024,
      );
      final cleanedText = cleanJsonResponse(responseText);
      final data = jsonDecode(cleanedText) as Map<String, dynamic>;
      return WorkoutExercise.fromMap(data);
    } catch (e) {
      debugPrint('Error replacing exercise: $e');
      return null;
    }
  }

  @override
  Future<String> explainExerciseSafety({
    required String exerciseName,
    required String exerciseDescription,
    required UserProfile profile,
    String languageCode = 'ru',
  }) async {
    if (!isConfigured) {
      return _localizedText(
        languageCode: languageCode,
        ru: 'Упражнение подобрано с учётом ваших ограничений и является безопасным.',
        kk: 'Бұл жаттығу сіздің шектеулеріңіз ескеріліп таңдалған және қауіпсіз.',
        en: 'This exercise was selected with your limitations in mind and is safe for you.',
      );
    }

    final prompt = AiPrompts.exerciseSafety(
      exerciseName: exerciseName,
      exerciseDescription: exerciseDescription,
      profile: profile,
      languageCode: languageCode,
    );

    try {
      final responseText = await _requestWithProvider(
        prompt: prompt,
        languageCode: languageCode,
        jsonMode: false,
        maxTokens: 500,
      );
      return responseText;
    } catch (e) {
      return _localizedText(
        languageCode: languageCode,
        ru: 'Упражнение подобрано с учётом ваших ограничений и является безопасным.',
        kk: 'Бұл жаттығу сіздің шектеулеріңіз ескеріліп таңдалған және қауіпсіз.',
        en: 'This exercise was selected with your limitations in mind and is safe for you.',
      );
    }
  }

  @override
  Future<String> getQuickRecommendation(
    DailyCheckIn checkIn, {
    String languageCode = 'ru',
  }) async {
    if (!isConfigured) {
      return getDefaultRecommendation(checkIn, languageCode: languageCode);
    }

    final prompt = AiPrompts.quickRecommendation(
      checkIn,
      languageCode: languageCode,
    );

    try {
      final responseText = await _requestWithProvider(
        prompt: prompt,
        languageCode: languageCode,
        jsonMode: false,
        maxTokens: 200,
        maxRetries: 0, // Quick recommendation — don't retry
      );
      return responseText;
    } catch (e) {
      return getDefaultRecommendation(checkIn, languageCode: languageCode);
    }
  }

  @override
  Future<PostWorkoutFeedback> generatePostWorkoutFeedback({
    required int durationMinutes,
    required int exercisesCompleted,
    required int totalExercises,
    required String workoutType,
    required int painReports,
    required UserProfile profile,
    List<String>? painLocations,
    String languageCode = 'ru',
  }) async {
    if (!isConfigured) {
      return getDefaultPostWorkoutFeedback(
        durationMinutes: durationMinutes,
        exercisesCompleted: exercisesCompleted,
        painReports: painReports,
        languageCode: languageCode,
      );
    }

    final prompt = AiPrompts.postWorkoutFeedback(
      durationMinutes: durationMinutes,
      exercisesCompleted: exercisesCompleted,
      totalExercises: totalExercises,
      workoutType: workoutType,
      painReports: painReports,
      profile: profile,
      painLocations: painLocations,
      languageCode: languageCode,
    );

    try {
      final responseText = await _requestWithProvider(
        prompt: prompt,
        languageCode: languageCode,
        jsonMode: true,
        maxTokens: 2048, // Increased from 1024 to avoid truncated responses
      );
      return parsePostWorkoutFeedback(
        responseText,
        workoutType,
        durationMinutes,
        painReports,
        languageCode: languageCode,
      );
    } catch (e) {
      debugPrint('Error generating post-workout feedback: $e');
      return getDefaultPostWorkoutFeedback(
        durationMinutes: durationMinutes,
        exercisesCompleted: exercisesCompleted,
        painReports: painReports,
        languageCode: languageCode,
      );
    }
  }

  @override
  Future<PainAdaptedIntensity> getPainAdaptedIntensity({
    required DailyCheckIn todayCheckIn,
    required List<String> recentPainReports,
    required int recentWorkoutCount,
  }) async {
    // This is done locally — no AI call needed
    final painLocationCounts = <String, int>{};
    for (final location in recentPainReports) {
      painLocationCounts[location] = (painLocationCounts[location] ?? 0) + 1;
    }

    final problematicAreas = painLocationCounts.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toList();

    String baseIntensity = todayCheckIn.suggestedIntensity;
    String adjustedIntensity = baseIntensity;
    String reason = '';
    List<String> avoidExercises = [];

    if (problematicAreas.isNotEmpty) {
      if (baseIntensity == WorkoutIntensity.high) {
        adjustedIntensity = WorkoutIntensity.moderate;
        reason =
            'Снижена из-за повторяющихся проблем: ${problematicAreas.join(", ")}';
      } else if (baseIntensity == WorkoutIntensity.moderate) {
        adjustedIntensity = WorkoutIntensity.light;
        reason =
            'Снижена из-за повторяющихся проблем: ${problematicAreas.join(", ")}';
      }

      for (final area in problematicAreas) {
        avoidExercises.addAll(_getExercisesToAvoid(area));
      }
    }

    if (recentWorkoutCount >= 5) {
      if (adjustedIntensity == WorkoutIntensity.high) {
        adjustedIntensity = WorkoutIntensity.moderate;
        reason =
            '${reason.isEmpty ? '' : '$reason. '}Рекомендуется восстановление после активной недели';
      }
    }

    if (todayCheckIn.painLevel >= 7) {
      adjustedIntensity = WorkoutIntensity.light;
      reason = 'Высокий уровень боли сегодня — рекомендуется щадящий режим';
    }

    return PainAdaptedIntensity(
      originalIntensity: baseIntensity,
      adjustedIntensity: adjustedIntensity,
      reason: reason.isEmpty
          ? 'Интенсивность соответствует вашему состоянию'
          : reason,
      problematicAreas: problematicAreas,
      avoidExerciseTypes: avoidExercises.toSet().toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Parsing helpers
  // ---------------------------------------------------------------------------

  @visibleForTesting
  String cleanJsonResponse(String responseText) {
    String cleanedText = responseText.trim();
    // Remove markdown code fences
    if (cleanedText.startsWith('```json')) {
      cleanedText = cleanedText.substring(7);
    }
    if (cleanedText.startsWith('```')) {
      cleanedText = cleanedText.substring(3);
    }
    if (cleanedText.endsWith('```')) {
      cleanedText = cleanedText.substring(0, cleanedText.length - 3);
    }
    // Remove <think>...</think> reasoning blocks (from DeepSeek)
    cleanedText = cleanedText.replaceAll(
      RegExp(r'<think>[\s\S]*?</think>'),
      '',
    );
    return repairJson(cleanedText.trim());
  }

  /// Attempts to repair truncated or malformed JSON
  @visibleForTesting
  String repairJson(String jsonString) {
    final trimmed = jsonString.trim();
    if (trimmed.isEmpty) return '{}';

    var repaired = _escapeInnerQuotesInJsonStrings(trimmed);

    if (_countUnescapedQuotes(repaired).isOdd) {
      repaired = '$repaired"';
    }

    repaired = _appendMissingJsonClosers(repaired);
    return repaired;
  }

  String _escapeInnerQuotesInJsonStrings(String input) {
    final buffer = StringBuffer();
    var inString = false;

    for (int i = 0; i < input.length; i++) {
      final ch = input[i];

      if (ch != '"') {
        buffer.write(ch);
        continue;
      }

      if (_isEscapedQuote(input, i)) {
        buffer.write(ch);
        continue;
      }

      if (!inString) {
        inString = true;
        buffer.write(ch);
        continue;
      }

      final nextChar = _nextSignificantChar(input, i + 1);
      final isClosingQuote =
          nextChar == null ||
          nextChar == ',' ||
          nextChar == '}' ||
          nextChar == ']' ||
          nextChar == ':';

      if (isClosingQuote) {
        inString = false;
        buffer.write(ch);
      } else {
        buffer.write(r'\"');
      }
    }

    return buffer.toString();
  }

  bool _isEscapedQuote(String input, int quoteIndex) {
    var backslashCount = 0;
    var index = quoteIndex - 1;
    while (index >= 0 && input[index] == '\\') {
      backslashCount++;
      index--;
    }
    return backslashCount.isOdd;
  }

  String? _nextSignificantChar(String input, int start) {
    for (int i = start; i < input.length; i++) {
      final ch = input[i];
      if (!RegExp(r'\s').hasMatch(ch)) {
        return ch;
      }
    }
    return null;
  }

  int _countUnescapedQuotes(String text) {
    var count = 0;
    for (int i = 0; i < text.length; i++) {
      if (text[i] == '"' && !_isEscapedQuote(text, i)) {
        count++;
      }
    }
    return count;
  }

  String _appendMissingJsonClosers(String text) {
    final stack = <String>[];
    var inString = false;

    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch == '"' && !_isEscapedQuote(text, i)) {
        inString = !inString;
        continue;
      }
      if (inString) continue;

      if (ch == '{' || ch == '[') {
        stack.add(ch);
      } else if (ch == '}' && stack.isNotEmpty && stack.last == '{') {
        stack.removeLast();
      } else if (ch == ']' && stack.isNotEmpty && stack.last == '[') {
        stack.removeLast();
      }
    }

    if (stack.isEmpty) return text;

    final buffer = StringBuffer(text);
    for (final opener in stack.reversed) {
      buffer.write(opener == '{' ? '}' : ']');
    }
    return buffer.toString();
  }

  String _snippetAroundError(String source, int? offset) {
    if (source.isEmpty) return '';
    final safeOffset = (offset ?? 0).clamp(0, source.length);
    final start = (safeOffset - 100).clamp(0, source.length);
    final end = (safeOffset + 100).clamp(0, source.length);
    return source
        .substring(start, end)
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r');
  }

  @visibleForTesting
  Workout parseWorkoutResponse(
    String responseText,
    String userUid,
    String checkInId,
    String workoutType, {
    String languageCode = 'ru',
  }) {
    final cleanedText = cleanJsonResponse(responseText);

    try {
      final Map<String, dynamic> data = jsonDecode(cleanedText);

      final warmup =
          (data['warmup'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [];

      final mainExercises =
          (data['main_exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [];

      final cooldown =
          (data['cooldown'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [];

      return Workout(
        id: '',
        userUid: userUid,
        title:
            data['title'] ??
            _localizedText(
              languageCode: languageCode,
              ru: 'Персональная тренировка',
              kk: 'Жеке жаттығу',
              en: 'Personalized workout',
            ),
        description: data['description'] ?? '',
        type: workoutType,
        intensity: inferIntensity(data),
        estimatedDuration: data['estimated_duration']?.toInt() ?? 30,
        warmup: warmup,
        mainExercises: mainExercises,
        cooldown: cooldown,
        checkInId: checkInId,
        aiMetadata: {
          'generated_at': DateTime.now().toIso8601String(),
          'model': _openRouter.isConfigured ? 'openrouter' : 'gemini',
          'language_code': _normalizeLanguageCode(languageCode),
        },
      );
    } on FormatException catch (e, stackTrace) {
      final snippet = _snippetAroundError(cleanedText, e.offset);
      debugPrint('_parseWorkoutResponse ERROR: $e');
      debugPrint('_parseWorkoutResponse snippet: $snippet');
      debugPrint('StackTrace: $stackTrace');
      throw FormatException(
        'Ошибка парсинга ответа: ${e.message}',
        cleanedText,
        e.offset,
      );
    } catch (e, stackTrace) {
      debugPrint('_parseWorkoutResponse ERROR: $e');
      debugPrint('StackTrace: $stackTrace');
      throw Exception('Ошибка парсинга ответа: $e');
    }
  }

  @visibleForTesting
  PostWorkoutFeedback parsePostWorkoutFeedback(
    String responseText,
    String workoutType,
    int durationMinutes,
    int painReports, {
    String languageCode = 'ru',
  }) {
    final cleanedText = cleanJsonResponse(responseText);
    final data = jsonDecode(cleanedText) as Map<String, dynamic>;

    RecoveryPlan? recoveryPlan;
    if (data['recovery_plan'] != null) {
      try {
        recoveryPlan = RecoveryPlan.fromMap(
          data['recovery_plan'] as Map<String, dynamic>,
        );
      } catch (e) {
        debugPrint('Error parsing recovery plan: $e');
      }
    }
    recoveryPlan ??= RecoveryPlan.defaultPlan(
      workoutType: workoutType,
      durationMinutes: durationMinutes,
      painReports: painReports,
    );

    return PostWorkoutFeedback(
      title:
          data['title'] ??
          _localizedText(
            languageCode: languageCode,
            ru: '✅ Тренировка завершена',
            kk: '✅ Жаттығу аяқталды',
            en: '✅ Workout completed',
          ),
      summary:
          data['summary'] ??
          _localizedText(
            languageCode: languageCode,
            ru: 'Вы отлично поработали!',
            kk: 'Сіз керемет жұмыс жасадыңыз!',
            en: 'Great work today!',
          ),
      tips: (data['tips'] as List<dynamic>?)?.cast<String>() ?? [],
      nextWorkoutSuggestion: data['next_workout_suggestion'] ?? '',
      encouragement:
          data['encouragement'] ??
          _localizedText(
            languageCode: languageCode,
            ru: 'Продолжайте в том же духе!',
            kk: 'Осы қарқынды жалғастырыңыз!',
            en: 'Keep up the great momentum!',
          ),
      recoveryPlan: recoveryPlan,
    );
  }

  @visibleForTesting
  String inferIntensity(Map<String, dynamic> data) {
    final duration = data['estimated_duration']?.toInt() ?? 30;
    if (duration <= 15) return WorkoutIntensity.light;
    if (duration >= 45) return WorkoutIntensity.high;
    return WorkoutIntensity.moderate;
  }

  // ---------------------------------------------------------------------------
  // Default fallbacks
  // ---------------------------------------------------------------------------

  @visibleForTesting
  String getDefaultRecommendation(
    DailyCheckIn checkIn, {
    String languageCode = 'ru',
  }) {
    if (checkIn.painLevel >= 7) {
      return _localizedText(
        languageCode: languageCode,
        ru: 'Сегодня рекомендуется отдых. Прислушайся к своему телу.',
        kk: 'Бүгін демалған дұрыс. Денеңіздің белгісіне құлақ асыңыз.',
        en: 'Rest is recommended today. Listen to your body.',
      );
    }
    if (checkIn.painLevel >= 4 || checkIn.energyLevel <= 2) {
      return _localizedText(
        languageCode: languageCode,
        ru: 'Рекомендуется легкая тренировка с акцентом на растяжку.',
        kk: 'Созылуға басымдық берілген жеңіл жаттығу ұсынылады.',
        en: 'A light workout with a focus on stretching is recommended.',
      );
    }
    if (checkIn.energyLevel >= 4 && checkIn.painLevel <= 2) {
      return _localizedText(
        languageCode: languageCode,
        ru: 'Отличное состояние! Можно выполнить полноценную тренировку.',
        kk: 'Күйіңіз тамаша! Толыққанды жаттығу жасауға болады.',
        en: 'Great condition! You can do a full workout today.',
      );
    }
    return _localizedText(
      languageCode: languageCode,
      ru: 'Рекомендуется умеренная тренировка под твои возможности.',
      kk: 'Мүмкіндігіңізге сай орташа қарқындағы жаттығу ұсынылады.',
      en: 'A moderate workout suited to your current condition is recommended.',
    );
  }

  @visibleForTesting
  PostWorkoutFeedback getDefaultPostWorkoutFeedback({
    required int durationMinutes,
    required int exercisesCompleted,
    required int painReports,
    String languageCode = 'ru',
  }) {
    String title;
    String summary;
    List<String> tips = [];
    String encouragement;

    if (painReports > 2) {
      title = _localizedText(
        languageCode: languageCode,
        ru: '⚠️ Тренировка с осторожностью',
        kk: '⚠️ Сақтықпен орындалған жаттығу',
        en: '⚠️ Cautionary workout',
      );
      summary = _localizedText(
        languageCode: languageCode,
        ru: 'Вы завершили тренировку, но было несколько жалоб на боль.',
        kk: 'Жаттығуды аяқтадыңыз, бірақ ауырсыну туралы бірнеше белгі болды.',
        en: 'You completed the workout, but there were multiple pain reports.',
      );
      tips = [
        _localizedText(
          languageCode: languageCode,
          ru: 'Убедитесь, что выполняете упражнения технически правильно',
          kk: 'Жаттығуларды дұрыс техникамен орындап жатқаныңызды тексеріңіз',
          en: 'Make sure each exercise is performed with proper technique',
        ),
        _localizedText(
          languageCode: languageCode,
          ru: 'Рассмотрите более легкие варианты упражнений',
          kk: 'Жаттығудың жеңілірек нұсқаларын қарастырыңыз',
          en: 'Consider easier exercise variations',
        ),
      ];
      encouragement = _localizedText(
        languageCode: languageCode,
        ru: 'Прислушивайтесь к своему телу — это важно!',
        kk: 'Денеңіздің белгісін тыңдау өте маңызды!',
        en: 'Listening to your body is essential!',
      );
    } else if (durationMinutes < 15) {
      title = _localizedText(
        languageCode: languageCode,
        ru: '👍 Быстрая тренировка',
        kk: '👍 Қысқа жаттығу',
        en: '👍 Quick workout',
      );
      summary = _localizedText(
        languageCode: languageCode,
        ru: 'Даже короткая тренировка лучше, чем никакой.',
        kk: 'Қысқа жаттығудың өзі мүлдем жасамағаннан жақсы.',
        en: 'Even a short workout is better than none.',
      );
      tips = [
        _localizedText(
          languageCode: languageCode,
          ru: 'Попробуйте увеличить время тренировки в следующий раз',
          kk: 'Келесі жолы жаттығу уақытын сәл ұзартып көріңіз',
          en: 'Try extending your workout duration next time',
        ),
      ];
      encouragement = _localizedText(
        languageCode: languageCode,
        ru: 'Главное — регулярность!',
        kk: 'Ең бастысы — тұрақтылық!',
        en: 'Consistency is what matters most!',
      );
    } else {
      title = _localizedText(
        languageCode: languageCode,
        ru: '🎉 Отличная работа!',
        kk: '🎉 Тамаша жұмыс!',
        en: '🎉 Great job!',
      );
      summary = _localizedText(
        languageCode: languageCode,
        ru: 'Вы выполнили $exercisesCompleted упражнений за $durationMinutes минут.',
        kk: 'Сіз $durationMinutes минутта $exercisesCompleted жаттығу орындадыңыз.',
        en: 'You completed $exercisesCompleted exercises in $durationMinutes minutes.',
      );
      tips = [
        _localizedText(
          languageCode: languageCode,
          ru: 'Не забывайте о восстановлении',
          kk: 'Қалпына келуге уақыт бөлуді ұмытпаңыз',
          en: 'Don’t forget recovery',
        ),
        _localizedText(
          languageCode: languageCode,
          ru: 'Пейте достаточно воды',
          kk: 'Суды жеткілікті мөлшерде ішіңіз',
          en: 'Stay well hydrated',
        ),
      ];
      encouragement = _localizedText(
        languageCode: languageCode,
        ru: 'Вы молодец! Так держать!',
        kk: 'Жарайсыз! Осы қарқынды сақтаңыз!',
        en: 'You’re doing great — keep it up!',
      );
    }

    return PostWorkoutFeedback(
      title: title,
      summary: summary,
      tips: tips,
      nextWorkoutSuggestion: _localizedText(
        languageCode: languageCode,
        ru: 'Отдохните и продолжите завтра',
        kk: 'Демалып, ертең жалғастырыңыз',
        en: 'Rest now and continue tomorrow',
      ),
      encouragement: encouragement,
      recoveryPlan: RecoveryPlan.defaultPlan(
        workoutType: 'general',
        durationMinutes: durationMinutes,
        painReports: painReports,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pain mapping helpers
  // ---------------------------------------------------------------------------

  String _painLocationToContraindication(String painLocation) {
    final mapping = <String, String>{
      'Спина (поясница)': Contraindications.lumbarHernia,
      'Спина (верх)': Contraindications.thoracicHernia,
      'Шея': Contraindications.cervicalHernia,
      'Колени': Contraindications.kneeInjury,
      'Плечи': Contraindications.shoulderInjury,
      'Запястья': Contraindications.wristInjury,
      'Голеностоп': Contraindications.ankleInjury,
      'Таз/бедра': Contraindications.hipInjury,
    };
    return mapping[painLocation] ?? '';
  }

  List<String> _getExercisesToAvoid(String painArea) {
    final mapping = <String, List<String>>{
      'Спина (поясница)': ['Скручивания', 'Наклоны', 'Супермен'],
      'Спина (верх)': ['Отжимания', 'Планка'],
      'Шея': ['Скручивания', 'Планка на руках'],
      'Колени': ['Приседания', 'Выпады', 'Прыжки'],
      'Плечи': ['Отжимания', 'Планка', 'Круги руками'],
      'Запястья': ['Отжимания', 'Планка', 'Упоры'],
      'Голеностоп': ['Прыжки', 'Бег на месте', 'Подъём на носки'],
      'Таз/бедра': ['Выпады', 'Мостик', 'Поза голубя'],
    };
    return mapping[painArea] ?? [];
  }
}
