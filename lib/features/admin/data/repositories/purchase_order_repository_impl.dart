import 'package:caffenio/features/admin/data/datasources/purchase_order_remote_datasource.dart';
import 'package:caffenio/features/admin/domain/repositories/purchase_order_repository.dart';
import 'package:caffenio/shared/models/purchase_order_model.dart';

class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  final PurchaseOrderRemoteDataSource remoteDataSource;

  PurchaseOrderRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<PurchaseOrderModel>> watchAllPurchaseOrders() {
    return remoteDataSource.watchAllPurchaseOrders();
  }

  @override
  Future<PurchaseOrderModel?> getPurchaseOrderById(String id) {
    return remoteDataSource.getPurchaseOrderById(id);
  }

  @override
  Future<void> createPurchaseOrder(PurchaseOrderModel order) {
    return remoteDataSource.createPurchaseOrder(order);
  }

  @override
  Future<void> updatePurchaseOrder(PurchaseOrderModel order) {
    return remoteDataSource.updatePurchaseOrder(order);
  }

  @override
  Future<void> deletePurchaseOrder(String id) {
    return remoteDataSource.deletePurchaseOrder(id);
  }
}
