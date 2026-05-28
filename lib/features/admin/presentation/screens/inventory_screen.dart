import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/features/admin/domain/repositories/inventory_repository.dart';
import 'package:caffenio/shared/models/inventory_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late InventoryRepository _repository;
  String? selectedSucursal;

  @override
  void initState() {
    super.initState();
    _repository = sl<InventoryRepository>();
  }

  void _showAddEditDialog({InventoryModel? inventory}) {
    final ingredientCtrl =
        TextEditingController(text: inventory?.ingredientId ?? '');
    final currentStockCtrl =
        TextEditingController(text: (inventory?.currentStock ?? 0).toString());
    final minStockCtrl =
        TextEditingController(text: (inventory?.minStock ?? 0).toString());
    final unitCtrl = TextEditingController(text: inventory?.unit ?? 'kg');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            inventory == null ? 'Nuevo Item de Inventario' : 'Editar Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ingredientCtrl,
                decoration:
                    const InputDecoration(label: Text('ID Ingrediente')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: currentStockCtrl,
                decoration: const InputDecoration(label: Text('Stock Actual')),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: minStockCtrl,
                decoration: const InputDecoration(label: Text('Stock Mínimo')),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: unitCtrl,
                decoration:
                    const InputDecoration(label: Text('Unidad (kg, L, etc.)')),
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
              final ingredientId = ingredientCtrl.text.trim();
              final currentStock = double.tryParse(currentStockCtrl.text) ?? 0;
              final minStock = double.tryParse(minStockCtrl.text) ?? 0;
              final unit = unitCtrl.text.trim();

              if (ingredientId.isEmpty || selectedSucursal == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completa todos los campos')),
                );
                return;
              }

              final newItem = (inventory ??
                      InventoryModel(
                        id: const Uuid().v4(),
                        sucursalId: selectedSucursal!,
                        ingredientId: '',
                        currentStock: 0,
                        minStock: 0,
                        unit: '',
                        lastUpdated: DateTime.now(),
                      ))
                  .copyWith(
                ingredientId: ingredientId,
                currentStock: currentStock,
                minStock: minStock,
                unit: unit,
                lastUpdated: DateTime.now(),
              );

              try {
                if (inventory == null) {
                  await _repository.createInventory(newItem);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item creado')),
                    );
                  }
                } else {
                  await _repository.updateInventory(newItem);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item actualizado')),
                    );
                  }
                }
                if (mounted) Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text(inventory == null ? 'Crear' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Inventario'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Filtrar por sucursal ID...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) =>
                  setState(() => selectedSucursal = v.isEmpty ? null : v),
            ),
          ),
          Expanded(
            child: selectedSucursal == null
                ? const Center(child: Text('Selecciona una sucursal'))
                : StreamBuilder<List<InventoryModel>>(
                    stream: _repository.watchBySucursal(selectedSucursal!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final items = snapshot.data ?? [];

                      if (items.isEmpty) {
                        return const Center(
                            child: Text('Sin inventario para esta sucursal'));
                      }

                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (ctx, i) {
                          final item = items[i];
                          final isLow = item.currentStock < item.minStock;
                          return Card(
                            margin: const EdgeInsets.all(8),
                            color: isLow ? Colors.red.shade50 : null,
                            child: ListTile(
                              title: Text(item.ingredientId),
                              subtitle: Text(
                                'Stock: ${item.currentStock.toStringAsFixed(2)} ${item.unit} (Mín: ${item.minStock.toStringAsFixed(2)})',
                                style: TextStyle(
                                  color: isLow ? Colors.red : Colors.green,
                                  fontWeight: isLow
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (ctx) => [
                                  PopupMenuItem(
                                    child: const Text('Editar'),
                                    onTap: () =>
                                        _showAddEditDialog(inventory: item),
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Eliminar'),
                                    onTap: () async {
                                      await _repository
                                          .deleteInventory(item.id);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('Item eliminado')),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectedSucursal == null ? null : () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
