import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BaristaOrdersScreen extends StatelessWidget {
  const BaristaOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Consola de Barista'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pendientes'),
              Tab(text: 'En Preparación'),
              Tab(text: 'Listos para Recoger'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersList(status: OrderStatus.pending),
            OrdersList(status: OrderStatus.in_progress),
            OrdersList(status: OrderStatus.ready_for_pickup),
          ],
        ),
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final OrderStatus status;

  const OrdersList({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FirebaseConstants.ordersCollection)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los pedidos.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No hay pedidos con estado: ${status.name}'),
          );
        }

        final orders = snapshot.data!.docs.map((doc) {
          return OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return OrderCard(order: orders[index]);
          },
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({required this.order, super.key});

  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    await FirebaseFirestore.instance
        .collection(FirebaseConstants.ordersCollection)
        .doc(order.id)
        .update({'status': newStatus.name});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pedido #${order.id.substring(0, 6)}...',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${order.deliveryType == DeliveryType.delivery ? "Envío a domicilio" : "Para llevar"}',
              style: theme.textTheme.titleMedium,
            ),
            if (order.deliveryType == DeliveryType.toGo)
              Text('Sucursal: ${order.branchId ?? "No especificada"}', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              'Creado: ${DateFormat.yMd().add_Hms().format(order.createdAt)}',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: 24),
            ...order.items.map((item) => ListTile(
                  dense: true,
                  title: Text(item.productName),
                  subtitle: Text('Cantidad: ${item.quantity}'),
                  trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: theme.textTheme.titleMedium),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    switch (order.status) {
      case OrderStatus.pending:
        return FilledButton(
          onPressed: () => _updateOrderStatus(OrderStatus.in_progress),
          child: const Text('Empezar Preparación'),
        );
      case OrderStatus.in_progress:
        return FilledButton(
          onPressed: () => _updateOrderStatus(OrderStatus.ready_for_pickup),
          child: const Text('Marcar como Listo para Recoger'),
          style: FilledButton.styleFrom(backgroundColor: Colors.orange),
        );
      case OrderStatus.ready_for_pickup:
        return FilledButton(
          onPressed: () => _updateOrderStatus(OrderStatus.completed),
          child: const Text('Completar Pedido'),
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
