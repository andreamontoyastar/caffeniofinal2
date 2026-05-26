import 'package:caffenio/features/admin/data/datasources/promotion_remote_datasource.dart';
import 'package:caffenio/features/admin/domain/repositories/promotion_repository.dart';
import 'package:caffenio/shared/models/promotion_model.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remoteDataSource;

  PromotionRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<PromotionModel>> watchAllPromotions() {
    return remoteDataSource.watchAllPromotions();
  }

  @override
  Future<PromotionModel?> getPromotionById(String id) {
    return remoteDataSource.getPromotionById(id);
  }

  @override
  Future<void> createPromotion(PromotionModel promotion) {
    return remoteDataSource.createPromotion(promotion);
  }

  @override
  Future<void> updatePromotion(PromotionModel promotion) {
    return remoteDataSource.updatePromotion(promotion);
  }

  @override
  Future<void> deletePromotion(String id) {
    return remoteDataSource.deletePromotion(id);
  }
}
