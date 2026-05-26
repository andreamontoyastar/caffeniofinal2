import 'package:caffenio/features/orders/domain/repositories/order_repository.dart';
import 'package:caffenio/shared/models/order_model.dart';

class GetCustomerOrders {
  GetCustomerOrders({required OrderRepository repository})
      : _repository = repository;

  final OrderRepository _repository;

  Stream<List<OrderModel>> call(String userId) {
    return _repository.watchCustomerOrders(userId);
  }
}
