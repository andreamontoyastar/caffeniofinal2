import 'package:caffenio/core/theme/app_colors.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/core/theme/app_typography.dart';
import 'package:caffenio/features/cart/presentation/providers/cart_provider.dart';
import 'package:caffenio/shared/models/cart_item_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Pantalla del carrito de compras.
///
/// Muestra los items agregados con sus personalizaciones, subtotales,
/// IVA estimado y total final. Permite ajustar cantidades, eliminar
/// productos individuales o proceder al checkout.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const double _taxRate = 0.16;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClearCart(context, cart),
              child: Text(
                'Vaciar',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _EmptyCartView(onBrowse: () => context.go('/home/catalog'))
          : _CartContent(cart: cart, taxRate: _taxRate),
    );
  }

  void _confirmClearCart(BuildContext context, CartProvider cart) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content:
            const Text('¿Deseas eliminar todos los productos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              cart.clearCart();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            ),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado Vacío
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 120,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Gap(AppSpacing.xl),
            Text(
              'Tu carrito está vacío',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.sm),
            Text(
              'Explora nuestro menú y agrega\ntus bebidas favoritas.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.coffee),
              label: const Text('Ver Menú'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, AppSpacing.buttonHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contenido principal del carrito
// ─────────────────────────────────────────────────────────────────────────────

class _CartContent extends StatelessWidget {
  const _CartContent({required this.cart, required this.taxRate});

  final CartProvider cart;
  final double taxRate;

  @override
  Widget build(BuildContext context) {
    final double tax = cart.subtotal * taxRate;
    final double total = cart.subtotal + tax;

    return Column(
      children: [
        // Lista de items
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _CartItemCard(item: item, cart: cart);
            },
          ),
        ),

        // Panel de totales + CTA
        _TotalPanel(subtotal: cart.subtotal, tax: tax, total: total),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de item del carrito
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item, required this.cart});

  final CartItemModel item;
  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    final unitPrice = item.subtotal / item.quantity;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono del producto
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.coffee,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const Gap(AppSpacing.md),

            // Info del item
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Gap(AppSpacing.xs),
                  _CustomizationChips(item: item),
                  const Gap(AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Precio unitario
                      Text(
                        '\$${unitPrice.toStringAsFixed(2)} c/u',
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // Subtotal del item
                      Text(
                        '\$${item.subtotal.toStringAsFixed(2)}',
                        style: AppTypography.titleSmall.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chips de personalización del item
// ─────────────────────────────────────────────────────────────────────────────

class _CustomizationChips extends StatelessWidget {
  const _CustomizationChips({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final List<String> chips = [
      item.selectedSize.name,
      if (item.selectedMilk != null) item.selectedMilk!.name,
      ...item.selectedExtras.map((e) => e.name),
    ];

    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: chips.map((label) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Panel de totales
// ─────────────────────────────────────────────────────────────────────────────

class _TotalPanel extends StatelessWidget {
  const _TotalPanel({
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  final double subtotal;
  final double tax;
  final double total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Línea decorativa
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          _PriceRow(label: 'Subtotal', value: subtotal),
          const Gap(AppSpacing.xs),
          _PriceRow(
            label: 'IVA (16%)',
            value: tax,
            valueColor: colorScheme.onSurfaceVariant,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),
          _PriceRow(
            label: 'Total',
            value: total,
            isTotal: true,
          ),

          const Gap(AppSpacing.lg),

          // Botón Checkout
          ElevatedButton.icon(
            onPressed: () => context.push('/cart/checkout'),
            icon: const Icon(Icons.payment_outlined),
            label: const Text('Proceder al Pago'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
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
    final TextStyle style = isTotal
        ? AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          )
        : AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? style
              : style.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: style.copyWith(
            color: valueColor ??
                (isTotal ? colorScheme.primary : colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}
