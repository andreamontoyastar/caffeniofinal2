import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:flutter/material.dart';

void showOrderDetailDialog(BuildContext context, OrderModel order) {
  final theme = Theme.of(context);
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Pedido ${order.displayId}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Estado: ${order.statusLabel}',
                style: theme.textTheme.bodyMedium),
            Text('Fecha: ${order.dateLabel}',
                style: theme.textTheme.bodyMedium),
            Text('Pago: ${order.paymentMethodLabel}',
                style: theme.textTheme.bodyMedium),
            Text('Entrega: ${order.deliveryType.label}',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('Artículos', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  '${item.quantity}x ${item.product.name} — \$${item.subtotal.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            const Divider(),
            Text(
              'Total: \$${order.total.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (order.pointsEarned > 0)
              Text(
                'Puntos ganados: ${order.pointsEarned}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}
