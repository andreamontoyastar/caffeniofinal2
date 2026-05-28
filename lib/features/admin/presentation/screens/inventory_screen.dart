import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/features/admin/domain/repositories/inventory_repository.dart';
import 'package:caffenio/shared/models/inventory_model.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<SucursalModel> _sucursales = [];
  bool _isLoadingSucursales = true;

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
    _repository = sl<InventoryRepository>();
    _loadSucursales();
  }

  Future<void> _loadSucursales() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(FirebaseConstants.sucursalesCollection)
          .get();
      if (mounted) {
        setState(() {
          _sucursales = snap.docs
              .map((d) => SucursalModel.fromFirestore(d))
              .where((s) => s.isActive)
              .toList();
          if (_sucursales.isNotEmpty) {
            selectedSucursal = _sucursales.first.id;
          }
          _isLoadingSucursales = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingSucursales = false);
      }
    }
  }

  String _getIngredientDisplayName(String ingredientId) {
    return predefinedIngredients[ingredientId]?['name'] ?? ingredientId;
  }

  void _showAddEditDialog({InventoryModel? inventory}) {
    final formKey = GlobalKey<FormState>();
    
    String selectedIngId = inventory?.ingredientId ?? predefinedIngredients.keys.first;
    final currentStockCtrl =
        TextEditingController(text: (inventory?.currentStock ?? 0.0).toString());
    final minStockCtrl =
        TextEditingController(text: (inventory?.minStock ?? 0.0).toString());
    final unitCtrl = TextEditingController(
        text: inventory?.unit ?? predefinedIngredients[selectedIngId]?['unit'] ?? 'kg');

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
              inventory == null ? 'Nuevo Item de Inventario' : 'Editar Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                          final newUnit = predefinedIngredients[val]?['unit'] ?? 'kg';
                          unitCtrl.text = newUnit;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: currentStockCtrl,
                    decoration: const InputDecoration(labelText: 'Stock Actual'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (v == null || double.tryParse(v) == null)
                        ? 'Ingrese un número válido'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: minStockCtrl,
                    decoration: const InputDecoration(labelText: 'Stock Mínimo'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (v == null || double.tryParse(v) == null)
                        ? 'Ingrese un número válido'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: unitCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Unidad (kg, L, etc.)'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingrese la unidad de medida'
                        : null,
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

                final currentStock = double.tryParse(currentStockCtrl.text) ?? 0.0;
                final minStock = double.tryParse(minStockCtrl.text) ?? 0.0;
                final unit = unitCtrl.text.trim();

                if (selectedSucursal == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seleccione una sucursal primero')),
                  );
                  return;
                }

                final newItem = (inventory ??
                        InventoryModel(
                          id: const Uuid().v4(),
                          sucursalId: selectedSucursal!,
                          ingredientId: selectedIngId,
                          currentStock: currentStock,
                          minStock: minStock,
                          unit: unit,
                          lastUpdated: DateTime.now(),
                        ))
                    .copyWith(
                  ingredientId: selectedIngId,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Inventario'),
      ),
      body: _isLoadingSucursales
          ? const Center(child: CircularProgressIndicator())
          : _sucursales.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No hay sucursales activas. Agregue una sucursal primero en la sección de Sucursales.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedSucursal,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por Sucursal',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.store),
                        ),
                        items: _sucursales.map((s) {
                          return DropdownMenuItem<String>(
                            value: s.id,
                            child: Text(s.name),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedSucursal = v;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: selectedSucursal == null
                          ? const Center(child: Text('Seleccione una sucursal'))
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
                                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      color: isLow ? Colors.red.shade50 : null,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: isLow ? Colors.red.shade100 : Colors.green.shade100,
                                          child: Icon(
                                            isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                                            color: isLow ? Colors.red : Colors.green,
                                          ),
                                        ),
                                        title: Text(
                                          _getIngredientDisplayName(item.ingredientId),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          'Stock: ${item.currentStock.toStringAsFixed(2)} ${item.unit} (Mín: ${item.minStock.toStringAsFixed(2)})',
                                          style: TextStyle(
                                            color: isLow ? Colors.red : Colors.green,
                                            fontWeight: isLow
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        trailing: PopupMenuButton<String>(
                                          onSelected: (val) async {
                                            if (val == 'edit') {
                                              _showAddEditDialog(inventory: item);
                                            } else if (val == 'delete') {
                                              try {
                                                await _repository.deleteInventory(item.id);
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Item eliminado')),
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Error al eliminar: $e')),
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
                    ),
                  ],
                ),
      floatingActionButton: selectedSucursal == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddEditDialog(),
              child: const Icon(Icons.add),
            ),
    );
  }
}
