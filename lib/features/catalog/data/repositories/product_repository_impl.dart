import 'package:caffenio/features/catalog/data/datasources/product_remote_datasource.dart';
import 'package:caffenio/features/catalog/domain/repositories/product_repository.dart';
import 'package:caffenio/shared/models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(
      {required ProductRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Stream<List<ProductModel>> watchProducts() {
    return _remoteDataSource.watchProducts();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) {
    return _remoteDataSource.addProduct(product);
  }

  @override
  Future<void> updateProduct(ProductModel product) {
    return _remoteDataSource.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String productId) {
    return _remoteDataSource.deleteProduct(productId);
  }
}
