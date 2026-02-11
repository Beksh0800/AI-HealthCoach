import 'app_exceptions.dart';

/// A simple Result type for returning either success or failure.
///
/// Usage:
/// ```dart
/// Result<UserProfile> result = await getUserProfile();
/// switch (result) {
///   case Success(:final data):
///     print('Got profile: ${data.name}');
///   case Failure(:final error):
///     print('Error: ${error.message}');
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Create a successful result
  factory Result.success(T data) = Success<T>;

  /// Create a failure result
  factory Result.failure(AppException error) = Failure<T>;

  /// Whether this result is a success
  bool get isSuccess => this is Success<T>;

  /// Whether this result is a failure
  bool get isFailure => this is Failure<T>;

  /// Get the data if successful, or null if failed
  T? get dataOrNull {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    return null;
  }

  /// Get the error if failed, or null if successful
  AppException? get errorOrNull {
    if (this is Failure<T>) {
      return (this as Failure<T>).error;
    }
    return null;
  }

  /// Transform the data if successful
  Result<R> map<R>(R Function(T data) transform) {
    if (this is Success<T>) {
      return Result.success(transform((this as Success<T>).data));
    }
    return Result.failure((this as Failure<T>).error);
  }

  /// Execute a function based on success/failure
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    }
    return failure((this as Failure<T>).error);
  }
}

/// Successful result containing data
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Failed result containing an error
class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);
}
