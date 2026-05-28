import 'package:caffenio/core/constants/app_constants.dart';
import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/services/service_locator.dart';
import 'package:caffenio/core/theme/app_colors.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/core/theme/app_typography.dart';
import 'package:caffenio/features/auth/presentation/providers/auth_provider.dart';
import 'package:caffenio/features/cart/presentation/providers/cart_provider.dart';
import 'package:caffenio/features/loyalty/data/models/loyalty_card_model.dart';
import 'package:caffenio/features/loyalty/domain/repositories/loyalty_repository.dart';
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
  DeliveryType _deliveryType = DeliveryType.inStore; // Default to inStore pickup
  PaymentMethod _paymentMethod = PaymentMethod.card;
  bool _isProcessing = false;
  bool _useLoyaltyPoints = false;
  late final TextEditingController _addressController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _cardExpiryController;
  late final TextEditingController _cardCvvController;
  late final TextEditingController _cardHolderController;

  // Sucursal selector
  List<SucursalModel> _sucursales = [];
  String? _selectedBranchId;

  static const double _taxRate = 0.16;

  @override
  void initState() {
    super.initState();
    final savedAddress = context.read<AuthProvider>().currentUser?.address ?? '';
    _addressController = TextEditingController(text: savedAddress);
    _cardNumberController = TextEditingController();
    _cardExpiryController = TextEditingController();
    _cardCvvController = TextEditingController();
    _cardHolderController = TextEditingController();
    _loadSucursales();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  Future<void> _loadSucursales() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(FirebaseConstants.sucursalesCollection)
          .where('isActive', isEqualTo: true)
          .get();
      if (mounted) {
        setState(() {
          _sucursales =
              snap.docs.map((d) => SucursalModel.fromFirestore(d)).toList();
          if (_sucursales.isNotEmpty) {
            _selectedBranchId = _sucursales.first.id;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _confirmOrder(BuildContext context) async {
    setState(() => _isProcessing = true);

    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final authProvider = context.read<AuthProvider>();
    final router = GoRouter.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Simular un breve retraso de procesamiento
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final userId = authProvider.currentUser?.uid;
    if (userId == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para confirmar el pedido.'),
        ),
      );
      setState(() => _isProcessing = false);
      return;
    }

    final String? addressStr = _deliveryType == DeliveryType.delivery ? _addressController.text.trim() : null;
    if (_deliveryType == DeliveryType.delivery && (addressStr == null || addressStr.isEmpty)) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa una dirección de entrega.'),
        ),
      );
      setState(() => _isProcessing = false);
      return;
    }

    // Validar datos de la tarjeta si se paga con tarjeta
    if (_paymentMethod == PaymentMethod.card) {
      final cardNum = _cardNumberController.text.replaceAll(' ', '');
      final expiry = _cardExpiryController.text.trim();
      final cvv = _cardCvvController.text.trim();
      final holder = _cardHolderController.text.trim();
      
      if (cardNum.length < 16 || expiry.isEmpty || cvv.length < 3 || holder.isEmpty) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Por favor, ingresa los datos de tu tarjeta correctamente.'),
          ),
        );
        setState(() => _isProcessing = false);
        return;
      }
    }

    // Actualizar la dirección en el perfil si es una entrega nueva y ha cambiado
    if (_deliveryType == DeliveryType.delivery && addressStr != null && authProvider.currentUser?.address != addressStr) {
      try {
        await authProvider.updateProfile(address: addressStr);
      } catch (_) {}
    }

    final order = orderProvider.placeOrder(
      items: cart.selectedItems,
      subtotal: cart.selectedSubtotal,
      deliveryType: _deliveryType,
      paymentMethod: _paymentMethod,
      userId: userId,
      branchId: _deliveryType == DeliveryType.inStore ? _selectedBranchId : null,
      address: addressStr,
    );

    // Cargar puntos para restar en caso de que esté activo
    int pointsToUse = 0;
    double pointsDiscount = 0.0;
    if (_useLoyaltyPoints) {
      try {
        final cardDoc = await FirebaseFirestore.instance
            .collection(FirebaseConstants.loyaltyCardsCollection)
            .doc(userId)
            .get();
        if (cardDoc.exists) {
          final points = (cardDoc.data()?[FirebaseConstants.fieldLoyaltyPoints] as num?)?.toInt() ?? 0;
          final double maxPointsValue = points * AppConstants.pesoPerPoint;
          final double shippingFee = _deliveryType == DeliveryType.delivery ? 30.0 : 0.0;
          final double currentSelectedTotal = (cart.selectedSubtotal + shippingFee) * (1 + _taxRate);
          final double pointsValueToRedeem = maxPointsValue > currentSelectedTotal ? currentSelectedTotal : maxPointsValue;
          pointsToUse = (pointsValueToRedeem / AppConstants.pesoPerPoint).round();
          pointsDiscount = pointsToUse * AppConstants.pesoPerPoint;
        }
      } catch (_) {}
    }

    final double finalTotal = (order.total - pointsDiscount).clamp(0.0, 999999.0);
    final int pointsEarned = (finalTotal * AppConstants.pointsPerPeso).floor();
    
    final OrderModel orderToSave = order.copyWith(
      userId: userId,
      pointsEarned: pointsEarned,
      pointsRedeemed: pointsToUse,
      total: finalTotal,
    );

    try {
      await sl<PlaceOrder>().call(orderToSave);
      
      // Ganar nuevos puntos
      if (pointsEarned > 0) {
        await sl<UpdateLoyaltyPoints>().call(
          uid: userId,
          pointsEarned: pointsEarned,
        );
      }

      // Restar puntos canjeados
      if (pointsToUse > 0) {
        await sl<UpdateLoyaltyPoints>().call(
          uid: userId,
          pointsEarned: -pointsToUse,
        );
      }

      String bodyMsg = 'Tu pedido ${orderToSave.displayId} fue recibido. Ganaste $pointsEarned puntos.';
      if (pointsToUse > 0) {
        bodyMsg += ' Canjeaste $pointsToUse puntos (-\$${pointsDiscount.toStringAsFixed(2)} MXN).';
      }

      await sl<NotificationsRemoteDataSource>().sendToUser(
        uid: userId,
        title: 'Pedido confirmado',
        body: bodyMsg,
        type: 'order',
        orderId: orderToSave.id,
      );

      cart.clearSelectedItems();
      setState(() => _isProcessing = false);
      router.go('/cart/confirmation', extra: orderToSave);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al procesar el pedido: $e')),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final double subtotal = cart.selectedSubtotal;
    final double shippingFee = _deliveryType == DeliveryType.delivery ? 30.0 : 0.0;
    final double actualSubtotal = subtotal + shippingFee;
    final double tax = actualSubtotal * _taxRate;
    final double total = actualSubtotal + tax;

    final userId = context.watch<AuthProvider>().currentUser?.uid;
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
            // ── Resumen de productos ──────────────────────────────────────
            _SectionCard(
              title: 'Resumen del Pedido',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  ...cart.selectedItems.map((item) => Padding(
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
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: AppSpacing.lg),
                  _CheckoutPriceRow(label: 'Subtotal productos', value: subtotal),
                  if (_deliveryType == DeliveryType.delivery) ...[
                    const Gap(AppSpacing.xs),
                    _CheckoutPriceRow(label: 'Costo de envío', value: shippingFee),
                  ],
                  const Gap(AppSpacing.xs),
                  _CheckoutPriceRow(
                    label: 'IVA (16%)',
                    value: tax,
                    valueColor: AppColors.onSurfaceVariant,
                  ),
                  const Gap(AppSpacing.xs),
                  
                  // Render de descuento por puntos
                  if (_useLoyaltyPoints && userId != null)
                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection(FirebaseConstants.loyaltyCardsCollection)
                          .doc(userId)
                          .get(),
                      builder: (context, snap) {
                        if (!snap.hasData || !snap.data!.exists) return const SizedBox.shrink();
                        final pts = (snap.data!.data()?[FirebaseConstants.fieldLoyaltyPoints] as num?)?.toInt() ?? 0;
                        final double val = pts * AppConstants.pesoPerPoint;
                        final double actualVal = val > total ? total : val;
                        if (actualVal <= 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: _CheckoutPriceRow(
                            label: 'Descuento Canje de Puntos',
                            value: -actualVal,
                            valueColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  
                  // Cálculo de precio final total
                  _FinalPriceBuilder(
                    baseTotal: total,
                    usePoints: _useLoyaltyPoints,
                    userId: userId,
                  ),
                ],
              ),
            ),

            const Gap(AppSpacing.md),

            // ── Loyalty Points Selection ──────────────────────────────────
            if (userId != null)
              StreamBuilder<LoyaltyCardModel?>(
                stream: sl<LoyaltyRepository>().watchLoyaltyCard(userId),
                builder: (context, cardSnapshot) {
                  if (!cardSnapshot.hasData || cardSnapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  final loyaltyCard = cardSnapshot.data!;
                  final availablePoints = loyaltyCard.points;
                  if (availablePoints <= 0) return const SizedBox.shrink();

                  final double maxPointsValue = availablePoints * AppConstants.pesoPerPoint;

                  return Column(
                    children: [
                      _SectionCard(
                        title: 'Puntos Caffenio Club',
                        icon: Icons.card_membership,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tienes $availablePoints puntos disponibles',
                                    style: AppTypography.bodyMedium
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Equivale a \$${maxPointsValue.toStringAsFixed(2)} MXN de descuento.',
                                    style: AppTypography.bodySmall
                                        .copyWith(color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _useLoyaltyPoints,
                              activeThumbColor: AppColors.primary,
                              onChanged: (val) {
                                setState(() {
                                  _useLoyaltyPoints = val;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      const Gap(AppSpacing.md),
                    ],
                  );
                },
              ),

            // ── Tipo de entrega ───────────────────────────────────────────
            _SectionCard(
              title: 'Tipo de Entrega',
              icon: Icons.store_outlined,
              child: Row(
                children: DeliveryType.values.map((type) {
                  final selected = _deliveryType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _deliveryType = type);
                        if (type == DeliveryType.delivery) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Se cobrarán \$30.00 MXN adicionales por servicio a domicilio.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.primary : colorScheme.outlineVariant,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          type == DeliveryType.delivery ? 'A domicilio' : 'Recoger en tienda',
                          style: AppTypography.bodyMedium.copyWith(
                            color: selected ? Colors.white : AppColors.onSurface,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Gap(AppSpacing.md),

            // ── Dirección de Entrega (solo si es A domicilio) ─────────────
            if (_deliveryType == DeliveryType.delivery) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 24),
                    const Gap(AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Aviso: El envío a domicilio tiene un cargo extra de \$30.00 MXN.',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.md),
              _SectionCard(
                title: 'Dirección de entrega',
                icon: Icons.location_on_outlined,
                child: TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Dirección de envío',
                    hintText: 'Calle, Número, Colonia, Ciudad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
              ),
            ],

            // ── Selección de Sucursal (solo si es Recoger en tienda) ────────
            if (_deliveryType == DeliveryType.inStore && _sucursales.isNotEmpty)
              _SectionCard(
                title: 'Sucursal de recogida',
                icon: Icons.store_outlined,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  itemHeight: 72.0,
                  initialValue: _selectedBranchId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  items: _sucursales
                      .map(
                        (s) => DropdownMenuItem(
                          value: s.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(s.name,
                                  style: AppTypography.bodyMedium
                                      .copyWith(fontWeight: FontWeight.bold)),
                              Text('${s.address}, ${s.city}',
                                  style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBranchId = val),
                ),
              ),

            const Gap(AppSpacing.md),

            // ── Método de pago ────────────────────────────────────────────
            _SectionCard(
              title: 'Método de Pago',
              icon: Icons.payment_outlined,
              child: Column(
                children: PaymentMethod.values.map((method) {
                  final selected = _paymentMethod == method;
                  final icon = switch (method) {
                    PaymentMethod.card => Icons.credit_card_outlined,
                    PaymentMethod.cash => Icons.monetization_on_outlined,
                  };

                  return InkWell(
                    onTap: () => setState(() => _paymentMethod = method),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryContainer.withValues(alpha: 0.2)
                            : Colors.transparent,
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

            const Gap(AppSpacing.md),

            // ── Formulario de tarjeta (solo si es pago con Tarjeta) ─────────
            if (_paymentMethod == PaymentMethod.card) ...[
              _SectionCard(
                title: 'Datos de la Tarjeta',
                icon: Icons.credit_card_outlined,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cardHolderController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Titular',
                        hintText: 'Ej. Juan Pérez',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const Gap(AppSpacing.md),
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Número de Tarjeta',
                        hintText: '1234 5678 1234 5678',
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 19,
                    ),
                    const Gap(AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cardExpiryController,
                            decoration: InputDecoration(
                              labelText: 'Expiración',
                              hintText: 'MM/AA',
                              counterText: '',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.datetime,
                            maxLength: 5,
                          ),
                        ),
                        const Gap(AppSpacing.md),
                        Expanded(
                          child: TextFormField(
                            controller: _cardCvvController,
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              counterText: '',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

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
    final TextStyle style = isTotal
        ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800)
        : AppTypography.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? style
              : style.copyWith(color: AppColors.onSurfaceVariant),
        ),
        Text(
          '\$${value.toStringAsFixed(2)} MXN',
          style: style.copyWith(
            color: valueColor ??
                (isTotal ? AppColors.primary : AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}

class _FinalPriceBuilder extends StatelessWidget {
  const _FinalPriceBuilder({
    required this.baseTotal,
    required this.usePoints,
    required this.userId,
  });

  final double baseTotal;
  final bool usePoints;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    if (!usePoints || userId == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: _CheckoutPriceRow(
          label: 'Total',
          value: baseTotal,
          isTotal: true,
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection(FirebaseConstants.loyaltyCardsCollection)
          .doc(userId)
          .get(),
      builder: (context, snap) {
        double finalTotal = baseTotal;
        if (snap.hasData && snap.data!.exists) {
          final pts = (snap.data!.data()?[FirebaseConstants.fieldLoyaltyPoints] as num?)?.toInt() ?? 0;
          final val = pts * AppConstants.pesoPerPoint;
          finalTotal = (baseTotal - val).clamp(0.0, 999999.0);
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: _CheckoutPriceRow(
            label: 'Total Final',
            value: finalTotal,
            isTotal: true,
          ),
        );
      },
    );
  }
}
