import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/shared/models/recipe_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> getRecipesByProductId(String productId);
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final FirebaseFirestore _firestore;

  RecipeRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  late final CollectionReference<Map<String, dynamic>> _recipesRef =
      _firestore.collection(FirebaseConstants.recipesCollection);

  @override
  Future<List<RecipeModel>> getRecipesByProductId(String productId) async {
    final snapshot =
        await _recipesRef.where('productId', isEqualTo: productId).get();
    return snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList();
  }
}
