import 'package:caffenio/features/admin/domain/repositories/purchase_order_repository.dart';
import 'package:caffenio/shared/models/purchase_order_model.dart';

class WatchAllPurchaseOrders {
  final PurchaseOrderRepository repository;

  WatchAllPurchaseOrders({required this.repository});

  Stream<List<PurchaseOrderModel>> call() {
    return repository.watchAllPurchaseOrders();
  }
}

class GetPurchaseOrderById {
  final PurchaseOrderRepository repository;

  GetPurchaseOrderById({required this.repository});

  Future<PurchaseOrderModel?> call(String id) {
    return repository.getPurchaseOrderById(id);
  }
}

class CreatePurchaseOrder {
  final PurchaseOrderRepository repository;

  CreatePurchaseOrder({required this.repository});

  Future<void> call(PurchaseOrderModel order) {
    return repository.createPurchaseOrder(order);
  }
}

class UpdatePurchaseOrder {
  final PurchaseOrderRepository repository;

  UpdatePurchaseOrder({required this.repository});

  Future<void> call(PurchaseOrderModel order) {
    return repository.updatePurchaseOrder(order);
  }
}

class DeletePurchaseOrder {
  final PurchaseOrderRepository repository;

  DeletePurchaseOrder({required this.repository});

  Future<void> call(String id) {
    return repository.deletePurchaseOrder(id);
  }
}
