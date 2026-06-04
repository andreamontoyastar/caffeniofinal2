import 'package:caffenio/core/constants/app_constants.dart';
import 'package:caffenio/shared/models/cart_item_model.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:flutter/material.dart';

/// Proveedor de estado en memoria para los pedidos realizados.
///
/// Se registra en [MultiProvider] y permite a las pantallas de
/// checkout/confirmación colocar pedidos y consultar el historial.
class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];

  /// Lista completa de pedidos realizados en esta sesión.
  List<OrderModel> get orders => List.unmodifiable(_orders);

  /// El pedido más reciente (útil para la pantalla de confirmación).
  OrderModel? get lastOrder => _orders.isNotEmpty ? _orders.last : null;

  /// Crea un nuevo pedido a partir de los items del carrito y lo almacena.
  ///
  /// Aplica el 16 % de IVA al subtotal y genera un ID basado en tiempo.
  /// Devuelve el [OrderModel] creado para que el llamador pueda navegar
  /// a la pantalla de confirmación con él como `extra`.
  OrderModel placeOrder({
    required List<CartItemModel> items,
    required double subtotal,
    required DeliveryType deliveryType,
    required PaymentMethod paymentMethod,
    String? userId,
    String? notes,
    String? branchId,
    int pointsRedeemed = 0,
  }) {
    const double taxRate = 0.16;
    final double tax = subtotal * taxRate;
    final double deliveryFee = deliveryType == DeliveryType.delivery ? 30.0 : 0.0;
    final double discount = pointsRedeemed * AppConstants.pesoPerPoint;
    final double total = (subtotal + tax + deliveryFee - discount).clamp(0.0, double.infinity);

    // ID único basado en timestamp (8 chars hex)
    final String orderId =
        DateTime.now().millisecondsSinceEpoch.toRadixString(16).padLeft(8, '0');

    final OrderModel order = OrderModel(
      id: orderId,
      userId: userId ?? '',
      items: List.from(items),
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: OrderStatus.pending,
      deliveryType: deliveryType,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      notes: notes,
      branchId: branchId,
      pointsRedeemed: pointsRedeemed,
    );

    _orders.add(order);
    notifyListeners();
    return order;
  }

  /// Actualiza el status de un pedido existente (útil para la vista de barista).
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final int index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }
}
