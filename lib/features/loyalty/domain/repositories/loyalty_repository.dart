import 'package:caffenio/features/loyalty/data/models/loyalty_card_model.dart';

abstract class LoyaltyRepository {
  Stream<LoyaltyCardModel?> watchLoyaltyCard(String uid);
  Future<void> updateLoyaltyPoints({
    required String uid,
    required int pointsEarned,
  });
}
