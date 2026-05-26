import 'package:caffenio/features/loyalty/domain/repositories/loyalty_repository.dart';

class UpdateLoyaltyPoints {
  UpdateLoyaltyPoints({required LoyaltyRepository repository})
      : _repository = repository;

  final LoyaltyRepository _repository;

  Future<void> call({
    required String uid,
    required int pointsEarned,
  }) {
    return _repository.updateLoyaltyPoints(
      uid: uid,
      pointsEarned: pointsEarned,
    );
  }
}
