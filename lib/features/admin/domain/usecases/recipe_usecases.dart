import 'package:caffenio/features/admin/domain/repositories/recipe_repository.dart';
import 'package:caffenio/shared/models/recipe_model.dart';

class GetRecipesByProductId {
  final RecipeRepository repository;

  GetRecipesByProductId({required this.repository});

  Future<List<RecipeModel>> call(String productId) {
    return repository.getRecipesByProductId(productId);
  }
}
