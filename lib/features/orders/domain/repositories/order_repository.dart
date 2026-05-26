import 'package:caffenio/shared/models/order_model.dart';

abstract class OrderRepository {
  Stream<List<OrderModel>> watchCustomerOrders(String userId);
  Stream<List<OrderModel>> watchAllOrders();
  Future<void> placeOrder(OrderModel order);
}
