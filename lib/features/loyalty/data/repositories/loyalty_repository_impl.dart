import 'package:caffenio/features/loyalty/data/datasources/loyalty_remote_datasource.dart';
import 'package:caffenio/features/loyalty/data/models/loyalty_card_model.dart';
import 'package:caffenio/features/loyalty/domain/repositories/loyalty_repository.dart';

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  LoyaltyRepositoryImpl({required LoyaltyRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final LoyaltyRemoteDataSource _remoteDataSource;

  @override
  Stream<LoyaltyCardModel?> watchLoyaltyCard(String uid) {
    return _remoteDataSource.watchLoyaltyCard(uid);
  }

  @override
  Future<void> updateLoyaltyPoints({
    required String uid,
    required int pointsEarned,
  }) {
    return _remoteDataSource.updateLoyaltyPoints(
      uid: uid,
      pointsEarned: pointsEarned,
    );
  }
}
