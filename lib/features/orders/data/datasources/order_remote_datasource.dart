import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

abstract class OrderRemoteDataSource {
  Stream<List<OrderModel>> watchCustomerOrders(String userId);
  Stream<List<OrderModel>> watchAllOrders();
  Future<void> placeOrder(OrderModel order);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection(FirebaseConstants.ordersCollection);

  @override
  Stream<List<OrderModel>> watchCustomerOrders(String userId) {
    // Sin orderBy para evitar índice compuesto; ordenamos en cliente.
    return _ordersRef
        .where(FirebaseConstants.fieldOrderUserId, isEqualTo: userId)
        .snapshots()
        .map(_mapOrderDocuments);
  }

  @override
  Stream<List<OrderModel>> watchAllOrders() {
    return _ordersRef.snapshots().map(_mapOrderDocuments);
  }

  List<OrderModel> _mapOrderDocuments(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final orders = <OrderModel>[];
    for (final doc in snapshot.docs) {
      try {
        orders.add(OrderModel.fromFirestore(doc));
      } catch (e, stack) {
        if (kDebugMode) {
          debugPrint('Order parse skip ${doc.id}: $e\n$stack');
        }
      }
    }
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<void> placeOrder(OrderModel order) async {
    final document =
        order.id.isNotEmpty ? _ordersRef.doc(order.id) : _ordersRef.doc();

    final orderToSave =
        order.id.isNotEmpty ? order : order.copyWith(id: document.id);

    await document.set(orderToSave.toMap(userId: order.userId));
  }
}
