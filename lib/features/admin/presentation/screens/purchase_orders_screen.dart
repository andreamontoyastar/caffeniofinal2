import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/features/admin/domain/repositories/purchase_order_repository.dart';
import 'package:caffenio/shared/models/purchase_order_detail_model.dart';
import 'package:caffenio/shared/models/purchase_order_model.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';
import 'package:caffenio/shared/models/supplier_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  late PurchaseOrderRepository _repository;
  List<SucursalModel> _sucursales = [];
  List<SupplierModel> _suppliers = [];
  bool _isLoadingDropdowns = true;

  static const Map<String, Map<String, String>> predefinedIngredients = {
    'cafe_granos': {'name': 'Café en Grano', 'unit': 'kg'},
    'leche_regular': {'name': 'Leche Regular', 'unit': 'L'},
    'jarabe_caramelo': {'name': 'Jarabe de Caramelo', 'unit': 'L'},
    'chocolate': {'name': 'Chocolate en Polvo', 'unit': 'kg'},
    'vaso': {'name': 'Vasos Caffenio', 'unit': 'piezas'},
  };

  @override
  void initState() {
    super.initState();
    _repository = sl<PurchaseOrderRepository>();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final branchesSnap = await FirebaseFirestore.instance
          .collection(FirebaseConstants.sucursalesCollection)
          .get();
      final suppliersSnap = await FirebaseFirestore.instance
          .collection(FirebaseConstants.suppliersCollection)
          .get();
      if (mounted) {
        setState(() {
          _sucursales = branchesSnap.docs
              .map((d) => SucursalModel.fromFirestore(d))
              .where((s) => s.isActive)
              .toList();
          _suppliers = suppliersSnap.docs
              .map((d) => SupplierModel.fromFirestore(d))
              .where((s) => s.isActive)
              .toList();
          _isLoadingDropdowns = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingDropdowns = false);
      }
    }
  }

  String _getSucursalName(String id) {
    final s = _sucursales.where((x) => x.id == id).firstOrNull;
    return s?.name ?? id;
  }

  String _getSupplierName(String id) {
    final s = _suppliers.where((x) => x.id == id).firstOrNull;
    return s?.name ?? id;
  }

  String _getIngredientDisplayName(String ingredientId) {
    return predefinedIngredients[ingredientId]?['name'] ?? ingredientId;
  }

  void _showAddEditDialog({PurchaseOrderModel? order}) {
    final formKey = GlobalKey<FormState>();

    String? selectedSupplierId = order?.supplierId ?? (_suppliers.isNotEmpty ? _suppliers.first.id : null);
    String? selectedSucursalId = order?.sucursalId ?? (_sucursales.isNotEmpty ? _sucursales.first.id : null);
    String selectedIngId = order?.details.firstOrNull?.ingredientId ?? predefinedIngredients.keys.first;

    final quantityCtrl = TextEditingController(
        text: order?.details.firstOrNull?.quantity.toString() ?? '10.0');
    final priceCtrl = TextEditingController(
        text: order?.details.firstOrNull?.unitPrice.toString() ?? '50.0');
    
    String status = order?.status ?? 'pending';
    DateTime orderDate = order?.date ?? DateTime.now();

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(order == null ? 'Nueva Orden de Compra' : 'Editar Orden'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedSupplierId,
                    decoration: const InputDecoration(labelText: 'Proveedor'),
                    items: _suppliers.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(s.name),
                      );
                    }).toList(),
                    validator: (v) => v == null ? 'Seleccione un proveedor' : null,
                    onChanged: (val) {
                      setDialogState(() {
                        selectedSupplierId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSucursalId,
                    decoration: const InputDecoration(labelText: 'Sucursal Destino'),
                    items: _sucursales.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(s.name),
                      );
                    }).toList(),
                    validator: (v) => v == null ? 'Seleccione una sucursal' : null,
                    onChanged: (val) {
                      setDialogState(() {
                        selectedSucursalId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('PENDIENTE'),
                      ),
                      DropdownMenuItem(
                        value: 'received',
                        child: Text('RECIBIDO'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelled',
                        child: Text('CANCELADO'),
                      ),
                    ],
                    onChanged: (value) => setDialogState(() {
                      status = value ?? 'pending';
                    }),
                    decoration: const InputDecoration(labelText: 'Estado'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedIngId,
                    decoration: const InputDecoration(labelText: 'Ingrediente'),
                    items: predefinedIngredients.entries.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value['name']!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedIngId = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: quantityCtrl,
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (v == null || double.tryParse(v) == null)
                        ? 'Ingrese una cantidad válida'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: 'Precio Unitario (MXN)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (v == null || double.tryParse(v) == null)
                        ? 'Ingrese un precio válido'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Fecha: ${orderDate.day}/${orderDate.month}/${orderDate.year}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: orderDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              orderDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: const Text('Cambiar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (selectedSupplierId == null || selectedSucursalId == null) return;

                final quantity = double.tryParse(quantityCtrl.text) ?? 0.0;
                final unitPrice = double.tryParse(priceCtrl.text) ?? 0.0;

                final id = order?.id ?? const Uuid().v4();
                final detailId = order?.details.firstOrNull?.id ?? const Uuid().v4();
                final orderModel = PurchaseOrderModel(
                  id: id,
                  supplierId: selectedSupplierId!,
                  sucursalId: selectedSucursalId!,
                  date: orderDate,
                  status: status,
                  details: [
                    PurchaseOrderDetailModel(
                      id: detailId,
                      orderId: id,
                      ingredientId: selectedIngId,
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

  Color _getStatusColor(String status) => switch (status) {
        'received' => Colors.green,
        'cancelled' => Colors.red,
        _ => Colors.orange,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Compra'),
      ),
      body: _isLoadingDropdowns
          ? const Center(child: CircularProgressIndicator())
          : _suppliers.isEmpty || _sucursales.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Se requiere al menos una sucursal y un proveedor activo para crear órdenes de compra.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : StreamBuilder<List<PurchaseOrderModel>>(
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
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(order.status).withValues(alpha: 0.1),
                              child: Icon(
                                order.status == 'received'
                                    ? Icons.check_circle_rounded
                                    : order.status == 'cancelled'
                                        ? Icons.cancel_rounded
                                        : Icons.hourglass_empty_rounded,
                                color: _getStatusColor(order.status),
                              ),
                            ),
                            title: Text(
                              'Orden a ${_getSupplierName(order.supplierId)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sucursal destino: ${_getSucursalName(order.sucursalId)}'),
                                  Text('Fecha de emisión: $dateLabel'),
                                  if (detail != null) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${_getIngredientDisplayName(detail.ingredientId)}: ${detail.quantity} unidades a \$${detail.unitPrice.toStringAsFixed(2)} c/u',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              onSelected: (val) async {
                                if (val == 'edit') {
                                  _showAddEditDialog(order: order);
                                } else if (val == 'delete') {
                                  try {
                                    await _repository.deletePurchaseOrder(order.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Orden eliminada')),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Eliminar'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: _suppliers.isEmpty || _sucursales.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddEditDialog(),
              child: const Icon(Icons.add),
            ),
    );
  }
}
