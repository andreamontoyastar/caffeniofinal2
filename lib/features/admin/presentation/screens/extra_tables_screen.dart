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
    _tabController = TabController(length: 5, vsync: this);
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
}
