import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/constants/route_constants.dart';
import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/core/theme/app_border_radius.dart';
import 'package:caffenio/core/theme/app_colors.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/features/admin/presentation/screens/employees_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/extra_tables_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/inventory_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/manage_orders_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/promotions_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/purchase_orders_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/sucursales_screen.dart';
import 'package:caffenio/features/admin/presentation/screens/suppliers_screen.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:caffenio/features/notifications/data/notifications_remote_datasource.dart';
import 'package:caffenio/features/settings/presentation/providers/settings_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Widget _buildMetricCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.mdAll),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _calculateDailyMetrics() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection(FirebaseConstants.ordersCollection)
        .where(FirebaseConstants.fieldCreatedAt,
            isGreaterThanOrEqualTo: startOfDay)
        .where(FirebaseConstants.fieldCreatedAt, isLessThanOrEqualTo: endOfDay)
        .get();

    final int orderCount = snapshot.docs.length;
    double totalRevenue = 0.0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final total =
          (data[FirebaseConstants.fieldOrderTotal] as num?)?.toDouble() ?? 0.0;
      totalRevenue += total;
    }

    return {
      'orderCount': orderCount,
      'totalRevenue': totalRevenue,
    };
  }

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
        return 'Marcar como En Preparación';
      case 'preparing':
        return 'Marcar como Listo';
      case 'ready':
        return 'Marcar como Entregado';
      default:
        return 'Actualizar estado';
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

    // Enviar notificación al usuario del cambio de estado
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
      } catch (e) {
        debugPrint('Error sending status notification: $e');
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Pedido ${orderDoc.id} actualizado a ${_translateStatus(nextStatus)}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Consola Administrativa',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<SettingsProvider>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: 'Cambiar tema',
            onPressed: () {
              final sp = context.read<SettingsProvider>();
              sp.toggleTheme(sp.themeMode != ThemeMode.dark);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar métricas',
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('MÉTRICAS EN TIEMPO REAL',
                style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder<Map<String, dynamic>>(
            future: _calculateDailyMetrics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: [
                    _buildMetricCard(context, 'Pedidos del Día', 'Cargando...',
                        Icons.receipt_long, theme.colorScheme.primary),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMetricCard(context, 'Ingresos Totales', 'Cargando...',
                        Icons.attach_money, theme.colorScheme.secondary),
                  ],
                );
              }

              if (snapshot.hasError) {
                return Column(
                  children: [
                    _buildMetricCard(context, 'Pedidos del Día', 'Error',
                        Icons.receipt_long, theme.colorScheme.primary),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMetricCard(context, 'Ingresos Totales', 'Error',
                        Icons.attach_money, theme.colorScheme.secondary),
                  ],
                );
              }

              final data =
                  snapshot.data ?? {'orderCount': 0, 'totalRevenue': 0.0};
              final orderCount = data['orderCount'] as int? ?? 0;
              final totalRevenue = data['totalRevenue'] as double? ?? 0.0;

              return Column(
                children: [
                  _buildMetricCard(
                      context,
                      'Pedidos del Día',
                      '$orderCount órdenes',
                      Icons.receipt_long,
                      theme.colorScheme.primary),
                  const SizedBox(height: AppSpacing.sm),
                  _buildMetricCard(
                      context,
                      'Ingresos Totales',
                      '\$${totalRevenue.toStringAsFixed(2)} MXN',
                      Icons.attach_money,
                      theme.colorScheme.secondary),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('ACCIONES DE CONTROL',
              style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            leading: Icon(Icons.coffee, color: theme.colorScheme.primary),
            title: Text('Administrar Menú / CRUD Productos',
                style: theme.textTheme.bodyMedium),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              GoRouter.of(context).push(RouteConstants.adminProducts);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: AppColors.primary),
            title: const Text('Gestión de Pedidos (Realtime)', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => const ManageOrdersScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.inventory, color: theme.colorScheme.secondary),
            title: Text('Monitoreo de Stock por Ingredientes',
                style: theme.textTheme.bodyMedium),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => const InventoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            leading: const Icon(Icons.local_shipping, color: Colors.blueGrey),
            title: Text('Gestión de Proveedores',
                style: theme.textTheme.bodyMedium),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => const SuppliersScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.indigo),
            title: Text('Órdenes de Compra', style: theme.textTheme.bodyMedium),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => const PurchaseOrdersScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            leading: Icon(Icons.location_on, color: theme.colorScheme.tertiary),
            title: Text('Gestión de Sucursales',
                style: theme.textTheme.bodyMedium),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => const SucursalesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_offer, color: Colors.amber),
            title: Text('Gestión de Promociones',
                style: theme.textTheme.bodyMedium),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => const PromotionsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage, color: Colors.teal),
            title: Text('Gestión de Inventario',
                style: theme.textTheme.bodyMedium),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => const InventoryScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.green),
            title:
                Text('Gestión de Empleados', style: theme.textTheme.bodyMedium),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => const EmployeesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.indigo),
            title: const Text('Administrar Tablas Adicionales', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => const ExtraTablesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Pedidos en tiempo real',
              style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(FirebaseConstants.ordersCollection)
                .orderBy(FirebaseConstants.fieldCreatedAt, descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    'No se pudo cargar la lista de pedidos. Intenta de nuevo.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = snapshot.data?.docs ?? [];
              if (orders.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    'No hay pedidos activos en este momento.',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final orderDoc = orders[index];
                  final orderData = orderDoc.data();
                  final String status =
                      orderData[FirebaseConstants.fieldOrderStatus]
                              ?.toString() ??
                          'pending';
                  final Timestamp? timestamp =
                      orderData[FirebaseConstants.fieldCreatedAt] as Timestamp?;
                  final DateTime createdAt =
                      timestamp?.toDate() ?? DateTime.now();
                  final String dateLabel =
                      '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
                  final int itemsCount =
                      (orderData['items'] as List<dynamic>?)?.length ?? 0;
                  final double total =
                      (orderData[FirebaseConstants.fieldOrderTotal] as num?)
                              ?.toDouble() ??
                          0.0;
                  final String paymentMethod =
                      orderData[FirebaseConstants.fieldOrderPaymentMethod]
                              ?.toString() ??
                          'Sin método';
                  final String deliveryType =
                      orderData['deliveryType']?.toString() ??
                          'No especificado';
                  final String userId =
                      orderData[FirebaseConstants.fieldOrderUserId]
                              ?.toString() ??
                          'Anónimo';

                  final bool isFinalized = status == 'delivered';
                  final String buttonLabel = _nextStatusLabel(status);

                  return Card(
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.mdAll),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Pedido ${orderDoc.id}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(_translateStatus(status)),
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '$dateLabel · $itemsCount artículos · $paymentMethod',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Total: \$${total.toStringAsFixed(2)} • $deliveryType',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Usuario: $userId',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              if (!isFinalized)
                                ElevatedButton(
                                  onPressed: () => _updateOrderStatus(
                                    context,
                                    orderDoc,
                                    status,
                                  ),
                                  child: Text(buttonLabel),
                                ),
                              if (isFinalized)
                                Text(
                                  'Pedido completado',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            shape: const RoundedRectangleBorder(
                borderRadius: AppBorderRadius.mdAll),
            child: ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text('Cerrar Sesión',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold)),
              trailing:
                  Icon(Icons.chevron_right, color: theme.colorScheme.error),
              onTap: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  GoRouter.of(context).go('/auth/login');
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}
