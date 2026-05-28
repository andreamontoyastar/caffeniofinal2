import 'package:caffenio/core/constants/route_constants.dart';
import 'package:caffenio/core/theme/app_colors.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/core/theme/app_typography.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de confirmación de pedido con animación de éxito.
///
/// Recibe el [OrderModel] confirmado via `GoRouterState.extra` y
/// muestra el número de folio, tipo de entrega, tiempo estimado y
/// opciones para navegar al inicio o al historial de pedidos.
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({required this.order, super.key});

  final OrderModel order;

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Iniciar animación al mostrar la pantalla
    Future.microtask(() => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return PopScope(
      canPop: false, // Evitar que el usuario regrese al checkout
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // ── Ícono animado ─────────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [AppColors.successLight, AppColors.success],
                        radius: 0.8,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.35),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),

                const Gap(AppSpacing.xxl),

                // ── Textos animados ───────────────────────────────────────
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) => Opacity(
                    opacity: _fadeAnim.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnim.value),
                      child: child,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '¡Pedido Confirmado!',
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(AppSpacing.sm),
                      Text(
                        'Tu pedido ha sido recibido\ny está siendo preparado.',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Gap(AppSpacing.xxl),

                // ── Tarjeta de detalles ───────────────────────────────────
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) => Opacity(
                    opacity: _fadeAnim.value,
                    child: child,
                  ),
                  child: _OrderDetailsCard(order: order),
                ),

                const Spacer(),

                // ── Botones de acción ─────────────────────────────────────
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) => Opacity(
                    opacity: _fadeAnim.value,
                    child: child,
                  ),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.go(RouteConstants.home),
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Volver al Inicio'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                              double.infinity, AppSpacing.buttonHeight),
                        ),
                      ),
                      const Gap(AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/home/orders'),
                        icon: const Icon(Icons.history_outlined),
                        label: const Text('Ver mis Pedidos'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(
                              double.infinity, AppSpacing.buttonHeight),
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de detalles del pedido
// ─────────────────────────────────────────────────────────────────────────────

class _OrderDetailsCard extends StatelessWidget {
  const _OrderDetailsCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Folio
          Text(
            'Folio de Pedido',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(AppSpacing.xs),
          Text(
            order.displayId,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),

          // Detalles en grid
          Row(
            children: [
              const _DetailItem(
                icon: Icons.timer_outlined,
                label: 'Tiempo estimado',
                value: '~10 minutos',
              ),
              const Gap(AppSpacing.md),
              _DetailItem(
                icon: Icons.store_outlined,
                label: 'Tipo de entrega',
                value: order.deliveryType.label,
              ),
            ],
          ),

          const Gap(AppSpacing.sm),

          Row(
            children: [
              _DetailItem(
                icon: Icons.payment_outlined,
                label: 'Método de pago',
                value: order.paymentMethod.label,
              ),
              const Gap(AppSpacing.md),
              _DetailItem(
                icon: Icons.receipt_outlined,
                label: 'Total pagado',
                value: '\$${order.total.toStringAsFixed(2)}',
                valueColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
            const Gap(4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Gap(2),
            Text(
              value,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
