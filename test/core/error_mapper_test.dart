import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_health_coach/core/errors/app_exceptions.dart';
import 'package:ai_health_coach/core/errors/error_mapper.dart';

void main() {
  group('ErrorMapper', () {
    test('maps timeout to NetworkException with TIMEOUT code', () {
      final mapped = ErrorMapper.toAppException(
        TimeoutException('Request timed out'),
      );
      expect(mapped, isA<NetworkException>());
      expect(mapped.code, 'TIMEOUT');
    });

    test('maps Firebase auth network error to NetworkException', () {
      final mapped = ErrorMapper.toAppException(
        FirebaseAuthException(code: 'network-request-failed'),
      );
      expect(mapped, isA<NetworkException>());
      expect(mapped.code, 'NO_CONNECTION');
    });

    test('maps API unavailable text to AIServiceException', () {
      final mapped = ErrorMapper.toAppException(
        Exception('OpenRouter API error: 503 Service Unavailable'),
      );
      expect(mapped, isA<AIServiceException>());
      expect(mapped.code, 'AI_UNAVAILABLE');
    });

    test('maps not configured text to AIServiceException', () {
      final mapped = ErrorMapper.toAppException(
        Exception('AI API не настроен. Добавьте GEMINI_API_KEY'),
      );
      expect(mapped, isA<AIServiceException>());
      expect(mapped.code, 'NOT_CONFIGURED');
    });

    test('maps unknown errors to generic AppException with fallback', () {
      final mapped = ErrorMapper.toAppException(
        Exception('unexpected'),
        fallbackMessage: 'fallback',
      );
      expect(mapped, isA<AppException>());
      expect(mapped.message, 'fallback');
    });
  });
}
