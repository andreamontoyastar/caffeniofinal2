import 'package:caffenio/core/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administrador', style: theme.textTheme.titleLarge),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        childAspectRatio: 3 / 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildDashboardCard(
            context,
            icon: Icons.fastfood,
            label: 'Productos',
            onTap: () => context.push(RouteConstants.adminProducts),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.category,
            label: 'Categorías',
            onTap: () => context.push(RouteConstants.adminCategories),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.store,
            label: 'Sucursales',
            onTap: () => context.push(RouteConstants.adminSucursales),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.group,
            label: 'Proveedores',
            onTap: () => context.push(RouteConstants.adminSuppliers),
          ),
          _buildDashboardCard(
            context,
            icon: Icons.receipt,
            label: 'Órdenes de Compra',
            onTap: () => context.push(RouteConstants.adminPurchaseOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
