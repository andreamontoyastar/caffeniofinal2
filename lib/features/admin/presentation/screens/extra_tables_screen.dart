import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/theme/app_colors.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/core/theme/app_typography.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ExtraTablesScreen extends StatefulWidget {
  const ExtraTablesScreen({super.key});

  @override
  State<ExtraTablesScreen> createState() => _ExtraTablesScreenState();
}

class _ExtraTablesScreenState extends State<ExtraTablesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablas de Base de Datos', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Clientes'),
            Tab(text: 'Lealtad'),
            Tab(text: 'Turnos'),
            Tab(text: 'Recetas'),
            Tab(text: 'Pagos'),
            Tab(text: 'Categorías'),
            Tab(text: 'Ingredientes'),
            Tab(text: 'Detalles Pedido'),
            Tab(text: 'Personalización'),
            Tab(text: 'Descuentos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClientsTab(theme),
          _buildLoyaltyTab(theme),
          _buildShiftsTab(theme),
          _buildRecipesTab(theme),
          _buildPaymentsTab(theme),
          _buildCategoriesTab(theme),
          _buildIngredientsTab(theme),
          _buildOrderDetailsTab(theme),
          _buildPersonalizationsTab(theme),
          _buildDiscountsTab(theme),
        ],
      ),
    );
  }

  Widget _buildClientsTab(ThemeData theme) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .where('role', isEqualTo: 'customer')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No hay clientes registrados.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['displayName']?.toString() ?? 'Sin Nombre', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(data['email']?.toString() ?? 'Sin Email'),
                trailing: Text(data['phone']?.toString() ?? 'Sin Teléfono', style: AppTypography.bodySmall),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoyaltyTab(ThemeData theme) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirebaseConstants.loyaltyCardsCollection)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No hay tarjetas de lealtad activas.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            return Card(
              child: ListTile(
                leading: const Icon(Icons.card_membership, color: AppColors.primary),
                title: Text('Usuario ID: ${docs[index].id}', style: AppTypography.bodySmall),
                subtitle: Text('Nivel: ${data['level']?.toString().toUpperCase() ?? 'BRONCE'}'),
                trailing: Text('${data['points'] ?? 0} Puntos', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShiftsTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ElevatedButton.icon(
            onPressed: () => _showAddShiftDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Nuevo Turno'),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('shifts').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No hay turnos registrados.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time, color: Colors.blue),
                      title: Text('Empleado: ${data['employeeName'] ?? 'Cajero'}', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Sucursal: ${data['sucursalName'] ?? 'Sucursal Central'}\nHorario: ${data['startHour'] ?? '08:00'} - ${data['endHour'] ?? '16:00'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => FirebaseFirestore.instance.collection('shifts').doc(docs[index].id).delete(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddShiftDialog() async {
    final nameCtrl = TextEditingController();
    final sucursalCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: '08:00');
    final endCtrl = TextEditingController(text: '16:00');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Asignar Turno'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre Empleado')),
              TextField(controller: sucursalCtrl, decoration: const InputDecoration(labelText: 'Sucursal')),
              Row(
                children: [
                  Expanded(child: TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Inicio'))),
                  const Gap(10),
                  Expanded(child: TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'Fin'))),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && sucursalCtrl.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('shifts').add({
                    'employeeName': nameCtrl.text,
                    'sucursalName': sucursalCtrl.text,
                    'startHour': startCtrl.text,
                    'endHour': endCtrl.text,
                    'date': DateTime.now().toIso8601String(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecipesTab(ThemeData theme) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirebaseConstants.recipesCollection)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No hay recetas registradas.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            return Card(
              child: ListTile(
                leading: const Icon(Icons.restaurant_menu, color: Colors.orange),
                title: Text('Producto ID: ${data['productId'] ?? 'N/A'}', style: AppTypography.bodySmall),
                subtitle: Text('Ingrediente: ${data['ingredientId'] ?? 'Café'}\nCantidad: ${data['cantidad'] ?? 1.0}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentsTab(ThemeData theme) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirebaseConstants.ordersCollection)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No hay transacciones registradas.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            return Card(
              child: ListTile(
                leading: const Icon(Icons.payment, color: Colors.teal),
                title: Text('Transacción ID: ${docs[index].id}', style: AppTypography.bodySmall),
                subtitle: Text('Método: ${data['paymentMethod']?.toString().toUpperCase() ?? 'EFECTIVO'}\nTotal: \$${data['total'] ?? 0.0} MXN'),
                trailing: Text(data['status']?.toString().toUpperCase() ?? 'PENDIENTE', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ElevatedButton.icon(
            onPressed: () => _showAddCategoryDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Categoría'),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No hay categorías registradas.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.category, color: Colors.purple),
                      title: Text(data['nombre']?.toString() ?? 'Sin Nombre', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Ingrediente Principal: ${data['higreinate'] ?? 'N/A'}\nUnidad: ${data['unidad'] ?? 'N/A'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => FirebaseFirestore.instance.collection('categories').doc(docs[index].id).delete(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final nombreCtrl = TextEditingController();
    final higreinateCtrl = TextEditingController();
    final unidadCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: higreinateCtrl, decoration: const InputDecoration(labelText: 'Ingrediente Principal (higreinate)')),
              TextField(controller: unidadCtrl, decoration: const InputDecoration(labelText: 'Unidad')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nombreCtrl.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('categories').add({
                    'nombre': nombreCtrl.text,
                    'higreinate': higreinateCtrl.text,
                    'unidad': unidadCtrl.text,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIngredientsTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ElevatedButton.icon(
            onPressed: () => _showAddIngredientDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Ingrediente'),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('ingredients').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No hay ingredientes registrados en esta tabla.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.egg, color: Colors.blueGrey),
                      title: Text(data['nombre']?.toString() ?? 'Sin Nombre', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Unidad: ${data['unidad'] ?? 'N/A'}\nStock: ${data['stock'] ?? 0.0}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => FirebaseFirestore.instance.collection('ingredients').doc(docs[index].id).delete(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddIngredientDialog() async {
    final nombreCtrl = TextEditingController();
    final unidadCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '0.0');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Ingrediente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: unidadCtrl, decoration: const InputDecoration(labelText: 'Unidad')),
              TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock Inicial')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nombreCtrl.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('ingredients').add({
                    'nombre': nombreCtrl.text,
                    'unidad': unidadCtrl.text,
                    'stock': double.tryParse(stockCtrl.text) ?? 0.0,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderDetailsTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ElevatedButton.icon(
            onPressed: () => _showAddOrderDetailDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Detalle de Pedido'),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('orderDetails').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No hay detalles de pedidos registrados.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.list_alt, color: Colors.teal),
                      title: Text('Detalle ID: ${docs[index].id}', style: AppTypography.bodySmall),
                      subtitle: Text('Pedido ID: ${data['pedido_id'] ?? 'N/A'}\nProducto ID: ${data['producto_id'] ?? 'N/A'}\nCantidad: ${data['cantidad'] ?? 1}\nPrecio Unitario: \$${data['precio_unitario'] ?? 0.0}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => FirebaseFirestore.instance.collection('orderDetails').doc(docs[index].id).delete(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddOrderDetailDialog() async {
    final pedidoCtrl = TextEditingController();
    final productoCtrl = TextEditingController();
    final cantidadCtrl = TextEditingController(text: '1');
    final precioCtrl = TextEditingController(text: '0.0');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Detalle de Pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: pedidoCtrl, decoration: const InputDecoration(labelText: 'ID Pedido')),
              TextField(controller: productoCtrl, decoration: const InputDecoration(labelText: 'ID Producto')),
              TextField(controller: cantidadCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad')),
              TextField(controller: precioCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Precio Unitario')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (pedidoCtrl.text.isNotEmpty && productoCtrl.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('orderDetails').add({
                    'pedido_id': pedidoCtrl.text,
                    'producto_id': productoCtrl.text,
                    'cantidad': int.tryParse(cantidadCtrl.text) ?? 1,
                    'precio_unitario': double.tryParse(precioCtrl.text) ?? 0.0,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonalizationsTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ElevatedButton.icon(
            onPressed: () => _showAddPersonalizationDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Personalización'),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('personalizations').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No hay personalizaciones registradas.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.tune, color: Colors.indigo),
                      title: Text('Detalle ID: ${data['detalle_id'] ?? 'N/A'}', style: AppTypography.bodySmall),
                      subtitle: Text('Opción: ${data['opcion'] ?? 'Sin Opción'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => FirebaseFirestore.instance.collection('personalizations').doc(docs[index].id).delete(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddPersonalizationDialog() async {
    final detalleCtrl = TextEditingController();
    final opcionCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Personalización'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: detalleCtrl, decoration: const InputDecoration(labelText: 'ID Detalle Pedido')),
              TextField(controller: opcionCtrl, decoration: const InputDecoration(labelText: 'Opción (Ej: Leche Soya, Extra Shot)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (detalleCtrl.text.isNotEmpty && opcionCtrl.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('personalizations').add({
                    'detalle_id': detalleCtrl.text,
                    'opcion': opcionCtrl.text,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiscountsTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ElevatedButton.icon(
            onPressed: () => _showAddDiscountDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Descuento'),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('discounts').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('No hay descuentos registrados.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.loyalty, color: Colors.redAccent),
                      title: Text(data['descripcion']?.toString() ?? 'Sin Descripción', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text('Descuento: ${data['porcentaje'] ?? 0}%\nValidez: ${data['fecha_inicio'] ?? 'N/A'} a ${data['fecha_fin'] ?? 'N/A'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => FirebaseFirestore.instance.collection('discounts').doc(docs[index].id).delete(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAddDiscountDialog() async {
    final descCtrl = TextEditingController();
    final porcCtrl = TextEditingController(text: '10');
    final inicioCtrl = TextEditingController(text: DateTime.now().toString().substring(0, 10));
    final finCtrl = TextEditingController(text: DateTime.now().add(const Duration(days: 7)).toString().substring(0, 10));

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuevo Descuento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción')),
              TextField(controller: porcCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Porcentaje')),
              TextField(controller: inicioCtrl, decoration: const InputDecoration(labelText: 'Fecha Inicio (AAAA-MM-DD)')),
              TextField(controller: finCtrl, decoration: const InputDecoration(labelText: 'Fecha Fin (AAAA-MM-DD)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (descCtrl.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('discounts').add({
                    'descripcion': descCtrl.text,
                    'porcentaje': int.tryParse(porcCtrl.text) ?? 10,
                    'fecha_inicio': inicioCtrl.text,
                    'fecha_fin': finCtrl.text,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

