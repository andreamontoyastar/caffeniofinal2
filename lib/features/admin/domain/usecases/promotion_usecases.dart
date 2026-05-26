import 'package:caffenio/features/admin/domain/repositories/promotion_repository.dart';
import 'package:caffenio/shared/models/promotion_model.dart';

class WatchAllPromotions {
  final PromotionRepository repository;

  WatchAllPromotions({required this.repository});

  Stream<List<PromotionModel>> call() {
    return repository.watchAllPromotions();
  }
}

class GetPromotionById {
  final PromotionRepository repository;

  GetPromotionById({required this.repository});

  Future<PromotionModel?> call(String id) {
    return repository.getPromotionById(id);
  }
}

class CreatePromotion {
  final PromotionRepository repository;

  CreatePromotion({required this.repository});

  Future<void> call(PromotionModel promotion) {
    return repository.createPromotion(promotion);
  }
}

class UpdatePromotion {
  final PromotionRepository repository;

  UpdatePromotion({required this.repository});

  Future<void> call(PromotionModel promotion) {
    return repository.updatePromotion(promotion);
  }
}

class DeletePromotion {
  final PromotionRepository repository;

  DeletePromotion({required this.repository});

  Future<void> call(String id) {
    return repository.deletePromotion(id);
  }
}
