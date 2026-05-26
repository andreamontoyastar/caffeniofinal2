import 'dart:async';

import 'package:caffenio/core/errors/exceptions.dart';
import 'package:caffenio/features/auth/domain/entities/user_entity.dart';
import 'package:caffenio/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Estados posibles del flujo de autenticación.
enum AuthStatus {
  /// Estado inicial: aún no se ha verificado si hay sesión activa.
  initial,

  /// Verificando o ejecutando una operación de auth.
  loading,

  /// Usuario autenticado correctamente.
  authenticated,

  /// Sin sesión activa.
  unauthenticated,

  /// Error en la última operación de auth.
  error,
}

/// Provider de autenticación — estado central de la sesión del usuario.
///
/// Escucha el stream [AuthRepository.authStateChanges] y expone métodos
/// para iniciar/cerrar sesión, registrarse y recuperar contraseña.
class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _listenToAuthState();
  }

  final AuthRepository _authRepository;
  StreamSubscription<UserEntity?>? _authSubscription;

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _errorMessage;
  String? _errorCode;
  bool _isActionLoading = false;

  // ── Getters ───────────────────────────────────────────────────────────────

  AuthStatus get authStatus => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isActionLoading => _isActionLoading;
  bool get hasError => _status == AuthStatus.error;

  String get displayName => _currentUser?.displayNameOrEmail ?? '';
  String get email => _currentUser?.email ?? '';
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isBarista => _currentUser?.isBarista ?? false;
  bool get isCustomer => _currentUser?.isCustomer ?? true;

  /// True si la sesión actual no tiene contraseña (solo Google u otro proveedor).
  bool get canAddPassword {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return false;
    return !firebaseUser.providerData
        .any((info) => info.providerId == EmailAuthProvider.PROVIDER_ID);
  }

  // ── Stream de auth state ──────────────────────────────────────────────────

  void _listenToAuthState() {
    _status = AuthStatus.loading;
    _authSubscription = _authRepository.authStateChanges.listen(
      (user) {
        _currentUser = user;
        _status = user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        _status = AuthStatus.error;
        _errorMessage = 'Error al verificar la sesión. Inténtalo de nuevo.';
        notifyListeners();
      },
    );
  }

  // ── Métodos públicos ──────────────────────────────────────────────────────

  /// Inicia sesión con correo y contraseña.
  /// Retorna true si fue exitoso.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _beginAction();
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message, code: e.code);
      return false;
    } catch (_) {
      _setError('Ocurrió un error inesperado. Inténtalo de nuevo.');
      return false;
    } finally {
      _endAction();
    }
  }

  /// Crea una cuenta nueva.
  /// Retorna true si fue exitoso.
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    required String phone,
  }) async {
    try {
      _beginAction();
      final user = await _authRepository.register(
        email: email,
        password: password,
        displayName: displayName,
        phone: phone,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message, code: e.code);
      return false;
    } catch (_) {
      _setError('Error al crear la cuenta. Inténtalo de nuevo.');
      return false;
    } finally {
      _endAction();
    }
  }

  /// Inicia sesión con Google.
  /// Retorna true si fue exitoso.
  Future<bool> signInWithGoogle() async {
    try {
      _beginAction();
      final user = await _authRepository.loginWithGoogle();
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message, code: e.code);
      return false;
    } catch (e) {
      _setError('Error al iniciar sesión con Google.');
      return false;
    } finally {
      _endAction();
    }
  }

  /// Vincula Google a una cuenta con correo/contraseña (mismo correo).
  Future<bool> linkGoogleWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      _beginAction();
      final user = await _authRepository.linkGoogleWithEmailPassword(
        email: email,
        password: password,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _errorCode = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message, code: e.code);
      return false;
    } catch (_) {
      _setError('No se pudo vincular Google. Inténtalo de nuevo.');
      return false;
    } finally {
      _endAction();
    }
  }

  /// Agrega contraseña a la cuenta actual (útil tras entrar con Google).
  Future<bool> linkEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      _beginAction();
      await _authRepository.linkEmailPasswordToCurrentUser(
        email: email,
        password: password,
      );
      _errorMessage = null;
      _errorCode = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message, code: e.code);
      return false;
    } catch (_) {
      _setError('No se pudo agregar la contraseña. Inténtalo de nuevo.');
      return false;
    } finally {
      _endAction();
    }
  }

  /// Cierra la sesión actual.
  Future<void> signOut() async {
    try {
      _beginAction();
      await _authRepository.logout();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Error al cerrar sesión.');
    } finally {
      _endAction();
    }
  }

  /// Envía correo de recuperación de contraseña.
  /// Retorna true si el correo fue enviado.
  Future<bool> sendPasswordReset({required String email}) async {
    try {
      _beginAction();
      await _authRepository.sendPasswordReset(email: email);
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Error al enviar el correo. Inténtalo de nuevo.');
      return false;
    } finally {
      _endAction();
    }
  }

  /// Actualiza los datos del usuario en su perfil.
  Future<bool> updateProfile({
    String? displayName,
    String? phone,
  }) async {
    if (_currentUser == null) return false;
    try {
      _beginAction();
      final user = await _authRepository.updateProfile(
        uid: _currentUser!.uid,
        displayName: displayName,
        phone: phone,
      );
      _currentUser = user;
      _errorMessage = null;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Error al actualizar el perfil. Inténtalo de nuevo.');
      return false;
    } finally {
      _endAction();
    }
  }

  /// Limpia el mensaje de error actual.
  void clearError() {
    if (_errorMessage == null && _errorCode == null) return;
    _errorMessage = null;
    _errorCode = null;
    if (_status == AuthStatus.error) {
      _status = _currentUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Helpers privados ──────────────────────────────────────────────────────

  void _beginAction() {
    _isActionLoading = true;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();
  }

  void _endAction() {
    _isActionLoading = false;
    notifyListeners();
  }

  void _setError(String message, {String? code}) {
    _isActionLoading = false;
    _errorMessage = message;
    _errorCode = code;
    if (_status != AuthStatus.authenticated) {
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
