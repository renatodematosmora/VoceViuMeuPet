/// Erros de domínio da aplicação
sealed class AppError implements Exception {
  final String message;
  const AppError(this.message);

  @override
  String toString() => message;
}

final class AuthError extends AppError {
  const AuthError(super.message);
}

final class NetworkError extends AppError {
  const NetworkError(super.message);
}

final class NotFoundError extends AppError {
  const NotFoundError(super.message);
}

final class ValidationError extends AppError {
  final Map<String, String> fields;
  const ValidationError(super.message, {this.fields = const {}});
}

final class PermissionError extends AppError {
  const PermissionError(super.message);
}

final class StorageError extends AppError {
  const StorageError(super.message);
}

final class UnknownError extends AppError {
  final Object? originalError;
  const UnknownError(super.message, {this.originalError});
}
