import '../entities/user_entity.dart';

/// Contrato del repositorio de autenticación.
///
/// Define las operaciones disponibles en la capa de dominio.
/// La implementación concreta vive en la capa de datos.
abstract class AuthRepository {
  /// Stream que emite el usuario actual o null cuando cierra sesión.
  /// Se actualiza automáticamente con los cambios de Firebase Auth.
  Stream<UserEntity?> get authStateChanges;

  /// Inicia sesión con correo y contraseña.
  ///
  /// Lanza [AuthException] si las credenciales son incorrectas.
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Crea una cuenta nueva con correo, contraseña y nombre.
  ///
  /// Crea automáticamente el documento en Firestore (users/{uid})
  /// con rol 'customer' e inicializa el programa de lealtad (loyalty/{uid}).
  /// Lanza [AuthException] si el correo ya está en uso.
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
    required String phone,
  });

  /// Inicia sesión con una cuenta de Google.
  ///
  /// Si es un usuario nuevo, crea los documentos de Firestore.
  /// Lanza [AuthException] si el usuario cancela o hay un error.
  Future<UserEntity> loginWithGoogle();

  /// Vincula Google a una cuenta que ya tiene correo/contraseña.
  Future<UserEntity> linkGoogleWithEmailPassword({
    required String email,
    required String password,
  });

  /// Agrega correo/contraseña a la sesión actual (p. ej. entró solo con Google).
  Future<void> linkEmailPasswordToCurrentUser({
    required String email,
    required String password,
  });

  /// Actualiza los datos del perfil del usuario en Firestore.
  ///
  /// Solo los campos provistos son actualizados.
  Future<UserEntity> updateProfile({
    required String uid,
    String? displayName,
    String? phone,
    String? address,
  });

  /// Cierra la sesión actual (Firebase + Google).
  Future<void> logout();

  /// Envía un correo de restablecimiento de contraseña.
  ///
  /// Lanza [AuthException] si el correo no existe en Firebase.
  Future<void> sendPasswordReset({required String email});

  /// Obtiene los datos completos del usuario actual desde Firestore.
  ///
  /// Retorna null si no hay usuario autenticado.
  Future<UserEntity?> getCurrentUser();
}
