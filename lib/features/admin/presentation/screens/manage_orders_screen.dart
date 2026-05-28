import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/core/theme/app_typography.dart';
import 'package:caffenio/features/notifications/data/notifications_remote_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  String _selectedFilter = 'todos';

  String _translateStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'preparing':
        return 'En Preparación';
      case 'ready':
        return 'Listo para Entregar';
      case 'delivered':
        return 'Entregado';
      default:
        return status;
    }
  }

  String _nextStatus(String status) {
    switch (status) {
      case 'pending':
        return 'preparing';
      case 'preparing':
        return 'ready';
      case 'ready':
        return 'delivered';
      default:
        return status;
    }
  }

  String _nextStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Marcar En Preparación';
      case 'preparing':
        return 'Marcar como Listo';
      case 'ready':
        return 'Marcar como Entregado';
      default:
        return 'Actualizar';
    }
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> orderDoc,
    String currentStatus,
  ) async {
    final String nextStatus = _nextStatus(currentStatus);
    if (nextStatus == currentStatus) return;

    await FirebaseFirestore.instance
        .collection(FirebaseConstants.ordersCollection)
        .doc(orderDoc.id)
        .update({FirebaseConstants.fieldOrderStatus: nextStatus});

    final String userId = orderDoc.data()[FirebaseConstants.fieldOrderUserId]?.toString() ?? '';
    if (userId.isNotEmpty && userId != 'Anónimo') {
      try {
        final statusLabel = _translateStatus(nextStatus);
        final orderDisplayId = orderDoc.data()['displayId']?.toString() ?? orderDoc.id;
        await sl<NotificationsRemoteDataSource>().sendToUser(
          uid: userId,
          title: 'Tu pedido cambió de estado',
          body: 'El pedido $orderDisplayId ahora está: $statusLabel',
          type: 'order',
          orderId: orderDoc.id,
        );
      } catch (_) {}
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido actualizado a ${_translateStatus(nextStatus)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: ['todos', 'pending', 'preparing', 'ready', 'delivered'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter == 'todos' ? 'Todos' : _translateStatus(filter)),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection(FirebaseConstants.ordersCollection)
                  .orderBy(FirebaseConstants.fieldCreatedAt, descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var docs = snapshot.data!.docs;

                // Filtrar localmente si no es 'todos'
                if (_selectedFilter != 'todos') {
                  docs = docs.where((d) => d.data()['status'] == _selectedFilter).toList();
                }

                if (docs.isEmpty) {
                  return const Center(child: Text('No hay pedidos en este estado.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final orderDoc = docs[index];
                    final orderData = orderDoc.data();
                    final status = orderData['status']?.toString() ?? 'pending';
                    final total = (orderData['total'] as num?)?.toDouble() ?? 0.0;
                    final deliveryType = orderData['deliveryType']?.toString() ?? 'Recoger';
                    final itemsCount = (orderData['items'] as List?)?.length ?? 0;

                    final isFinalized = status == 'delivered';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pedido #${orderDoc.id.substring(0, 8)}', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                Chip(label: Text(_translateStatus(status))),
                              ],
                            ),
                            const Divider(),
                            Text('Artículos: $itemsCount · Tipo: $deliveryType'),
                            Text('Total: \$${total.toStringAsFixed(2)} MXN', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (!isFinalized)
                              ElevatedButton(
                                onPressed: () => _updateOrderStatus(context, orderDoc, status),
                                child: Text(_nextStatusLabel(status)),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
