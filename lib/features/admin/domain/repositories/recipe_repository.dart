import 'package:caffenio/shared/models/recipe_model.dart';

abstract class RecipeRepository {
  Future<List<RecipeModel>> getRecipesByProductId(String productId);
}
