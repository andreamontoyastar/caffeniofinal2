import 'package:firebase_auth/firebase_auth.dart';

import 'exceptions.dart';

/// Convierte [FirebaseAuthException] en [AuthException] con mensajes en español.
abstract final class AuthErrorMapper {
  /// Mapea un error de Firebase Auth a una excepción de dominio con mensaje legible.
  static AuthException fromFirebaseAuthException(FirebaseAuthException e) {
    return AuthException(
      message: _codeToMessage(e.code),
      code: e.code,
    );
  }

  static String _codeToMessage(String code) {
    return switch (code) {
      // ── Credenciales ───────────────────────────────────────────────────────
      'email-already-in-use' =>
        'Ya existe una cuenta con este correo. Inicia sesión o vincula el otro método.',
      'wrong-password' =>
        'La contraseña es incorrecta. Inténtalo de nuevo.',
      'user-not-found' =>
        'No hay cuenta con ese correo. Revisa el correo o regístrate.',
      'invalid-credential' =>
        'Correo o contraseña incorrectos.',
      'invalid-id-token' || 'credential-already-in-use' =>
        'No se pudo validar la cuenta de Google. Revisa la configuración de Firebase.',
      'invalid-email' =>
        'El formato del correo electrónico no es válido.',
      'weak-password' =>
        'La contraseña es muy débil. Usa al menos 8 caracteres con letras y números.',

      // ── Cuenta ────────────────────────────────────────────────────────────
      'user-disabled' =>
        'Esta cuenta ha sido deshabilitada. Contacta al soporte de Caffenio.',
      'requires-recent-login' =>
        'Esta operación requiere que vuelvas a iniciar sesión.',
      'account-exists-with-different-credential' =>
        'Ya existe una cuenta con ese correo usando otro método de inicio de sesión.',
      'operation-not-allowed' =>
        'Este método de inicio de sesión no está disponible.',

      // ── Red ───────────────────────────────────────────────────────────────
      'network-request-failed' =>
        'Sin conexión a internet. Revisa tu red e inténtalo de nuevo.',
      'too-many-requests' =>
        'Demasiados intentos fallidos. Espera unos minutos e inténtalo de nuevo.',

      // ── Google Sign-In ────────────────────────────────────────────────────
      'popup-closed-by-user' ||
      'cancelled-popup-request' =>
        'El inicio de sesión con Google fue cancelado.',

      // ── Recuperación de contraseña ────────────────────────────────────────
      'expired-action-code' =>
        'El enlace de recuperación ha expirado. Solicita uno nuevo.',
      'invalid-action-code' =>
        'El enlace no es válido. Puede haber sido usado anteriormente.',

      // ── Default ───────────────────────────────────────────────────────────
      _ => 'Ocurrió un error al autenticar. Inténtalo de nuevo.',
    };
  }
}
