import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for making AI requests via OpenRouter API
/// OpenRouter provides access to many free and paid models
class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
 
  // Stable defaults for paid OpenRouter accounts.
  static const String modelAutoRouter = 'openrouter/auto';
  static const String modelGpt4oMini = 'openai/gpt-4o-mini';
  static const String modelGeminiFlash = 'google/gemini-2.0-flash-001';
  static const String modelClaudeHaiku = 'anthropic/claude-3.5-haiku';
  static const String modelLlama33 = 'meta-llama/llama-3.3-70b-instruct';

  // Backward-compatible aliases used by tests/older code.
  static const String modelGemma3 = modelGeminiFlash;
  static const String modelDeepSeekR1 = modelLlama33;
  static const String modelQwen3 = modelGpt4oMini;
  static const String modelFreeRouter = modelAutoRouter;

  static const List<String> fallbackModels = _defaultFallbackModels;

  static const List<String> _defaultFallbackModels = [
    modelGpt4oMini,
    modelGeminiFlash,
    modelClaudeHaiku,
    modelLlama33,
    modelAutoRouter,
  ];

  String? _apiKey;
  late final List<String> _fallbackModels;
  
  OpenRouterService() {
    _initApiKey();
    _fallbackModels = _resolveFallbackModels();
  }
  
  void _initApiKey() {
    try {
      if (dotenv.isInitialized) {
        _apiKey = dotenv.env['OPENROUTER_API_KEY'];
      }
    } catch (e) {
      debugPrint('OpenRouterService: Error accessing API key: $e');
    }
  }
  
  /// Check if OpenRouter is configured
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  List<String> _resolveFallbackModels() {
    try {
      final raw = dotenv.env['OPENROUTER_MODELS'];
      if (raw != null && raw.trim().isNotEmpty) {
        final fromEnv = raw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (fromEnv.isNotEmpty) {
          debugPrint('OpenRouterService: using OPENROUTER_MODELS override');
          return fromEnv;
        }
      }
    } catch (_) {
      // Ignore dotenv access issues and use defaults.
    }
    return _defaultFallbackModels;
  }
  
  /// Generate a completion with automatic fallback across multiple models
  /// Tries each model in [fallbackModels] until one succeeds
  Future<String?> generateCompletionWithFallback({
    required String prompt,
    String? systemPrompt,
    bool jsonMode = false,
    int maxTokens = 4096,
    double temperature = 0.7,
  }) async {
    if (!isConfigured) {
      throw Exception('OpenRouter API не настроен. Добавьте OPENROUTER_API_KEY в .env');
    }
    
    Exception? lastError;
    
    for (final model in _fallbackModels) {
      try {
        debugPrint('OpenRouterService: Trying model $model');
        final result = await generateCompletion(
          prompt: prompt,
          systemPrompt: systemPrompt,
          model: model,
          jsonMode: jsonMode,
          maxTokens: maxTokens,
          temperature: temperature,
        );
        
        if (result != null && result.isNotEmpty) {
          debugPrint('OpenRouterService: Success with model $model');
          return result;
        }
      } catch (e) {
        debugPrint('OpenRouterService: Model $model failed: $e');
        lastError = e is Exception ? e : Exception(e.toString());
        // Continue to next model
      }
    }
    
    // All models failed
    throw lastError ?? Exception('All OpenRouter models failed');
  }
  
  /// Generate a completion using OpenRouter API
  /// [prompt] - The text prompt to send
  /// [systemPrompt] - Optional system message defining AI persona
  /// [model] - The model to use (defaults to Gemma 3)
  /// [jsonMode] - If true, requests JSON response format
  /// [maxTokens] - Maximum tokens in response
  /// [temperature] - Creativity level (0.0 - 1.0)
  Future<String?> generateCompletion({
    required String prompt,
    String? systemPrompt,
    String model = modelAutoRouter,
    bool jsonMode = false,
    int maxTokens = 4096,
    double temperature = 0.7,
  }) async {
    if (!isConfigured) {
      throw Exception('OpenRouter API не настроен. Добавьте OPENROUTER_API_KEY в .env');
    }

    try {
      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://ai-health-coach.app',
        'X-Title': 'AI Health Coach',
      };
      
      final messages = <Map<String, String>>[];
      
      // Add system prompt if provided
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messages.add({
          'role': 'system',
          'content': systemPrompt,
        });
      }
      
      messages.add({
        'role': 'user',
        'content': prompt,
      });
      
      final body = <String, dynamic>{
        'model': model,
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': temperature,
      };

      final shouldSendResponseFormat =
          jsonMode && _supportsResponseFormat(model);
      if (shouldSendResponseFormat) {
        body['response_format'] = {'type': 'json_object'};
      }

      var response = await _postCompletion(headers: headers, body: body);

      if (response.statusCode != 200 &&
          shouldSendResponseFormat &&
          _isResponseFormatUnsupported(response.body)) {
        debugPrint(
          'OpenRouterService: model $model does not support response_format, retrying without it',
        );
        body.remove('response_format');
        response = await _postCompletion(headers: headers, body: body);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          return message?['content'] as String?;
        }
        return null;
      }

      final errorData = jsonDecode(response.body);
      final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
      throw Exception('OpenRouter API error ($model): $errorMessage');
    } catch (e) {
      debugPrint('OpenRouterService error: $e');
      rethrow;
    }
  }

  bool _supportsResponseFormat(String model) {
    final normalized = model.toLowerCase();
    if (normalized.contains('deepseek')) return false;
    return true;
  }

  bool _isResponseFormatUnsupported(String responseBody) {
    final lowered = responseBody.toLowerCase();
    return lowered.contains('response_format') ||
        lowered.contains('json_object') ||
        lowered.contains('unsupported') ||
        lowered.contains('not support');
  }

  Future<http.Response> _postCompletion({
    required Map<String, String> headers,
    required Map<String, dynamic> body,
  }) {
    return http
        .post(
          Uri.parse(_baseUrl),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(
          const Duration(seconds: 45),
          onTimeout: () => throw Exception('OpenRouter request timed out'),
        );
  }
  
  /// Generate text completion (non-JSON)
  Future<String?> generateText({
    required String prompt,
    String model = modelAutoRouter,
    int maxTokens = 500,
    double temperature = 0.7,
  }) async {
    return generateCompletion(
      prompt: prompt,
      model: model,
      jsonMode: false,
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }
  
  /// Generate JSON completion
  Future<Map<String, dynamic>?> generateJson({
    required String prompt,
    String model = modelAutoRouter,
    int maxTokens = 4096,
    double temperature = 0.7,
  }) async {
    final response = await generateCompletion(
      prompt: prompt,
      model: model,
      jsonMode: true,
      maxTokens: maxTokens,
      temperature: temperature,
    );
    
    if (response == null) return null;
    
    // Clean and parse JSON
    String cleanedText = response.trim();
    if (cleanedText.startsWith('```json')) {
      cleanedText = cleanedText.substring(7);
    }
    if (cleanedText.startsWith('```')) {
      cleanedText = cleanedText.substring(3);
    }
    if (cleanedText.endsWith('```')) {
      cleanedText = cleanedText.substring(0, cleanedText.length - 3);
    }
    cleanedText = cleanedText.trim();
    
    return jsonDecode(cleanedText) as Map<String, dynamic>;
  }
}
