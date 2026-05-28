import 'package:caffenio/core/theme/app_colors.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/core/theme/app_typography.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:caffenio/features/cart/presentation/providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Pantalla Home — placeholder hasta Fase 4 (navegación + módulos).
///
/// Muestra información del usuario autenticado y permite cerrar sesión.
/// Se reemplazará por el shell de navegación completo en la siguiente fase.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showCatalogsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    tabs: [
                      Tab(icon: Icon(Icons.store), text: 'Sucursales'),
                      Tab(icon: Icon(Icons.local_offer), text: 'Promociones'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: Sucursales
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection('branches').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final docs = snapshot.data!.docs;
                            if (docs.isEmpty) {
                              return const Center(child: Text('No hay sucursales disponibles.'));
                            }
                            return ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data = docs[index].data();
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: AppColors.primaryContainer,
                                      child: Icon(Icons.store, color: AppColors.primary),
                                    ),
                                    title: Text(data['name']?.toString() ?? 'Sucursal', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${data['address'] ?? ''}, ${data['city'] ?? ''}\nHorario: ${data['schedule'] ?? ''}'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        // Tab 2: Promociones
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection('promotions').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final docs = snapshot.data!.docs;
                            if (docs.isEmpty) {
                              return const Center(child: Text('No hay promociones activas.'));
                            }
                            return ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data = docs[index].data();
                                final code = data['code'] ?? 'GENERAL';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.orange.withValues(alpha: 0.15),
                                      child: const Icon(Icons.local_offer, color: Colors.orange),
                                    ),
                                    title: Text(data['title']?.toString() ?? 'Promoción', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${data['description'] ?? ''}\nCódigo: $code'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Caffenio'),
        actions: [
          // Badge del carrito
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                tooltip: 'Ver carrito',
                onPressed: () => context.push('/cart'),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartCount',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Cerrar sesión',
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  user?.initials ?? '?',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Gap(AppSpacing.lg),

              // Nombre
              Text(
                '¡Hola, ${user?.displayNameOrEmail ?? 'Usuario'}! ☕',
                style: AppTypography.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const Gap(AppSpacing.sm),

              // Email
              Text(
                user?.email ?? '',
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(AppSpacing.sm),

              // Rol
              Container(
                padding: AppSpacing.chipPadding,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Text(
                  user?.role.toUpperCase() ?? '',
                  style: AppTypography.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Gap(AppSpacing.xxl),
              ElevatedButton.icon(
                onPressed: () => context.push('/home/catalog'),
                icon: Icon(Icons.coffee, color: Theme.of(context).colorScheme.onPrimary),
                label: const Text('Ver Menú y Personalizar'),
              ),
              const Gap(AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => _showCatalogsBottomSheet(context),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Ver Sucursales y Promociones'),
              ),
              const Gap(AppSpacing.lg),

              // Próximamente
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    const Text('🚀', style: TextStyle(fontSize: 36)),
                    const Gap(AppSpacing.sm),
                    Text(
                      'Módulos en desarrollo',
                      style: AppTypography.titleMedium,
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      'Catálogo, carrito, pedidos y lealtad\nse añadirán en las siguientes fases.',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
