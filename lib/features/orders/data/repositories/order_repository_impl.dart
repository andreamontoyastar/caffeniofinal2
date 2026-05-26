import 'package:caffenio/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:caffenio/features/orders/domain/repositories/order_repository.dart';
import 'package:caffenio/shared/models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl({required OrderRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final OrderRemoteDataSource _remoteDataSource;

  @override
  Stream<List<OrderModel>> watchCustomerOrders(String userId) {
    return _remoteDataSource.watchCustomerOrders(userId);
  }

  @override
  Stream<List<OrderModel>> watchAllOrders() {
    return _remoteDataSource.watchAllOrders();
  }

  @override
  Future<void> placeOrder(OrderModel order) {
    return _remoteDataSource.placeOrder(order);
  }
}
