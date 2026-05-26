import 'package:caffenio/features/orders/domain/repositories/order_repository.dart';
import 'package:caffenio/shared/models/order_model.dart';

class PlaceOrder {
  PlaceOrder({required OrderRepository repository}) : _repository = repository;

  final OrderRepository _repository;

  Future<void> call(OrderModel order) {
    return _repository.placeOrder(order);
  }
}
