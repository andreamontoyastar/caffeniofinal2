import 'package:caffenio/shared/models/purchase_order_model.dart';

abstract class PurchaseOrderRepository {
  Stream<List<PurchaseOrderModel>> watchAllPurchaseOrders();
  Future<PurchaseOrderModel?> getPurchaseOrderById(String id);
  Future<void> createPurchaseOrder(PurchaseOrderModel order);
  Future<void> updatePurchaseOrder(PurchaseOrderModel order);
  Future<void> deletePurchaseOrder(String id);
}
