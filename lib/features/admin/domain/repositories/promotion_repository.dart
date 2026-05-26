import 'package:caffenio/shared/models/promotion_model.dart';

abstract class PromotionRepository {
  Stream<List<PromotionModel>> watchAllPromotions();
  Future<PromotionModel?> getPromotionById(String id);
  Future<void> createPromotion(PromotionModel promotion);
  Future<void> updatePromotion(PromotionModel promotion);
  Future<void> deletePromotion(String id);
}
