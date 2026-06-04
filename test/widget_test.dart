import 'package:caffenio/features/cart/presentation/providers/cart_provider.dart';
import 'package:caffenio/features/orders/presentation/providers/order_provider.dart';
import 'package:caffenio/shared/models/order_model.dart';
import 'package:caffenio/shared/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartProvider Tests', () {
    late CartProvider cartProvider;
    late ProductModel testProduct;

    setUp(() {
      cartProvider = CartProvider();
      testProduct = ProductModel.mockProducts.first; // Café Americano (price: 35.0)
    });

    test('Initial cart should be empty', () {
      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.subtotal, 0.0);
    });

    test('Add item to cart should update totals', () {
      final size = testProduct.sizes.first; // Chico (priceExtra: 0)
      final extras = <CustomizationOption>[];

      cartProvider.addItem(
        product: testProduct,
        quantity: 2,
        selectedSize: size,
        selectedExtras: extras,
      );

      expect(cartProvider.items.length, 1);
      expect(cartProvider.itemCount, 2);
      expect(cartProvider.subtotal, 70.0); // 35 * 2
    });

    test('Add duplicate item should group and sum quantity', () {
      final size = testProduct.sizes.first;
      final extras = <CustomizationOption>[];

      cartProvider.addItem(
        product: testProduct,
        quantity: 2,
        selectedSize: size,
        selectedExtras: extras,
      );

      cartProvider.addItem(
        product: testProduct,
        quantity: 1,
        selectedSize: size,
        selectedExtras: extras,
      );

      expect(cartProvider.items.length, 1);
      expect(cartProvider.itemCount, 3);
      expect(cartProvider.subtotal, 105.0); // 35 * 3
    });

    test('Remove item should remove it completely', () {
      final size = testProduct.sizes.first;
      final extras = <CustomizationOption>[];

      cartProvider.addItem(
        product: testProduct,
        quantity: 1,
        selectedSize: size,
        selectedExtras: extras,
      );

      final itemId = cartProvider.items.first.id;
      cartProvider.removeItem(itemId);

      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, 0);
    });

    test('Clear cart should empty everything', () {
      final size = testProduct.sizes.first;
      final extras = <CustomizationOption>[];

      cartProvider.addItem(
        product: testProduct,
        quantity: 5,
        selectedSize: size,
        selectedExtras: extras,
      );

      cartProvider.clearCart();

      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.subtotal, 0.0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // OrderProvider Tests
  // ─────────────────────────────────────────────────────────────────────────

  group('OrderProvider Tests', () {
    late OrderProvider orderProvider;
    late CartProvider cartProvider;
    late ProductModel testProduct;

    setUp(() {
      orderProvider = OrderProvider();
      cartProvider = CartProvider();
      testProduct = ProductModel.mockProducts.first; // Café Americano (price: 35.0)

      // Agregar un item de prueba al carrito
      cartProvider.addItem(
        product: testProduct,
        quantity: 2,
        selectedSize: testProduct.sizes.first, // Chico
        selectedExtras: const [],
      );
    });

    test('Initial orders list should be empty', () {
      expect(orderProvider.orders, isEmpty);
      expect(orderProvider.lastOrder, isNull);
    });

    test('placeOrder should create an order with correct totals', () {
      final subtotal = cartProvider.subtotal; // 70.0

      final order = orderProvider.placeOrder(
        items: cartProvider.items,
        subtotal: subtotal,
        deliveryType: DeliveryType.pickup,
        paymentMethod: PaymentMethod.card,
      );

      expect(orderProvider.orders.length, 1);
      expect(order.subtotal, 70.0);
      expect(order.tax, closeTo(70.0 * 0.16, 0.001)); // 11.2
      expect(order.total, closeTo(70.0 * 1.16, 0.001)); // 81.2
    });

    test('placeOrder should apply discount and save branchId and pointsRedeemed', () {
      final subtotal = cartProvider.subtotal; // 70.0

      final order = orderProvider.placeOrder(
        items: cartProvider.items,
        subtotal: subtotal,
        deliveryType: DeliveryType.pickup,
        paymentMethod: PaymentMethod.wallet,
        branchId: 'branch_abc',
        pointsRedeemed: 150, // $15.00 MXN discount
      );

      // totalBeforeDiscount = 70.0 + 11.2 = 81.2
      // discount = 150 * 0.10 = 15.0
      // expectedTotal = 81.2 - 15.0 = 66.2
      expect(order.subtotal, 70.0);
      expect(order.tax, closeTo(11.2, 0.001));
      expect(order.total, closeTo(66.2, 0.001));
      expect(order.branchId, 'branch_abc');
      expect(order.pointsRedeemed, 150);
    });

    test('placeOrder should set status to pending', () {
      final order = orderProvider.placeOrder(
        items: cartProvider.items,
        subtotal: cartProvider.subtotal,
        deliveryType: DeliveryType.pickup,
        paymentMethod: PaymentMethod.cash,
      );

      expect(order.status, OrderStatus.pending);
    });

    test('lastOrder should return the most recent order', () {
      orderProvider.placeOrder(
        items: cartProvider.items,
        subtotal: cartProvider.subtotal,
        deliveryType: DeliveryType.pickup,
        paymentMethod: PaymentMethod.wallet,
      );

      expect(orderProvider.lastOrder, isNotNull);
      expect(orderProvider.orders.length, 1);
    });

    test('updateOrderStatus should change the order status', () {
      final order = orderProvider.placeOrder(
        items: cartProvider.items,
        subtotal: cartProvider.subtotal,
        deliveryType: DeliveryType.pickup,
        paymentMethod: PaymentMethod.card,
      );

      orderProvider.updateOrderStatus(order.id, OrderStatus.ready);

      expect(orderProvider.orders.first.status, OrderStatus.ready);
    });

    test('displayId should follow ORD-YEAR-XXXX format', () {
      final order = orderProvider.placeOrder(
        items: cartProvider.items,
        subtotal: cartProvider.subtotal,
        deliveryType: DeliveryType.pickup,
        paymentMethod: PaymentMethod.card,
      );

      expect(order.displayId, startsWith('ORD-'));
      expect(order.displayId.length, greaterThan(8));
    });
  });
}

