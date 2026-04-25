enum AppErrorCode {
  validation,
  startup,
  quranUnavailable,
  persistence,
  permissionDenied,
  platformUnavailable,
  sharing,
  unknown,
}

class AppError implements Exception {
  const AppError({
    required this.code,
    required this.message,
    this.cause,
    this.stackTrace,
    this.isRecoverable = true,
  });

  final AppErrorCode code;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  final bool isRecoverable;

  factory AppError.fromException(
    Object cause,
    StackTrace stackTrace, {
    AppErrorCode code = AppErrorCode.unknown,
    String? message,
    bool isRecoverable = true,
  }) {
    return AppError(
      code: code,
      message: message ?? cause.toString(),
      cause: cause,
      stackTrace: stackTrace,
      isRecoverable: isRecoverable,
    );
  }

  @override
  String toString() => 'AppError(${code.name}): $message';
}
