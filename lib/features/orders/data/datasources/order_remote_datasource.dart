import 'dart:async';
import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/features/admin/domain/services/stock_automation_service.dart';
import 'package:caffenio/features/notifications/data/notifications_remote_datasource.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

abstract class OrderRemoteDataSource {
  Stream<List<OrderModel>> watchCustomerOrders(String userId);
  Stream<List<OrderModel>> watchAllOrders();
  Future<void> placeOrder(OrderModel order);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required StockAutomationService stockAutomationService,
  })  : _firestore = firestore,
        _stockService = stockAutomationService {
    _startOrderSimulator();
  }

  final FirebaseFirestore _firestore;
  final StockAutomationService _stockService;

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

    // Descontar inventario por cada item del pedido
    if (order.branchId != null && order.branchId!.isNotEmpty) {
      for (final item in order.items) {
        try {
          await _stockService.consumeIngredientsForOrder(
            sucursalId: order.branchId!,
            productId: item.product.id,
            quantity: item.quantity.toDouble(),
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Stock decrement error for ${item.product.id}: $e');
          }
        }
      }
    }
  }

  void _startOrderSimulator() {
    Timer.periodic(const Duration(seconds: 25), (timer) async {
      try {
        final activeOrders = await _ordersRef
            .where(FirebaseConstants.fieldOrderStatus, whereIn: ['pending', 'preparing', 'ready'])
            .get();

        for (final doc in activeOrders.docs) {
          final data = doc.data();
          final String currentStatus = data[FirebaseConstants.fieldOrderStatus]?.toString() ?? 'pending';
          
          String nextStatus = currentStatus;
          if (currentStatus == 'pending') {
            nextStatus = 'preparing';
          } else if (currentStatus == 'preparing') {
            nextStatus = 'ready';
          }

          if (nextStatus != currentStatus) {
            await doc.reference.update({FirebaseConstants.fieldOrderStatus: nextStatus});
            
            // Enviar notificación al usuario del cambio de estado del simulador
            final String userId = data[FirebaseConstants.fieldOrderUserId]?.toString() ?? '';
            if (userId.isNotEmpty && userId != 'Anónimo') {
              try {
                final notifyService = sl<NotificationsRemoteDataSource>();
                final orderDisplayId = data['displayId']?.toString() ?? doc.id;
                final String deliveryTypeStr = data['deliveryType']?.toString() ?? 'inStore';
                
                String statusTitle = 'Actualización de tu pedido';
                String statusBody = 'El pedido $orderDisplayId ahora está: Preparando';
                
                if (nextStatus == 'ready') {
                  statusTitle = '¡Pedido Listo!';
                  statusBody = deliveryTypeStr == 'delivery'
                      ? 'Tu repartidor va en camino con tu pedido $orderDisplayId a domicilio.'
                      : 'Tu pedido $orderDisplayId ya está listo para recoger en sucursal.';
                }

                await notifyService.sendToUser(
                  uid: userId,
                  title: statusTitle,
                  body: statusBody,
                  type: 'order',
                  orderId: doc.id,
                );
              } catch (_) {}
            }
          }
        }
      } catch (_) {}
    });
  }
}
