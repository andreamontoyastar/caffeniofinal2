import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/shared/models/purchase_order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PurchaseOrderRemoteDataSource {
  Stream<List<PurchaseOrderModel>> watchAllPurchaseOrders();
  Future<PurchaseOrderModel?> getPurchaseOrderById(String id);
  Future<void> createPurchaseOrder(PurchaseOrderModel order);
  Future<void> updatePurchaseOrder(PurchaseOrderModel order);
  Future<void> deletePurchaseOrder(String id);
}

class PurchaseOrderRemoteDataSourceImpl
    implements PurchaseOrderRemoteDataSource {
  final FirebaseFirestore _firestore;

  PurchaseOrderRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  late final CollectionReference<Map<String, dynamic>> _ordersRef =
      _firestore.collection(FirebaseConstants.purchaseOrdersCollection);

  @override
  Stream<List<PurchaseOrderModel>> watchAllPurchaseOrders() {
    return _ordersRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PurchaseOrderModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<PurchaseOrderModel?> getPurchaseOrderById(String id) async {
    final doc = await _ordersRef.doc(id).get();
    if (!doc.exists) return null;
    return PurchaseOrderModel.fromFirestore(doc);
  }

  @override
  Future<void> createPurchaseOrder(PurchaseOrderModel order) async {
    await _ordersRef.doc(order.id).set(order.toMap());
  }

  @override
  Future<void> updatePurchaseOrder(PurchaseOrderModel order) async {
    await _ordersRef.doc(order.id).update(order.toMap());
  }

  @override
  Future<void> deletePurchaseOrder(String id) async {
    await _ordersRef.doc(id).delete();
  }
}
