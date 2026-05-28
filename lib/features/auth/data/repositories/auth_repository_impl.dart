import 'package:caffenio/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:caffenio/features/auth/domain/entities/user_entity.dart';
import 'package:caffenio/features/auth/domain/repositories/auth_repository.dart';

/// Implementación concreta de [AuthRepository].
///
/// Delega toda la lógica de acceso a datos en [AuthRemoteDataSource].
/// Esta clase es el puente entre el dominio y los datos remotos.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<UserEntity?> get authStateChanges =>
      _remoteDataSource.authStateChanges;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
    required String phone,
  }) {
    return _remoteDataSource.createUserWithEmailAndPassword(
      email,
      password,
      displayName,
      phone,
    );
  }

  @override
  Future<UserEntity> updateProfile({
    required String uid,
    String? displayName,
    String? phone,
    String? address,
  }) {
    return _remoteDataSource.updateUserProfile(
      uid: uid,
      displayName: displayName,
      phone: phone,
      address: address,
    );
  }

  @override
  Future<UserEntity> loginWithGoogle() {
    return _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<UserEntity> linkGoogleWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.linkGoogleWithEmailPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> linkEmailPasswordToCurrentUser({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.linkEmailPasswordToCurrentUser(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.signOut();
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    return _remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return _remoteDataSource.getCurrentUserData();
  }
}
