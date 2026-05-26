import 'package:caffenio/core/constants/app_constants.dart';
import 'package:equatable/equatable.dart';

/// Entidad de usuario del dominio.
///
/// No depende de ningún paquete externo de Firebase.
/// Es la representación de negocio del usuario en toda la app.
class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.emailVerified,
    this.displayName,
    this.photoURL,
    this.phone,
    this.sucursalId,
  });

  /// ID único de Firebase Auth.
  final String uid;

  /// Correo electrónico verificado o no.
  final String email;

  /// Nombre para mostrar (puede ser null si no se ha configurado).
  final String? displayName;

  /// URL de la foto de perfil.
  final String? photoURL;

  /// Rol del usuario en la aplicación.
  /// Valores posibles: 'customer', 'barista', 'admin'.
  final String role;

  /// Número de teléfono del usuario.
  final String? phone;

  /// ID de la sucursal asignada (solo para baristas).
  final String? sucursalId;

  /// Fecha de creación de la cuenta.
  final DateTime createdAt;

  /// Si el correo ha sido verificado.
  final bool emailVerified;

  // ── Helpers de rol ────────────────────────────────────────────────────────

  bool get isAdmin => role == AppConstants.roleAdmin;
  bool get isBarista => role == AppConstants.roleBarista;
  bool get isCustomer => role == AppConstants.roleCustomer;

  /// Nombre para mostrar en la UI.
  /// Si no hay displayName, usa la parte local del correo.
  String get displayNameOrEmail => (displayName?.isNotEmpty ?? false)
      ? displayName!
      : email.split('@').first;

  /// Iniciales para el avatar.
  String get initials {
    final name = displayNameOrEmail;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ── CopyWith ──────────────────────────────────────────────────────────────

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phone,
    String? role,
    String? sucursalId,
    DateTime? createdAt,
    bool? emailVerified,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      sucursalId: sucursalId ?? this.sucursalId,
      createdAt: createdAt ?? this.createdAt,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoURL,
        phone,
        role,
        sucursalId,
        createdAt,
        emailVerified,
      ];

  @override
  String toString() =>
      'UserEntity(uid: $uid, email: $email, role: $role, verified: $emailVerified)';
}
