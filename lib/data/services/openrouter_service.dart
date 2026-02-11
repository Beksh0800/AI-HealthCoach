import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for making AI requests via OpenRouter API
/// OpenRouter provides access to many free and paid models
class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  // Free models on OpenRouter (updated 2025)
  // These are reliable free models that support Russian language
  static const String modelGemma3 = 'google/gemma-3-27b-it:free';
  static const String modelDeepSeekR1 = 'deepseek/deepseek-r1:free';
  static const String modelLlama33 = 'meta-llama/llama-3.3-70b-instruct:free';
  static const String modelQwen3 = 'qwen/qwen3-30b-a3b:free';
  static const String modelFreeRouter = 'openrouter/auto'; // Auto-router for free models
  
  // Fallback order for multi-model approach
  static const List<String> fallbackModels = [
    modelFreeRouter,    // Auto-router for free models (Most reliable according to logs)
    modelGemma3,        // Best for multilingual (Russian)
    modelDeepSeekR1,    // Good reasoning
    modelLlama33,       // Reliable fallback
    modelQwen3,         // Alternative
  ];

  String? _apiKey;
  
  OpenRouterService() {
    _initApiKey();
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
    
    for (final model in fallbackModels) {
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
    String model = modelGemma3,
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
      
      // Add response format for JSON mode (only some models support this)
      if (jsonMode && !model.contains('deepseek')) {
        body['response_format'] = {'type': 'json_object'};
      }
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw Exception('OpenRouter request timed out'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          return message?['content'] as String?;
        }
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('OpenRouter API error ($model): $errorMessage');
      }
    } catch (e) {
      debugPrint('OpenRouterService error: $e');
      rethrow;
    }
  }
  
  /// Generate text completion (non-JSON)
  Future<String?> generateText({
    required String prompt,
    String model = modelFreeRouter,
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
    String model = modelFreeRouter,
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
