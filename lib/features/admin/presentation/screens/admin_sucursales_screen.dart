import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/constants/route_constants.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminSucursalesScreen extends StatelessWidget {
  const AdminSucursalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sucursales', style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push(RouteConstants.adminSucursalesCreate);
            },
            tooltip: 'Agregar sucursal',
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(FirebaseConstants.sucursalesCollection).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar las sucursales.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            );
          }

          final sucursales = snapshot.data!.docs.map((doc) {
            return SucursalModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
          }).toList();

          if (sucursales.isEmpty) {
            return const Center(
              child: Text('No hay sucursales. Agrega una nueva.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sucursales.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final sucursal = sucursales[index];
              return _buildSucursalTile(context, sucursal);
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SucursalModel sucursal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar sucursal'),
        content: Text(
            '¿Eliminar "${sucursal.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await FirebaseFirestore.instance.collection(FirebaseConstants.sucursalesCollection).doc(sucursal.id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${sucursal.name}" eliminada.')),
        );
      }
    }
  }

  Widget _buildSucursalTile(
    BuildContext context,
    SucursalModel sucursal,
  ) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        title: Text(sucursal.name, style: theme.textTheme.titleMedium),
        subtitle: Text(sucursal.address, style: theme.textTheme.bodyMedium),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                context.push(
                  RouteConstants.adminSucursalesEdit
                      .replaceFirst(':sucursalId', sucursal.id),
                );
                break;
              case 'delete':
                _confirmDelete(context, sucursal);
                break;
            }
          },
          itemBuilder: (ctx) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}
