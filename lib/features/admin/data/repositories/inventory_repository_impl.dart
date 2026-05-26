import 'package:caffenio/features/admin/data/datasources/inventory_remote_datasource.dart';
import 'package:caffenio/features/admin/domain/repositories/inventory_repository.dart';
import 'package:caffenio/shared/models/inventory_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<InventoryModel>> watchBySucursal(String sucursalId) {
    return remoteDataSource.watchBySucursal(sucursalId);
  }

  @override
  Future<InventoryModel?> getInventoryById(String id) {
    return remoteDataSource.getInventoryById(id);
  }

  @override
  Future<InventoryModel?> getInventoryBySucursalAndIngredient(
    String sucursalId,
    String ingredientId,
  ) {
    return remoteDataSource.getInventoryBySucursalAndIngredient(
      sucursalId,
      ingredientId,
    );
  }

  @override
  Future<void> createInventory(InventoryModel inventory) {
    return remoteDataSource.createInventory(inventory);
  }

  @override
  Future<void> updateInventory(InventoryModel inventory) {
    return remoteDataSource.updateInventory(inventory);
  }

  @override
  Future<void> deleteInventory(String id) {
    return remoteDataSource.deleteInventory(id);
  }

  @override
  Future<void> decrementStock(String inventoryId, double quantity) {
    return remoteDataSource.decrementStock(inventoryId, quantity);
  }
}
