import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/shared/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ProductRemoteDataSource {
  Stream<List<ProductModel>> watchProducts();
  Future<ProductModel> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;
  bool _hasSeededProducts = false;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection(FirebaseConstants.productsCollection);

  @override
  Stream<List<ProductModel>> watchProducts() {
    return _productsRef
        .orderBy(FirebaseConstants.fieldProductName)
        .snapshots()
        .asyncMap((snapshot) async {
      final products =
          snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
      await _seedInitialProductsIfNeeded(products);
      return products;
    });
  }

  Future<void> _seedInitialProductsIfNeeded(List<ProductModel> products) async {
    if (_hasSeededProducts) return;
    if (products.isNotEmpty) {
      _hasSeededProducts = true;
      return;
    }

    final batch = _firestore.batch();
    for (final product in ProductModel.mockProducts) {
      final productDoc = _productsRef.doc(product.id);
      batch.set(productDoc, product.toJson());
    }
    await batch.commit();
    _hasSeededProducts = true;
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    final doc = _productsRef.doc();
    final productWithId = product.copyWith(id: doc.id);
    await doc.set(productWithId.toJson());
    return productWithId;
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _productsRef
        .doc(product.id)
        .set(product.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _productsRef.doc(productId).delete();
  }
}
