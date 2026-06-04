import 'dart:async';
import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/features/notifications/data/notifications_remote_datasource.dart';
import 'package:caffenio/features/orders/domain/repositories/order_repository.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceOrder {
  PlaceOrder({required OrderRepository repository}) : _repository = repository;

  final OrderRepository _repository;

  Future<void> call(OrderModel order) async {
    await _repository.placeOrder(order);

    // Iniciar simulación en segundo plano para cambiar el estado automáticamente
    _startOrderSimulation(order);
  }

  void _startOrderSimulation(OrderModel order) {
    final transitions = [
      (status: OrderStatus.preparing, delay: 10, label: 'En Preparación'),
      (status: OrderStatus.ready, delay: 20, label: 'Listo para Entregar'),
      (status: OrderStatus.delivered, delay: 30, label: 'Entregado'),
    ];

    for (final t in transitions) {
      Timer(Duration(seconds: t.delay), () async {
        try {
          final docRef = FirebaseFirestore.instance
              .collection(FirebaseConstants.ordersCollection)
              .doc(order.id);

          final docSnap = await docRef.get();
          if (!docSnap.exists) return;

          final currentStatus = docSnap.data()?['status']?.toString();
          if (currentStatus == 'cancelled' || currentStatus == 'delivered') return;

          await docRef.update({'status': t.status.name});

          if (order.userId.isNotEmpty && order.userId != 'Anónimo') {
            await sl<NotificationsRemoteDataSource>().sendToUser(
              uid: order.userId,
              title: 'Tu pedido cambió de estado',
              body: 'El pedido ${order.displayId} ahora está: ${t.label}',
              type: 'order',
              orderId: order.id,
            );
          }
        } catch (_) {
          // Ignorar fallas de red en simulación
        }
      });
    }
  }
}
