/// Base exception for all app-level errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// Exception for network-related errors (no internet, timeout, etc.)
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});

  factory NetworkException.noConnection() =>
      NetworkException('Нет подключения к интернету', code: 'NO_CONNECTION');

  factory NetworkException.timeout() =>
      NetworkException('Превышено время ожидания', code: 'TIMEOUT');
}

/// Exception for AI service errors (quota, parse, configuration)
class AIServiceException extends AppException {
  AIServiceException(super.message, {super.code, super.originalError});

  factory AIServiceException.quotaExceeded() => AIServiceException(
        'Квота API исчерпана. Попробуйте позже.',
        code: 'QUOTA_EXCEEDED',
      );

  factory AIServiceException.parseError(String details) => AIServiceException(
        'Ошибка обработки ответа ИИ: $details',
        code: 'PARSE_ERROR',
      );

  factory AIServiceException.notConfigured() => AIServiceException(
        'ИИ-сервис не настроен. Проверьте API ключи в .env.',
        code: 'NOT_CONFIGURED',
      );

  factory AIServiceException.emptyResponse() => AIServiceException(
        'Пустой ответ от ИИ. Попробуйте снова.',
        code: 'EMPTY_RESPONSE',
      );
}

/// Exception for authentication errors
class AuthException extends AppException {
  AuthException(super.message, {super.code, super.originalError});

  factory AuthException.notAuthenticated() =>
      AuthException('Необходима авторизация', code: 'NOT_AUTHENTICATED');

  factory AuthException.invalidCredentials() =>
      AuthException('Неверный логин или пароль', code: 'INVALID_CREDENTIALS');

  factory AuthException.emailInUse() => AuthException(
        'Этот email уже зарегистрирован',
        code: 'EMAIL_IN_USE',
      );

  factory AuthException.weakPassword() => AuthException(
        'Пароль должен содержать минимум 6 символов',
        code: 'WEAK_PASSWORD',
      );
}

/// Exception for data/Firestore errors
class DataException extends AppException {
  DataException(super.message, {super.code, super.originalError});

  factory DataException.notFound(String entity) => DataException(
        '$entity не найден',
        code: 'NOT_FOUND',
      );

  factory DataException.saveFailed(String entity) => DataException(
        'Ошибка сохранения: $entity',
        code: 'SAVE_FAILED',
      );

  factory DataException.deleteFailed(String entity) => DataException(
        'Ошибка удаления: $entity',
        code: 'DELETE_FAILED',
      );
}
