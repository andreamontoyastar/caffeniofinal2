import 'package:caffenio/features/admin/data/datasources/recipe_remote_datasource.dart';
import 'package:caffenio/features/admin/domain/repositories/recipe_repository.dart';
import 'package:caffenio/shared/models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remoteDataSource;

  RecipeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RecipeModel>> getRecipesByProductId(String productId) {
    return remoteDataSource.getRecipesByProductId(productId);
  }
}
