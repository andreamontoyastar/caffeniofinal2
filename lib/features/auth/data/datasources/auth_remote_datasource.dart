import 'package:caffenio/core/constants/app_constants.dart';
import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/errors/auth_error_mapper.dart';
import 'package:caffenio/core/errors/exceptions.dart';
import 'package:caffenio/features/auth/data/models/user_model.dart';
import 'package:caffenio/features/notifications/data/notifications_remote_datasource.dart';
import 'package:caffenio/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ── Interfaz ──────────────────────────────────────────────────────────────────

abstract class AuthRemoteDataSource {
  /// Stream que emite el usuario actual o null.
  Stream<UserModel?> get authStateChanges;

  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String phone,
  );
  Future<UserModel> updateUserProfile({
    required String uid,
    String? displayName,
    String? phone,
  });
  Future<UserModel> signInWithGoogle();
  /// Vincula Google a una cuenta que ya tiene correo/contraseña.
  Future<UserModel> linkGoogleWithEmailPassword({
    required String email,
    required String password,
  });
  /// Agrega correo/contraseña a la sesión actual (p. ej. entró con Google).
  Future<void> linkEmailPasswordToCurrentUser({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getCurrentUserData();
}

// ── Implementación ────────────────────────────────────────────────────────────

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    GoogleSignIn? googleSignIn,
    NotificationsRemoteDataSource? notificationsDataSource,
  })  : _auth = firebaseAuth,
        _firestore = firestore,
        _notificationsDataSource = notificationsDataSource,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
              serverClientId: DefaultFirebaseOptions.googleWebClientId,
            );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final NotificationsRemoteDataSource? _notificationsDataSource;

  // ── authStateChanges ───────────────────────────────────────────────────────

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        return await _fetchUserFromFirestore(firebaseUser);
      } catch (_) {
        return UserModel.fromFirebaseUser(firebaseUser);
      }
    });
  }

  // ── Email / Password ──────────────────────────────────────────────────────

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final trimmedEmail = email.trim().toLowerCase();
    try {
      await _googleSignIn.signOut();

      final credential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      return await _resolveUserAfterSignIn(credential.user!);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('Email sign-in FirebaseAuth code: ${e.code}');
      }
      throw await _mapEmailSignInException(e, trimmedEmail);
    } on AuthException {
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Email sign-in error: $e\n$stackTrace');
      }
      throw const AuthException(
        message:
            'No se pudo completar el inicio de sesión. Intenta de nuevo o usa "Continuar con Google".',
      );
    }
  }

  @override
  Future<UserModel> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String phone,
  ) async {
    final trimmedEmail = email.trim().toLowerCase();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      final firebaseUser = credential.user!;

      await firebaseUser.updateDisplayName(displayName.trim());
      await firebaseUser.reload();

      final userModel = UserModel.fromFirebaseUser(
        _auth.currentUser ?? firebaseUser,
      ).copyWith(
        displayName: displayName.trim(),
        phone: phone.trim(),
      );

      try {
        await _createUserDocument(userModel);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('Register Firestore profile failed: $e\n$stackTrace');
        }
        await _auth.signOut();
        await _googleSignIn.signOut();
        throw const AuthException(
          message:
              'Tu cuenta se creó, pero falló guardar el perfil. '
              'Ve a "Iniciar sesión" con el mismo correo y contraseña.',
          code: 'register-profile-failed',
        );
      }

      await _safeInitializeLoyalty(firebaseUser.uid);
      await _sendWelcomeNotification(firebaseUser.uid);

      return userModel;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw await _mapRegisterEmailInUse(trimmedEmail);
      }
      throw AuthErrorMapper.fromFirebaseAuthException(e);
    } on AuthException {
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Register error: $e\n$stackTrace');
      }
      try {
        await _auth.signOut();
        await _googleSignIn.signOut();
      } catch (_) {}
      throw const AuthException(
        message:
            'No se completó el registro. Si el correo ya existe, usa "Iniciar sesión".',
      );
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String uid,
    String? displayName,
    String? phone,
  }) async {
    try {
      final userRef =
          _firestore.collection(FirebaseConstants.usersCollection).doc(uid);
      final Map<String, dynamic> updateData = {};

      if (displayName != null) {
        updateData[FirebaseConstants.fieldUserDisplayName] = displayName.trim();
      }
      if (phone != null) {
        updateData[FirebaseConstants.fieldUserPhone] = phone.trim();
      }
      if (updateData.isNotEmpty) {
        updateData[FirebaseConstants.fieldUpdatedAt] =
            FieldValue.serverTimestamp();
        await userRef.set(updateData, SetOptions(merge: true));
      }

      final updatedDoc = await userRef.get();
      if (!updatedDoc.exists || updatedDoc.data() == null) {
        throw const AuthException(
          message: 'No se encontró el usuario para actualizar.',
        );
      }

      if (displayName != null) {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          await currentUser.updateDisplayName(displayName.trim());
          await currentUser.reload();
        }
      }

      return UserModel.fromFirestore(updatedDoc);
    } on FirebaseAuthException catch (e) {
      throw AuthErrorMapper.fromFirebaseAuthException(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw const AuthException(
        message: 'Error al actualizar el perfil. Inténtalo de nuevo.',
      );
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Evita credenciales cacheadas de intentos fallidos anteriores.
      await _googleSignIn.signOut();

      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        throw const AuthException(
          message: 'El inicio de sesión con Google fue cancelado.',
          code: 'cancelled-popup-request',
        );
      }

      final googleAuth = await googleAccount.authentication;
      if (googleAuth.idToken == null) {
        throw const AuthException(
          message:
              'Google no devolvió un token válido. Revisa en Firebase Console '
              'que el SHA-1 de tu keystore esté registrado para com.caffenio.caffenio.',
          code: 'missing-id-token',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthException(
          message: 'No se pudo obtener la información de la cuenta Google.',
        );
      }

      return await _resolveUserAfterSignIn(firebaseUser);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw const AuthException(
          code: 'link-password-required',
          message:
              'Este correo ya tiene contraseña. Escríbela arriba y pulsa "Vincular con Google".',
        );
      }
      throw AuthErrorMapper.fromFirebaseAuthException(e);
    } on PlatformException catch (e) {
      throw AuthException(
        message: _googlePlatformErrorMessage(e),
        code: e.code,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Google sign-in error: $e\n$stackTrace');
      }
      throw AuthException(
        message: e.toString().contains('ApiException: 10')
            ? 'Configuración de Google incorrecta (SHA-1). En Firebase Console → '
                'com.caffenio.caffenio → agrega la huella SHA-1 de tu keystore de debug/release.'
            : 'Error al iniciar sesión con Google. Inténtalo de nuevo.',
      );
    }
  }

  static String _googlePlatformErrorMessage(PlatformException e) {
    return switch (e.code) {
      'sign_in_canceled' || '12501' =>
        'El inicio de sesión con Google fue cancelado.',
      'network_error' || '7' =>
        'Sin conexión. Revisa tu internet e inténtalo de nuevo.',
      'sign_in_failed' || '10' =>
        'Google Sign-In no está configurado para esta app. Registra el SHA-1 del '
            'keystore en Firebase (app com.caffenio.caffenio) y vuelve a descargar google-services.json.',
      _ => e.message?.isNotEmpty == true
          ? e.message!
          : 'Error al iniciar sesión con Google (${e.code}).',
    };
  }

  @override
  Future<UserModel> linkGoogleWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    try {
      await _googleSignIn.signOut();

      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        throw const AuthException(
          message: 'Vinculación con Google cancelada.',
          code: 'cancelled-popup-request',
        );
      }

      final googleAuth = await googleAccount.authentication;
      if (googleAuth.idToken == null) {
        throw const AuthException(
          message: 'No se pudo vincular Google. Intenta de nuevo.',
          code: 'missing-id-token',
        );
      }

      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final emailCredential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      final firebaseUser = emailCredential.user;
      if (firebaseUser == null) {
        throw const AuthException(
          message: 'No se pudo verificar tu contraseña.',
        );
      }

      final linked = await firebaseUser.linkWithCredential(googleCredential);
      return await _resolveUserAfterSignIn(linked.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        return await signInWithGoogle();
      }
      if (e.code == 'credential-already-in-use') {
        throw const AuthException(
          message: 'Google ya está vinculado a esta cuenta. Inicia sesión normalmente.',
          code: 'credential-already-in-use',
        );
      }
      throw await _mapEmailSignInException(e, trimmedEmail);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        message: 'No se pudo vincular Google: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> linkEmailPasswordToCurrentUser({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(
        message: 'Debes tener sesión iniciada para agregar contraseña.',
      );
    }

    final trimmedEmail = email.trim().toLowerCase();
    if (user.email?.toLowerCase() != trimmedEmail) {
      throw const AuthException(
        message: 'El correo debe coincidir con el de tu cuenta actual.',
      );
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: trimmedEmail,
        password: password,
      );
      await user.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked' ||
          e.code == 'email-already-in-use') {
        return;
      }
      throw AuthErrorMapper.fromFirebaseAuthException(e);
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw const AuthException(message: 'Error al cerrar sesión.');
    }
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthErrorMapper.fromFirebaseAuthException(e);
    } catch (e) {
      throw const AuthException(
        message: 'Error al enviar el correo. Inténtalo de nuevo.',
      );
    }
  }

  // ── Current User ──────────────────────────────────────────────────────────

  @override
  Future<UserModel?> getCurrentUserData() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    try {
      return await _fetchUserFromFirestore(firebaseUser);
    } catch (_) {
      return UserModel.fromFirebaseUser(firebaseUser);
    }
  }

  // ── Helpers privados ──────────────────────────────────────────────────────

  Future<AuthException> _mapRegisterEmailInUse(String email) async {
    final methods = await _fetchSignInMethods(email);
    if (methods.contains('google.com') && !methods.contains('password')) {
      return const AuthException(
        message:
            'Este correo ya usa Google. Entra con Google y en Perfil agrega una contraseña '
            'para poder usar ambos métodos.',
        code: 'email-in-use-google-only',
      );
    }
    if (methods.contains('password')) {
      return const AuthException(
        message:
            'Este correo ya está registrado. Inicia sesión con tu contraseña '
            'o vincula Google desde el botón "Vincular con Google".',
        code: 'email-already-in-use',
      );
    }
    return const AuthException(
      message: 'Este correo ya tiene cuenta. Intenta iniciar sesión.',
      code: 'email-already-in-use',
    );
  }

  Future<List<String>> _fetchSignInMethods(String email) async {
    try {
      return await _auth.fetchSignInMethodsForEmail(email);
    } catch (_) {
      return const [];
    }
  }

  Future<AuthException> _mapEmailSignInException(
    FirebaseAuthException e,
    String email,
  ) async {
    if (e.code == 'invalid-credential' ||
        e.code == 'invalid-login-credentials' ||
        e.code == 'wrong-password') {
      final methods = await _fetchSignInMethods(email);
      if (methods.contains('google.com') && !methods.contains('password')) {
        return const AuthException(
          message:
              'Esta cuenta aún no tiene contraseña. Entra con Google y en Perfil '
              'usa "Agregar contraseña" para activar correo/contraseña.',
          code: 'password-not-linked',
        );
      }
      if (methods.contains('password')) {
        return const AuthException(
          message:
              'Contraseña incorrecta. Verifica tus datos o usa "¿Olvidaste tu contraseña?".',
          code: 'wrong-password',
        );
      }
    }

    return switch (e.code) {
      'user-not-found' => const AuthException(
          message:
              'No hay cuenta con ese correo. Regístrate o revisa que el correo esté bien escrito.',
          code: 'user-not-found',
        ),
      'wrong-password' => const AuthException(
          message:
              'Contraseña incorrecta. Inténtalo de nuevo o usa "¿Olvidaste tu contraseña?".',
          code: 'wrong-password',
        ),
      'invalid-credential' || 'invalid-login-credentials' => const AuthException(
          message:
              'Correo o contraseña incorrectos. Si olvidaste la contraseña, recupérala.',
          code: 'invalid-credential',
        ),
      'operation-not-allowed' => const AuthException(
          message:
              'El inicio con correo no está habilitado en Firebase Console '
              '(Authentication → Email/Password).',
          code: 'operation-not-allowed',
        ),
      _ => AuthErrorMapper.fromFirebaseAuthException(e),
    };
  }

  /// Tras autenticar en Firebase Auth, carga o crea el perfil en Firestore.
  Future<UserModel> _resolveUserAfterSignIn(User firebaseUser) async {
    final userRef =
        _firestore.collection(FirebaseConstants.usersCollection).doc(firebaseUser.uid);
    final existing = await userRef.get();
    final isNewUser = !existing.exists;

    try {
      final user = await _fetchUserFromFirestore(firebaseUser);
      await _safeInitializeLoyalty(firebaseUser.uid);
      if (isNewUser) await _sendWelcomeNotification(firebaseUser.uid);
      return user;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Resolve user after sign-in: $e\n$stackTrace');
      }
      final fallback = UserModel.fromFirebaseUser(firebaseUser);
      try {
        await _createUserDocument(fallback);
      } catch (_) {
        // Si Firestore falla, igual entramos con datos de Auth.
      }
      await _safeInitializeLoyalty(firebaseUser.uid);
      if (isNewUser) await _sendWelcomeNotification(firebaseUser.uid);
      return fallback;
    }
  }

  Future<void> _safeInitializeLoyalty(String uid) async {
    try {
      await _initializeLoyaltyDocument(uid);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Loyalty init skipped: $e');
      }
    }
  }

  /// Obtiene el documento del usuario desde Firestore.
  /// Si no existe o el esquema es antiguo, usa Firebase Auth como respaldo.
  Future<UserModel> _fetchUserFromFirestore(User firebaseUser) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(firebaseUser.uid)
        .get();

    if (doc.exists && doc.data() != null) {
      try {
        return UserModel.fromFirestore(doc);
      } catch (_) {
        final fallback = UserModel.fromFirebaseUser(firebaseUser);
        await _createUserDocument(fallback);
        return fallback;
      }
    }

    final userModel = UserModel.fromFirebaseUser(firebaseUser);
    await _createUserDocument(userModel);
    return userModel;
  }

  /// Crea o actualiza el documento users/{uid} en Firestore.
  Future<void> _createUserDocument(UserModel user) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .set(user.toNewUserJson(), SetOptions(merge: true));
  }

  Future<void> _sendWelcomeNotification(String uid) async {
    final notifications = _notificationsDataSource;
    if (notifications == null) return;
    try {
      await notifications.sendToUser(
        uid: uid,
        title: 'Bienvenido a Caffenio',
        body:
            'Tu cuenta está lista. Empiezas con 0 puntos; gana puntos con cada pedido.',
        type: 'welcome',
      );
    } catch (_) {
      // No bloquear registro si falla la notificación.
    }
  }

  /// Inicializa loyaltyCards/{uid} con 0 puntos (plan de implementación).
  Future<void> _initializeLoyaltyDocument(String uid) async {
    final ref =
        _firestore.collection(FirebaseConstants.loyaltyCollection).doc(uid);

    // Solo crear si no existe
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        FirebaseConstants.fieldUid: uid,
        FirebaseConstants.fieldLoyaltyPoints: AppConstants.welcomeBonusPoints,
        FirebaseConstants.fieldLoyaltyTotalEarned:
            AppConstants.welcomeBonusPoints,
        FirebaseConstants.fieldLoyaltyTotalRedeemed: 0,
        FirebaseConstants.fieldLoyaltyLevel: 'bronze',
        FirebaseConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
        FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
    }
  }
}
