import 'dart:math';

import 'package:caffenio/core/constants/app_constants.dart';
import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/core/theme/app_typography.dart';
import 'package:caffenio/features/admin/domain/usecases/sucursal_usecases.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:caffenio/features/cart/presentation/providers/cart_provider.dart';
import 'package:caffenio/features/loyalty/data/models/loyalty_card_model.dart';
import 'package:caffenio/features/loyalty/domain/usecases/get_loyalty_card.dart';
import 'package:caffenio/features/loyalty/domain/usecases/update_loyalty_points.dart';
import 'package:caffenio/features/notifications/data/notifications_remote_datasource.dart';
import 'package:caffenio/features/orders/domain/usecases/place_order.dart';
import 'package:caffenio/features/orders/presentation/providers/order_provider.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:caffenio/shared/models/sucursal_model.dart';
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
  DeliveryType _deliveryType = DeliveryType.pickup;
  PaymentMethod _paymentMethod = PaymentMethod.card;
  bool _isProcessing = false;
  String? _selectedBranchId;
  int _userPoints = 0;

  final _addressController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  static const double _taxRate = 0.16;

  @override
  void dispose() {
    _addressController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder(BuildContext context) async {
    if (_deliveryType == DeliveryType.delivery && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu dirección de entrega.')),
      );
      return;
    }
    if (_deliveryType == DeliveryType.pickup && (_selectedBranchId == null || _selectedBranchId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una sucursal para recoger tu pedido.')),
      );
      return;
    }
    if (_paymentMethod == PaymentMethod.card &&
        (_cardNumberController.text.trim().isEmpty ||
         _cardExpiryController.text.trim().isEmpty ||
         _cardCvvController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa los datos de tu tarjeta.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Capturar providers y router ANTES del await para evitar uso de context
    // a través de gaps asíncronos (use_build_context_synchronously)
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();
    final router = GoRouter.of(context);

    // Simular un breve retraso de procesamiento
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

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

    // Calcular descuento de monedero para placeOrder
    final double deliveryFee = _deliveryType == DeliveryType.delivery ? 30.0 : 0.0;
    final double tax = cart.subtotal * _taxRate;
    final double totalBeforeDiscount = cart.subtotal + tax + deliveryFee;

    int pointsRedeemed = 0;
    if (_paymentMethod == PaymentMethod.wallet) {
      final double pointsValue = _userPoints * AppConstants.pesoPerPoint;
      final double discount = min(totalBeforeDiscount, pointsValue);
      pointsRedeemed = (discount / AppConstants.pesoPerPoint).round();
    }

    final order = orderProvider.placeOrder(
      items: cart.items,
      subtotal: cart.subtotal,
      deliveryType: _deliveryType,
      paymentMethod: _paymentMethod,
      userId: userId,
      notes: _deliveryType == DeliveryType.delivery ? 'Dirección: ${_addressController.text.trim()}' : null,
      branchId: _deliveryType == DeliveryType.pickup ? _selectedBranchId : null,
      pointsRedeemed: pointsRedeemed,
    );

    final int pointsEarned = (order.total * AppConstants.pointsPerPeso).floor();
    final OrderModel orderToSave =
        order.copyWith(userId: userId, pointsEarned: pointsEarned);

    await sl<PlaceOrder>().call(orderToSave);
    
    // Sumar puntos ganados
    await sl<UpdateLoyaltyPoints>().call(
      uid: userId,
      pointsEarned: pointsEarned,
    );
    
    // Restar puntos redimidos si aplica
    if (pointsRedeemed > 0) {
      await sl<UpdateLoyaltyPoints>().call(
        uid: userId,
        pointsEarned: -pointsRedeemed,
      );
    }

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
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.currentUser?.uid;
    final colorScheme = Theme.of(context).colorScheme;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirmar Pedido')),
        body: const Center(child: Text('Debes iniciar sesión para continuar.')),
      );
    }

    return StreamBuilder<LoyaltyCardModel?>(
      stream: sl<GetLoyaltyCard>().call(userId),
      builder: (context, snapshot) {
        final points = snapshot.data?.points ?? 0;
        _userPoints = points;

        final double deliveryFee = _deliveryType == DeliveryType.delivery ? 30.0 : 0.0;
        final double tax = cart.subtotal * _taxRate;
        final double totalBeforeDiscount = cart.subtotal + tax + deliveryFee;

        double discount = 0.0;
        int pointsRedeemed = 0;

        if (_paymentMethod == PaymentMethod.wallet) {
          final double pointsValue = points * AppConstants.pesoPerPoint;
          discount = min(totalBeforeDiscount, pointsValue);
          pointsRedeemed = (discount / AppConstants.pesoPerPoint).round();
        }

        final double total = totalBeforeDiscount - discount;

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
                // ── Resumen de productos ──────────────────────────────────────
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
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        item.selectedSize.name +
                                            (item.selectedMilk != null
                                                ? ' · ${item.selectedMilk!.name}'
                                                : ''),
                                        style: AppTypography.bodySmall.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${item.subtotal.toStringAsFixed(2)}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
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
                        valueColor: colorScheme.onSurfaceVariant,
                      ),
                      if (_deliveryType == DeliveryType.delivery) ...[
                        const Gap(AppSpacing.xs),
                        _CheckoutPriceRow(
                          label: 'Cargo por Envío',
                          value: deliveryFee,
                          valueColor: colorScheme.primary,
                        ),
                      ],
                      if (_paymentMethod == PaymentMethod.wallet && discount > 0) ...[
                        const Gap(AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Descuento Monedero ($pointsRedeemed pts)',
                              style: AppTypography.bodySmall.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                            Text(
                              '-\$${discount.toStringAsFixed(2)}',
                              style: AppTypography.bodySmall.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
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

                // ── Tipo de entrega ───────────────────────────────────────────
                _SectionCard(
                  title: 'Tipo de Entrega',
                  icon: Icons.store_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        ? colorScheme.primaryContainer
                                        : colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? colorScheme.primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        type == DeliveryType.pickup
                                            ? Icons.store
                                            : Icons.local_shipping_outlined,
                                        color: selected
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant,
                                        size: 28,
                                      ),
                                      const Gap(AppSpacing.xs),
                                      Text(
                                        type.label,
                                        style: AppTypography.labelMedium.copyWith(
                                          color: selected
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
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
                      if (_deliveryType == DeliveryType.delivery) ...[
                        const Gap(AppSpacing.md),
                        Text(
                          'Dirección de Entrega',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Gap(AppSpacing.xs),
                        TextField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            hintText: 'Calle, Número, Colonia, Código Postal',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ],
                      if (_deliveryType == DeliveryType.pickup) ...[
                        const Gap(AppSpacing.md),
                        Text(
                          'Sucursal de Recogida',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Gap(AppSpacing.xs),
                        StreamBuilder<List<SucursalModel>>(
                          stream: sl<WatchAllSucursales>().call(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Text(
                                'Error al cargar sucursales.',
                                style: TextStyle(color: colorScheme.error),
                              );
                            }
                            final sucursales = snapshot.data ?? [];
                            if (sucursales.isEmpty) {
                              return Text(
                                'No hay sucursales disponibles.',
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              );
                            }

                            final listIds = sucursales.map((s) => s.id).toList();
                            if (_selectedBranchId != null && !listIds.contains(_selectedBranchId)) {
                              _selectedBranchId = null;
                            }

                            return DropdownButtonFormField<String>(
                              value: _selectedBranchId,
                              hint: Text(
                                'Selecciona una sucursal',
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                              dropdownColor: colorScheme.surfaceContainerHighest,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.storefront),
                                border: OutlineInputBorder(),
                              ),
                              items: sucursales.map((sucursal) {
                                return DropdownMenuItem<String>(
                                  value: sucursal.id,
                                  child: Text('${sucursal.name} (${sucursal.city})'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedBranchId = val;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const Gap(AppSpacing.md),

                // ── Método de pago ────────────────────────────────────────────
                _SectionCard(
                  title: 'Método de Pago',
                  icon: Icons.payment_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...PaymentMethod.values.map((method) {
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
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    selected ? colorScheme.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  icon,
                                  color: selected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const Gap(AppSpacing.md),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method.label,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: selected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    if (method == PaymentMethod.wallet)
                                      Text(
                                        'Saldo: $points pts (\$${(points * AppConstants.pesoPerPoint).toStringAsFixed(2)} MXN)',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                if (selected)
                                  Icon(
                                    Icons.check_circle,
                                    color: colorScheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (_paymentMethod == PaymentMethod.card) ...[
                        const Gap(AppSpacing.md),
                        Text(
                          'Datos de la Tarjeta',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Gap(AppSpacing.xs),
                        TextField(
                          controller: _cardNumberController,
                          decoration: const InputDecoration(
                            hintText: 'Número de Tarjeta (16 dígitos)',
                            prefixIcon: Icon(Icons.credit_card),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                        const Gap(AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _cardExpiryController,
                                decoration: const InputDecoration(
                                  hintText: 'MM/AA',
                                  prefixIcon: Icon(Icons.calendar_today_outlined),
                                ),
                                keyboardType: TextInputType.datetime,
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            Expanded(
                              child: TextField(
                                controller: _cardCvvController,
                                decoration: const InputDecoration(
                                  hintText: 'CVV',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                maxLength: 3,
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const Gap(AppSpacing.xxl),

                // ── Botón Confirmar ───────────────────────────────────────────
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
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────────────────────────────────────

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
              Icon(icon, size: 20, color: colorScheme.primary),
              const Gap(AppSpacing.sm),
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final TextStyle style =
        isTotal ? AppTypography.titleSmall : AppTypography.bodySmall;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style.copyWith(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal,
            color: isTotal ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: style.copyWith(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal,
            color: valueColor ??
                (isTotal ? colorScheme.primary : colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}
