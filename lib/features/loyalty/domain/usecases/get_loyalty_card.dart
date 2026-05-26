import 'package:caffenio/features/loyalty/data/models/loyalty_card_model.dart';
import 'package:caffenio/features/loyalty/domain/repositories/loyalty_repository.dart';

class GetLoyaltyCard {
  GetLoyaltyCard({required LoyaltyRepository repository})
      : _repository = repository;

  final LoyaltyRepository _repository;

  Stream<LoyaltyCardModel?> call(String uid) {
    return _repository.watchLoyaltyCard(uid);
  }
}
