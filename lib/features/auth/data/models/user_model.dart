import 'package:caffenio/core/constants/app_constants.dart';
import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/features/auth/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Modelo de usuario de la capa de datos.
///
/// Extiende [UserEntity] añadiendo capacidades de serialización
/// hacia/desde Firestore y Firebase Auth.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.role,
    required super.createdAt,
    required super.emailVerified,
    super.displayName,
    super.photoURL,
    super.phone,
    super.sucursalId,
    super.address,
  });

  // ── Factories ─────────────────────────────────────────────────────────────

  /// Construye un [UserModel] desde un mapa JSON de Firestore.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    final rawDate = json[FirebaseConstants.fieldCreatedAt];
    if (rawDate is Timestamp) {
      createdAt = rawDate.toDate();
    } else if (rawDate is String) {
      createdAt = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return UserModel(
      uid: _readString(json, FirebaseConstants.fieldUid) ?? '',
      email: _readString(json, FirebaseConstants.fieldUserEmail) ?? '',
      displayName: _readString(json, FirebaseConstants.fieldUserDisplayName),
      photoURL: _readString(json, FirebaseConstants.fieldUserPhotoUrl),
      phone: _readString(json, FirebaseConstants.fieldUserPhone),
      role: _readString(json, FirebaseConstants.fieldUserRole) ??
          AppConstants.roleCustomer,
      sucursalId: _readString(json, FirebaseConstants.fieldUserBranchId),
      address: _readString(json, FirebaseConstants.fieldUserAddress),
      createdAt: createdAt,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Construye desde un [DocumentSnapshot] de Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel.fromJson({
      ...data,
      FirebaseConstants.fieldUid: doc.id,
    });
  }

  /// Construye desde un objeto [User] de Firebase Auth.
  /// Usado cuando aún no existe el documento en Firestore.
  factory UserModel.fromFirebaseUser(
    User firebaseUser, {
    String role = AppConstants.roleCustomer,
    String? sucursalId,
  }) {
    final fallbackDisplayName =
        firebaseUser.email?.split('@').first ?? 'Cliente Caffenio';
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName?.trim().isNotEmpty == true
          ? firebaseUser.displayName
          : fallbackDisplayName,
      photoURL: firebaseUser.photoURL ?? AppConstants.placeholderAvatarUrl,
      phone: firebaseUser.phoneNumber ?? '',
      role: role,
      sucursalId: sucursalId,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      emailVerified: firebaseUser.emailVerified,
    );
  }

  // ── Serialización ─────────────────────────────────────────────────────────

  /// Convierte el modelo a un mapa para escrituras de Firestore.
  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.fieldUid: uid,
      FirebaseConstants.fieldUserEmail: email,
      FirebaseConstants.fieldUserDisplayName: displayName ?? '',
      FirebaseConstants.fieldUserPhotoUrl:
          photoURL ?? AppConstants.placeholderAvatarUrl,
      FirebaseConstants.fieldUserPhone: phone ?? '',
      FirebaseConstants.fieldUserRole: role,
      FirebaseConstants.fieldUserBranchId: sucursalId,
      FirebaseConstants.fieldUserAddress: address,
      FirebaseConstants.fieldCreatedAt: Timestamp.fromDate(createdAt),
      FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
      FirebaseConstants.fieldIsActive: true,
      FirebaseConstants.fieldIsDeleted: false,
      'emailVerified': emailVerified,
    };
  }

  /// Mapa para crear un documento nuevo — usa serverTimestamp para createdAt.
  Map<String, dynamic> toNewUserJson() {
    return {
      ...toJson(),
      FirebaseConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
      FirebaseConstants.fieldUserFcmToken: null,
    };
  }

  // ── CopyWith ──────────────────────────────────────────────────────────────

  @override
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phone,
    String? role,
    String? sucursalId,
    String? address,
    DateTime? createdAt,
    bool? emailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      sucursalId: sucursalId ?? this.sucursalId,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}
