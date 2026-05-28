import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/core/theme/app_spacing.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void showOrderDetailDialog(BuildContext context, OrderModel order) {
  final theme = Theme.of(context);
  bool isUpdating = false;
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
            if (order.address != null && order.address!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Dirección: ${order.address}',
                  style: theme.textTheme.bodyMedium),
            ],
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
        if (order.status == OrderStatus.ready)
          StatefulBuilder(
            builder: (context, setDialogState) {
              return TextButton.icon(
                onPressed: isUpdating
                    ? null
                    : () async {
                        setDialogState(() => isUpdating = true);
                        try {
                          await FirebaseFirestore.instance
                              .collection(FirebaseConstants.ordersCollection)
                              .doc(order.id)
                              .update({
                            FirebaseConstants.fieldOrderStatus: OrderStatus.delivered.name,
                          });
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  order.deliveryType == DeliveryType.delivery
                                      ? '¡Pedido marcado como Entregado!'
                                      : '¡Pedido marcado como Recogido!',
                                ),
                              ),
                            );
                          }
                        } catch (_) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Error al actualizar el estado.'),
                              ),
                            );
                          }
                        } finally {
                          if (ctx.mounted) {
                            setDialogState(() => isUpdating = false);
                          }
                        }
                      },
                icon: isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  order.deliveryType == DeliveryType.delivery
                      ? '¡Ya lo recibí!'
                      : '¡Ya lo recogí!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                ),
              );
            },
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}
