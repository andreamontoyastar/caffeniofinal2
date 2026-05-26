/// Excepción base de la aplicación.
///
/// Las excepciones se lanzan desde la capa de datos y se capturan
/// en los repositorios o providers para convertirlas en [Failure] o mensajes de UI.
class AppException implements Exception {
  const AppException({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException[$code]: $message';
}

/// Error de autenticación — Firebase Auth, Google Sign-In.
class AuthException extends AppException {
  const AuthException({required super.message, super.code});

  @override
  String toString() => 'AuthException[$code]: $message';
}

/// Error de red — sin conexión, timeout.
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});

  @override
  String toString() => 'NetworkException[$code]: $message';
}

/// Error del servidor — Firestore, Storage, etc.
class ServerException extends AppException {
  const ServerException({required super.message, super.code});

  @override
  String toString() => 'ServerException[$code]: $message';
}

/// Error de caché — Hive, SharedPreferences.
class CacheException extends AppException {
  const CacheException({required super.message, super.code});

  @override
  String toString() => 'CacheException[$code]: $message';
}
