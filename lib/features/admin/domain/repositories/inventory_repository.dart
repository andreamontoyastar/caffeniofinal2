import 'package:caffenio/shared/models/inventory_model.dart';

abstract class InventoryRepository {
  Stream<List<InventoryModel>> watchBySucursal(String sucursalId);
  Future<InventoryModel?> getInventoryById(String id);
  Future<InventoryModel?> getInventoryBySucursalAndIngredient(
    String sucursalId,
    String ingredientId,
  );
  Future<void> createInventory(InventoryModel inventory);
  Future<void> updateInventory(InventoryModel inventory);
  Future<void> deleteInventory(String id);
  Future<void> decrementStock(String inventoryId, double quantity);
}
