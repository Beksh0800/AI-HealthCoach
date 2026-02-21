import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'app_exceptions.dart';

class ErrorMapper {
  static AppException toAppException(Object error, {String? fallbackMessage}) {
    if (error is AppException) return error;

    if (error is TimeoutException) {
      return NetworkException.timeout();
    }
    if (error is FirebaseAuthException) {
      return _mapFirebaseAuth(error);
    }
    if (error is FirebaseException) {
      return _mapFirebase(error);
    }

    final raw = error.toString();
    final lower = raw.toLowerCase();

    if (_containsAny(lower, const [
      'socketexception',
      'failed host lookup',
      'name or service not known',
      'network is unreachable',
      'connection refused',
      'connection reset',
      'no address associated',
      'network-request-failed',
      'errno = 101',
      'errno = 111',
      'errno = 7',
    ])) {
      return NetworkException.noConnection();
    }

    if (_containsAny(lower, const [
      'timeout',
      'timed out',
      'deadline-exceeded',
      'request timed out',
    ])) {
      return NetworkException.timeout();
    }

    if (_containsAny(lower, const [
      'quota',
      'resource exhausted',
      'rate limit',
      'too many requests',
      '429',
    ])) {
      return AIServiceException.quotaExceeded();
    }

    if (_containsAny(lower, const [
      'not configured',
      'api не настроен',
      'missing api key',
      'invalid api key',
      'openrouter_api_key',
      'gemini_api_key',
    ])) {
      return AIServiceException.notConfigured();
    }

    if (_containsAny(lower, const [
      'service unavailable',
      'temporarily unavailable',
      'bad gateway',
      'gateway timeout',
      '503',
      '502',
      'overloaded',
      'model is at capacity',
      'upstream error',
    ])) {
      return AIServiceException(
        'AI-сервис временно недоступен. Попробуйте позже.',
        code: 'AI_UNAVAILABLE',
        originalError: error,
      );
    }

    if (_containsAny(lower, const [
      'parse',
      'invalid json',
      'unexpected character',
      'format exception',
      'ошибка парсинга',
    ])) {
      return AIServiceException.parseError('Некорректный ответ от AI');
    }

    if (_containsAny(lower, const [
      'empty response',
      'returned empty response',
      'пустой ответ',
    ])) {
      return AIServiceException.emptyResponse();
    }

    return AppException(
      fallbackMessage ?? 'Произошла ошибка. Попробуйте еще раз.',
      originalError: error,
    );
  }

  static String toMessage(Object error, {String? fallbackMessage}) {
    return toAppException(error, fallbackMessage: fallbackMessage).message;
  }

  static bool isRetryable(Object error) {
    final mapped = toAppException(error);
    if (mapped is NetworkException) return true;
    if (mapped is AIServiceException) {
      return mapped.code != 'NOT_CONFIGURED';
    }
    final code = mapped.code?.toUpperCase();
    if (code == 'PERMISSION_DENIED') return false;
    return true;
  }

  static AppException _mapFirebaseAuth(FirebaseAuthException error) {
    switch (error.code) {
      case 'network-request-failed':
        return NetworkException.noConnection();
      case 'too-many-requests':
        return AuthException(
          'Слишком много попыток. Попробуйте позже.',
          code: 'TOO_MANY_REQUESTS',
          originalError: error,
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AuthException.invalidCredentials();
      case 'email-already-in-use':
        return AuthException.emailInUse();
      case 'weak-password':
        return AuthException.weakPassword();
      case 'invalid-email':
        return AuthException(
          'Неверный формат email',
          code: 'INVALID_EMAIL',
          originalError: error,
        );
      case 'user-disabled':
        return AuthException(
          'Аккаунт заблокирован',
          code: 'USER_DISABLED',
          originalError: error,
        );
      default:
        return AuthException(
          'Ошибка авторизации. Попробуйте еще раз.',
          code: error.code,
          originalError: error,
        );
    }
  }

  static AppException _mapFirebase(FirebaseException error) {
    switch (error.code) {
      case 'unavailable':
        return NetworkException.noConnection();
      case 'deadline-exceeded':
        return NetworkException.timeout();
      case 'permission-denied':
        return DataException(
          'Недостаточно прав для выполнения операции',
          code: 'PERMISSION_DENIED',
          originalError: error,
        );
      case 'resource-exhausted':
        return DataException(
          'Лимит запросов исчерпан. Попробуйте позже.',
          code: 'RESOURCE_EXHAUSTED',
          originalError: error,
        );
      case 'not-found':
        return DataException.notFound('Данные');
      default:
        return DataException(
          'Ошибка доступа к данным. Попробуйте позже.',
          code: error.code,
          originalError: error,
        );
    }
  }

  static bool _containsAny(String text, List<String> patterns) {
    for (final pattern in patterns) {
      if (text.contains(pattern)) return true;
    }
    return false;
  }
}
