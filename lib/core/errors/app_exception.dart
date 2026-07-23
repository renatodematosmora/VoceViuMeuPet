/// Classe base para todas as exceções da aplicação com suporte a logging
class AppException implements Exception {
  final String message;           // Mensagem genérica (mostrar ao usuário)
  final String? internalMessage;  // Detalhes técnicos (logar apenas)
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.internalMessage,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Exceção específica para erros do Supabase
class SupabaseException extends AppException {
  SupabaseException({
    required String message,
    String? internalMessage,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    internalMessage: internalMessage,
    stackTrace: stackTrace,
  );
}

/// Exceção específica para erros de rede
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? internalMessage,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    internalMessage: internalMessage,
    stackTrace: stackTrace,
  );
}

/// Exceção específica para erros de validação
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException({
    required String message,
    String? internalMessage,
    StackTrace? stackTrace,
    this.fieldErrors,
  }) : super(
    message: message,
    internalMessage: internalMessage,
    stackTrace: stackTrace,
  );
}

/// Exceção específica para erros de armazenamento
class AppStorageException extends AppException {
  AppStorageException({
    required String message,
    String? internalMessage,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    internalMessage: internalMessage,
    stackTrace: stackTrace,
  );
}

/// Exceção para operações não autorizadas
class UnauthorizedException extends AppException {
  UnauthorizedException({
    required String message,
    String? internalMessage,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    internalMessage: internalMessage,
    stackTrace: stackTrace,
  );
}
