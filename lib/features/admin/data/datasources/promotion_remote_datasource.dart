import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/shared/models/promotion_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PromotionRemoteDataSource {
  Stream<List<PromotionModel>> watchAllPromotions();
  Future<PromotionModel?> getPromotionById(String id);
  Future<void> createPromotion(PromotionModel promotion);
  Future<void> updatePromotion(PromotionModel promotion);
  Future<void> deletePromotion(String id);
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final FirebaseFirestore _firestore;

  PromotionRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  late final CollectionReference<Map<String, dynamic>> _promotionsRef =
      _firestore.collection(FirebaseConstants.promotionsCollection);

  @override
  Stream<List<PromotionModel>> watchAllPromotions() {
    return _promotionsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PromotionModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<PromotionModel?> getPromotionById(String id) async {
    final doc = await _promotionsRef.doc(id).get();
    if (!doc.exists) return null;
    return PromotionModel.fromFirestore(doc);
  }

  @override
  Future<void> createPromotion(PromotionModel promotion) async {
    await _promotionsRef.doc(promotion.id).set(promotion.toMap());
  }

  @override
  Future<void> updatePromotion(PromotionModel promotion) async {
    await _promotionsRef.doc(promotion.id).set(promotion.toMap());
  }

  @override
  Future<void> deletePromotion(String id) async {
    await _promotionsRef.doc(id).delete();
  }
}
