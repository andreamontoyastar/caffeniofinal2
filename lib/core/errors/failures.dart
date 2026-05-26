import 'package:equatable/equatable.dart';

/// Jerarquía de errores del dominio (capa de negocio).
///
/// Los fallos son el resultado de operaciones fallidas, expresados de forma
/// que la UI puede interpretar sin conocer detalles de implementación.
sealed class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '${runtimeType.toString()}(message: $message, code: $code)';
}

/// Error de autenticación (credenciales, sesión, permisos).
final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Error de red o falta de conectividad.
final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Error del servidor o de la API remota.
final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Error de caché o almacenamiento local.
final class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Error de validación de datos.
final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Error inesperado no clasificado.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.code});
}
