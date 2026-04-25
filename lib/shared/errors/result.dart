import 'app_error.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Failure<T>(:final error) => onFailure(error),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppError error;
}

Future<Result<T>> guardResult<T>(
  Future<T> Function() action, {
  AppErrorCode code = AppErrorCode.unknown,
  String? message,
  bool isRecoverable = true,
}) async {
  try {
    return Success<T>(await action());
  } catch (error, stackTrace) {
    return Failure<T>(
      AppError.fromException(
        error,
        stackTrace,
        code: code,
        message: message,
        isRecoverable: isRecoverable,
      ),
    );
  }
}
