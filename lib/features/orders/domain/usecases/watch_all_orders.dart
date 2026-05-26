import 'package:caffenio/features/orders/domain/repositories/order_repository.dart';
import 'package:caffenio/shared/models/order_model.dart';

class WatchAllOrders {
  WatchAllOrders({required OrderRepository repository})
      : _repository = repository;

  final OrderRepository _repository;

  Stream<List<OrderModel>> call() {
    return _repository.watchAllOrders();
  }
}
