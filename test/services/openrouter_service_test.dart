import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

import 'package:ai_health_coach/data/services/openrouter_service.dart';

// Mock HTTP Client
class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('OpenRouterService', () {
    group('model constants', () {
      test('has correct free model identifiers', () {
        expect(OpenRouterService.modelGemma3, 'google/gemma-3-27b-it:free');
        expect(OpenRouterService.modelDeepSeekR1, 'deepseek/deepseek-r1:free');
        expect(OpenRouterService.modelLlama33, 'meta-llama/llama-3.3-70b-instruct:free');
        expect(OpenRouterService.modelQwen3, 'qwen/qwen3-30b-a3b:free');
        expect(OpenRouterService.modelFreeRouter, 'openrouter/auto');
      });

      test('fallbackModels contains all models in correct order', () {
        expect(OpenRouterService.fallbackModels, [
          OpenRouterService.modelGemma3,
          OpenRouterService.modelDeepSeekR1,
          OpenRouterService.modelLlama33,
          OpenRouterService.modelQwen3,
          OpenRouterService.modelFreeRouter,
        ]);
      });

      test('fallbackModels has Gemma3 as first choice (best for Russian)', () {
        expect(OpenRouterService.fallbackModels.first, OpenRouterService.modelGemma3);
      });
    });

    group('isConfigured', () {
      test('returns false when API key is not set', () {
        // Note: This test relies on dotenv not being initialized in test environment
        final service = OpenRouterService();
        // In test environment without dotenv, API key will be null
        expect(service.isConfigured, isFalse);
      });
    });

    group('generateCompletionWithFallback', () {
      test('throws exception when not configured', () async {
        final service = OpenRouterService();
        
        expect(
          () => service.generateCompletionWithFallback(prompt: 'test'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('OpenRouter API не настроен'),
          )),
        );
      });
    });

    group('generateCompletion', () {
      test('throws exception when not configured', () async {
        final service = OpenRouterService();
        
        expect(
          () => service.generateCompletion(prompt: 'test'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('OpenRouter API не настроен'),
          )),
        );
      });
    });
  });
}
