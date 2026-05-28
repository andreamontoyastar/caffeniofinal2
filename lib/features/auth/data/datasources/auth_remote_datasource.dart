import 'dart:async';
import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/errors/auth_error_mapper.dart';
import 'package:caffenio/core/errors/exceptions.dart';
import 'package:caffenio/features/auth/data/models/user_model.dart';
import 'package:caffenio/features/notifications/data/notifications_remote_datasource.dart';
import 'package:caffenio/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> createUserWithEmailAndPassword(String email, String password, String displayName, String phone);
  Future<UserModel> updateUserProfile({required String uid, String? displayName, String? phone, String? address});
  Future<UserModel> signInWithGoogle();
  Future<UserModel> linkGoogleWithEmailPassword({required String email, required String password});
  Future<void> linkEmailPasswordToCurrentUser({required String email, required String password});
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel?> getCurrentUserData();
}

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
            ) {
    _initCombinedStream();
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final NotificationsRemoteDataSource? _notificationsDataSource;

  final StreamController<UserModel?> _localUserStream = StreamController<UserModel?>.broadcast();
  UserModel? _cachedUser;
  late final StreamController<UserModel?> _combinedStreamController;

  void _initCombinedStream() {
    _combinedStreamController = StreamController<UserModel?>.broadcast();
    
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _combinedStreamController.add(_cachedUser);
      } else {
        try {
          final user = await _fetchUserFromFirestore(firebaseUser);
          _cachedUser = user;
          _combinedStreamController.add(user);
        } catch (_) {
          final user = UserModel.fromFirebaseUser(firebaseUser);
          _cachedUser = user;
          _combinedStreamController.add(user);
        }
      }
    }, onError: (Object err) {
      _combinedStreamController.addError(err);
    });

    _localUserStream.stream.listen((localUser) {
      _cachedUser = localUser;
      _combinedStreamController.add(localUser);
    }, onError: (Object err) {
      _combinedStreamController.addError(err);
    });
  }

  @override
  Stream<UserModel?> get authStateChanges => _combinedStreamController.stream;

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    final trimmedEmail = email.trim().toLowerCase();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      return await _resolveUserAfterSignIn(credential.user!);
    } on FirebaseAuthException catch (e) {
      try {
        final query = await _firestore
            .collection(FirebaseConstants.usersCollection)
            .where('email', isEqualTo: trimmedEmail)
            .get();
        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          final storedPassword = doc.data()['password'] as String?;
          if (storedPassword != null && storedPassword == password) {
            final userModel = UserModel.fromFirestore(doc);
            _cachedUser = userModel;
            _localUserStream.add(userModel);
            return userModel;
          }
        }
      } catch (err) {
        debugPrint('Fallback login error: $err');
      }
      throw await _mapEmailSignInException(e, trimmedEmail);
    } catch (e) {
      try {
        final query = await _firestore
            .collection(FirebaseConstants.usersCollection)
            .where('email', isEqualTo: trimmedEmail)
            .get();
        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          final storedPassword = doc.data()['password'] as String?;
          if (storedPassword != null && storedPassword == password) {
            final userModel = UserModel.fromFirestore(doc);
            _cachedUser = userModel;
            _localUserStream.add(userModel);
            return userModel;
          }
        }
      } catch (err) {
        debugPrint('Fallback login error: $err');
      }
      throw const AuthException(message: 'No se pudo completar el inicio de sesión.');
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

      final userModel = UserModel.fromFirebaseUser(_auth.currentUser ?? firebaseUser).copyWith(
        displayName: displayName.trim(),
        phone: phone.trim(),
      );

      await _createUserDocument(userModel);
      await _safeInitializeLoyalty(firebaseUser.uid);
      await _sendWelcomeNotification(firebaseUser.uid);

      return userModel;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw await _mapRegisterEmailInUse(trimmedEmail);
      }
      throw AuthErrorMapper.fromFirebaseAuthException(e);
    } catch (e) {
      throw const AuthException(message: 'No se completó el registro.');
    }
  }

  @override
  Future<UserModel> updateUserProfile({required String uid, String? displayName, String? phone, String? address}) async {
    try {
      final userRef = _firestore.collection(FirebaseConstants.usersCollection).doc(uid);
      final Map<String, dynamic> updateData = {};

      if (displayName != null) updateData[FirebaseConstants.fieldUserDisplayName] = displayName.trim();
      if (phone != null) updateData[FirebaseConstants.fieldUserPhone] = phone.trim();
      if (address != null) updateData[FirebaseConstants.fieldUserAddress] = address.trim();

      if (updateData.isNotEmpty) {
        updateData[FirebaseConstants.fieldUpdatedAt] = FieldValue.serverTimestamp();
        await userRef.set(updateData, SetOptions(merge: true));
      }

      if (displayName != null && _auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(displayName.trim());
        await _auth.currentUser!.reload();
      }

      final updatedDoc = await userRef.get();
      return UserModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw const AuthException(message: 'Error al actualizar el perfil.');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    GoogleSignInAccount? googleAccount;
    try {
      googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        throw const AuthException(message: 'El inicio de sesión fue cancelado.');
      }

      final googleAuth = await googleAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return await _resolveUserAfterSignIn(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential' || e.code == 'credential-already-in-use') {
        try {
          final googleEmail = googleAccount?.email ?? '';
          if (googleEmail.isNotEmpty) {
            final query = await _firestore
                .collection(FirebaseConstants.usersCollection)
                .where('email', isEqualTo: googleEmail.trim().toLowerCase())
                .get();
            if (query.docs.isNotEmpty) {
              final doc = query.docs.first;
              final userModel = UserModel.fromFirestore(doc);
              _cachedUser = userModel;
              _localUserStream.add(userModel);
              return userModel;
            }
          }
        } catch (err) {
          debugPrint('Google fallback login error: $err');
        }
      }
      throw AuthErrorMapper.fromFirebaseAuthException(e);
    } catch (e) {
      try {
        final googleEmail = googleAccount?.email ?? '';
        if (googleEmail.isNotEmpty) {
          final query = await _firestore
              .collection(FirebaseConstants.usersCollection)
              .where('email', isEqualTo: googleEmail.trim().toLowerCase())
              .get();
          if (query.docs.isNotEmpty) {
            final doc = query.docs.first;
            final userModel = UserModel.fromFirestore(doc);
            _cachedUser = userModel;
            _localUserStream.add(userModel);
            return userModel;
          }
        }
      } catch (err) {
        debugPrint('Google fallback login error: $err');
      }
      debugPrint('Error Google Sign-In: $e');
      throw const AuthException(message: 'Error al iniciar sesión con Google. Verifica tu configuración SHA-1 o usa inicio con correo.');
    }
  }

  @override
  Future<UserModel> linkGoogleWithEmailPassword({required String email, required String password}) async {
    final trimmedEmail = email.trim().toLowerCase();
    try {
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) throw const AuthException(message: 'Cancelado.');

      final googleAuth = await googleAccount.authentication;
      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final emailCredential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      final linked = await emailCredential.user!.linkWithCredential(googleCredential);
      return await _resolveUserAfterSignIn(linked.user!);
    } catch (e) {
      throw const AuthException(message: 'No se pudo vincular la cuenta.');
    }
  }

  @override
  Future<void> linkEmailPasswordToCurrentUser({required String email, required String password}) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(message: 'Sin sesión activa.');
    try {
      final credential = EmailAuthProvider.credential(email: email.trim().toLowerCase(), password: password);
      await user.linkWithCredential(credential);
    } catch (e) {
      throw const AuthException(message: 'Error al vincular contraseña.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _cachedUser = null;
      _localUserStream.add(null);
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (_) {
      throw const AuthException(message: 'No existe ninguna cuenta con este correo.');
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return await _fetchUserFromFirestore(firebaseUser);
  }

  Future<AuthException> _mapRegisterEmailInUse(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.contains('google.com') && !methods.contains('password')) {
        return const AuthException(
          message: 'Este correo ya está registrado mediante Google. Usa el botón "Continuar con Google".',
        );
      }
    } catch (_) {}
    return const AuthException(message: 'El correo ya está registrado. Intenta iniciar sesión.');
  }

  Future<AuthException> _mapEmailSignInException(FirebaseAuthException e, String email) async {
    if (e.code == 'invalid-credential' || e.code == 'wrong-password' || e.code == 'invalid-login-credentials') {
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.contains('google.com') && !methods.contains('password')) {
          return const AuthException(
            message: 'Esta cuenta fue creada con Google. Por favor, inicia sesión usando el botón "Continuar con Google".',
          );
        }
      } catch (_) {}
      return const AuthException(message: 'Contraseña incorrecta. Verifica tus datos.');
    }
    if (e.code == 'user-not-found' || e.code == 'invalid-email') {
      return const AuthException(message: 'No existe ninguna cuenta con este correo.');
    }
    return AuthErrorMapper.fromFirebaseAuthException(e);
  }

  Future<UserModel> _resolveUserAfterSignIn(User firebaseUser) async {
    debugPrint('Usuario autenticado: ${firebaseUser.email}');
    final user = await _fetchUserFromFirestore(firebaseUser);
    await _updateLastLogin(firebaseUser.uid);
    await _safeInitializeLoyalty(firebaseUser.uid);
    return user;
  }

  Future<void> _safeInitializeLoyalty(String uid) async {
    try {
      await _initializeLoyaltyDocument(uid);
    } catch (_) {}
  }

  Future<UserModel> _fetchUserFromFirestore(User firebaseUser) async {
    final doc = await _firestore.collection(FirebaseConstants.usersCollection).doc(firebaseUser.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc);
    }
    final fallback = UserModel.fromFirebaseUser(firebaseUser);
    await _createUserDocument(fallback);
    return fallback;
  }

  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection(FirebaseConstants.usersCollection).doc(uid).update({
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((_) => null);
  }

  Future<void> _createUserDocument(UserModel user) async {
    await _firestore.collection(FirebaseConstants.usersCollection).doc(user.uid).set({
      'uid': user.uid,
      'email': user.email.toLowerCase().trim(),
      'displayName': user.displayName?.trim() ?? 'Cliente Caffenio',
      'phone': user.phone?.trim() ?? '',
      'role': 'customer',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _sendWelcomeNotification(String uid) async {
    if (_notificationsDataSource == null) return;
    try {
      await _notificationsDataSource!.sendToUser(
        uid: uid,
        title: 'Bienvenido a Caffenio',
        body: 'Tu cuenta está lista. Empiezas con 0 puntos.',
        type: 'welcome',
      );
    } catch (_) {}
  }

  Future<void> _initializeLoyaltyDocument(String uid) async {
    final ref = _firestore.collection(FirebaseConstants.loyaltyCollection).doc(uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'uid': uid,
        'points': 0,
        'totalEarned': 0,
        'totalRedeemed': 0,
        'level': 'bronze',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
