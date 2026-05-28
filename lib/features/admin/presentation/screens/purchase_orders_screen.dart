import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/features/admin/domain/repositories/purchase_order_repository.dart';
import 'package:caffenio/shared/models/purchase_order_detail_model.dart';
import 'package:caffenio/shared/models/purchase_order_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  late PurchaseOrderRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = sl<PurchaseOrderRepository>();
  }

  void _showAddEditDialog({PurchaseOrderModel? order}) {
    final supplierCtrl = TextEditingController(text: order?.supplierId ?? '');
    final sucursalCtrl = TextEditingController(text: order?.sucursalId ?? '');
    final ingredientCtrl =
        TextEditingController(text: order?.details.first.ingredientId ?? '');
    final quantityCtrl = TextEditingController(
        text: order?.details.first.quantity.toString() ?? '0');
    final priceCtrl = TextEditingController(
        text: order?.details.first.unitPrice.toString() ?? '0');
    String status = order?.status ?? 'pending';
    DateTime orderDate = order?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(order == null ? 'Nueva Orden de Compra' : 'Editar Orden'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: supplierCtrl,
                  decoration:
                      const InputDecoration(label: Text('ID Proveedor')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sucursalCtrl,
                  decoration: const InputDecoration(label: Text('ID Sucursal')),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  items: ['pending', 'received', 'cancelled']
                      .map((state) => DropdownMenuItem(
                            value: state,
                            child: Text(state.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    status = value ?? 'pending';
                  }),
                  decoration: const InputDecoration(label: Text('Estado')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ingredientCtrl,
                  decoration:
                      const InputDecoration(label: Text('ID Ingrediente')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityCtrl,
                  decoration: const InputDecoration(label: Text('Cantidad')),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  decoration:
                      const InputDecoration(label: Text('Precio unitario')),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Text(
                    'Fecha de orden: ${orderDate.toLocal().toString().split(' ')[0]}'),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: orderDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        orderDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Cambiar fecha'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final supplierId = supplierCtrl.text.trim();
                final sucursalId = sucursalCtrl.text.trim();
                final ingredientId = ingredientCtrl.text.trim();
                final quantity = double.tryParse(quantityCtrl.text) ?? 0;
                final unitPrice = double.tryParse(priceCtrl.text) ?? 0;

                if (supplierId.isEmpty ||
                    sucursalId.isEmpty ||
                    ingredientId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Completa los campos requeridos')),
                  );
                  return;
                }

                final id = order?.id ?? const Uuid().v4();
                final detailId = order?.details.first.id ?? const Uuid().v4();
                final orderModel = PurchaseOrderModel(
                  id: id,
                  supplierId: supplierId,
                  sucursalId: sucursalId,
                  date: orderDate,
                  status: status,
                  details: [
                    PurchaseOrderDetailModel(
                      id: detailId,
                      orderId: id,
                      ingredientId: ingredientId,
                      quantity: quantity,
                      unitPrice: unitPrice,
                    ),
                  ],
                  createdAt: order?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                try {
                  if (order == null) {
                    await _repository.createPurchaseOrder(orderModel);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Orden creada')),
                      );
                    }
                  } else {
                    await _repository.updatePurchaseOrder(orderModel);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Orden actualizada')),
                      );
                    }
                  }
                  if (mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(order == null ? 'Crear' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Compra'),
      ),
      body: StreamBuilder<List<PurchaseOrderModel>>(
        stream: _repository.watchAllPurchaseOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text('No hay órdenes de compra. Crea una nueva.'),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (ctx, index) {
              final order = orders[index];
              final detail =
                  order.details.isNotEmpty ? order.details.first : null;
              final dateLabel =
                  '${order.date.day.toString().padLeft(2, '0')}/${order.date.month.toString().padLeft(2, '0')}/${order.date.year}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('Orden ${order.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Proveedor: ${order.supplierId}'),
                      Text('Sucursal: ${order.sucursalId}'),
                      Text('Estado: ${order.status}'),
                      Text('Fecha: $dateLabel'),
                      if (detail != null)
                        Text(
                            'Detalle: ${detail.ingredientId} · ${detail.quantity} · ${detail.unitPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton(
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        child: const Text('Editar'),
                        onTap: () => _showAddEditDialog(order: order),
                      ),
                      PopupMenuItem(
                        child: const Text('Eliminar'),
                        onTap: () async {
                          await _repository.deletePurchaseOrder(order.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Orden eliminada')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
