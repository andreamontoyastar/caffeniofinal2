import 'package:caffenio/shared/models/product_model.dart';

abstract class ProductRepository {
  Stream<List<ProductModel>> watchProducts();
  Future<ProductModel> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
}
