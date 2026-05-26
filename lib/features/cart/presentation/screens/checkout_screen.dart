import 'package:caffenio/core/constants/app_constants.dart';
import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/core/theme/app_colors.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/core/theme/app_typography.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:caffenio/features/cart/presentation/providers/cart_provider.dart';
import 'package:caffenio/features/loyalty/domain/usecases/update_loyalty_points.dart';
import 'package:caffenio/features/notifications/data/notifications_remote_datasource.dart';
import 'package:caffenio/features/orders/domain/usecases/place_order.dart';
import 'package:caffenio/features/orders/presentation/providers/order_provider.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Pantalla de checkout.
///
/// Muestra el resumen del pedido, permite elegir método de entrega
/// y método de pago, y confirma el pedido invocando [OrderProvider.placeOrder].
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DeliveryType _deliveryType = DeliveryType.toGo;
  PaymentMethod _paymentMethod = PaymentMethod.card;
  String? _selectedBranchId;
  bool _isProcessing = false;

  static const double _taxRate = 0.16;

  Future<void> _confirmOrder(BuildContext context) async {
    if (_deliveryType == DeliveryType.toGo && _selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una sucursal para recoger.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isProcessing = true);

    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();
    final router = GoRouter.of(context);

    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final order = orderProvider.placeOrder(
      items: cart.items,
      subtotal: cart.subtotal,
      deliveryType: _deliveryType,
      paymentMethod: _paymentMethod,
      userId: authProvider.currentUser?.uid,
      branchId: _selectedBranchId,
    );

    final userId = authProvider.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para confirmar el pedido.'),
          ),
        );
      }
      setState(() => _isProcessing = false);
      return;
    }

    final int pointsEarned = (order.total * AppConstants.pointsPerPeso).floor();
    final OrderModel orderToSave =
        order.copyWith(userId: userId, pointsEarned: pointsEarned);

    await sl<PlaceOrder>().call(orderToSave);
    await sl<UpdateLoyaltyPoints>().call(
      uid: userId,
      pointsEarned: pointsEarned,
    );
    await sl<NotificationsRemoteDataSource>().sendToUser(
      uid: userId,
      title: 'Pedido confirmado',
      body:
          'Tu pedido ${orderToSave.displayId} fue recibido. Ganaste $pointsEarned puntos.',
      type: 'order',
      orderId: orderToSave.id,
    );

    cart.clearCart();

    setState(() => _isProcessing = false);

    router.go('/cart/confirmation', extra: orderToSave);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final double tax = cart.subtotal * _taxRate;
    final double total = cart.subtotal + tax;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Confirmar Pedido'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: 'Resumen del Pedido',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  ...cart.items.map((item) => Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.quantity}x ${item.product.name}',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    item.selectedSize.name +
                                        (item.selectedMilk != null
                                            ? ' · ${item.selectedMilk!.name}'
                                            : ''),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: AppSpacing.lg),
                  _CheckoutPriceRow(label: 'Subtotal', value: cart.subtotal),
                  const Gap(AppSpacing.xs),
                  _CheckoutPriceRow(
                    label: 'IVA (16%)',
                    value: tax,
                    valueColor: AppColors.onSurfaceVariant,
                  ),
                  const Gap(AppSpacing.xs),
                  _CheckoutPriceRow(
                    label: 'Total',
                    value: total,
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const Gap(AppSpacing.md),

            _SectionCard(
              title: 'Tipo de Entrega',
              icon: Icons.store_outlined,
              child: Column(
                children: [
                  Row(
                    children: DeliveryType.values.map((type) {
                      final selected = _deliveryType == type;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _deliveryType = type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primaryContainer
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    type == DeliveryType.inStore
                                        ? Icons.store
                                        : Icons.takeout_dining_outlined,
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                    size: 28,
                                  ),
                                  const Gap(AppSpacing.xs),
                                  Text(
                                    type.label,
                                    style: AppTypography.labelMedium.copyWith(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.onSurfaceVariant,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_deliveryType == DeliveryType.toGo)
                    _BranchSelector(
                      onChanged: (branchId) {
                        setState(() => _selectedBranchId = branchId);
                      },
                    ),
                ],
              ),
            ),

            const Gap(AppSpacing.md),

            _SectionCard(
              title: 'Método de Pago',
              icon: Icons.payment_outlined,
              child: Column(
                children: PaymentMethod.values.map((method) {
                  final selected = _paymentMethod == method;
                  final IconData icon = switch (method) {
                    PaymentMethod.cash => Icons.money_outlined,
                    PaymentMethod.card => Icons.credit_card_outlined,
                    PaymentMethod.wallet =>
                      Icons.account_balance_wallet_outlined,
                  };
                  return GestureDetector(
                    onTap: () => setState(() => _paymentMethod = method),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryContainer
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              selected ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            color: selected
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
                          ),
                          const Gap(AppSpacing.md),
                          Text(
                            method.label,
                            style: AppTypography.bodyMedium.copyWith(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          if (selected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Gap(AppSpacing.xxl),

            ElevatedButton(
              onPressed: _isProcessing ? null : () => _confirmOrder(context),
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, AppSpacing.buttonHeight),
              ),
              child: _isProcessing
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Confirmar Pedido'),
            ),

            const Gap(AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _BranchSelector extends StatelessWidget {
  const _BranchSelector({required this.onChanged});

  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sucursales').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final branches = snapshot.data!.docs.map((doc) {
          return SucursalModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
        }).toList();

        return DropdownButtonFormField<String>(
          onChanged: onChanged,
          hint: const Text('Selecciona una sucursal'),
          items: branches.map((branch) {
            return DropdownMenuItem(value: branch.id, child: Text(branch.name));
          }).toList(),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const Gap(AppSpacing.sm),
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _CheckoutPriceRow extends StatelessWidget {
  const _CheckoutPriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        isTotal ? AppTypography.titleSmall : AppTypography.bodySmall;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style.copyWith(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal,
            color: isTotal ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: style.copyWith(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal,
            color: valueColor ??
                (isTotal ? AppColors.primary : AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}
