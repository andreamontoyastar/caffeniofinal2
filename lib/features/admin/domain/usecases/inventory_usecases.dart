import 'package:caffenio/features/admin/domain/repositories/inventory_repository.dart';
import 'package:caffenio/shared/models/inventory_model.dart';

class WatchInventoryBySucursal {
  final InventoryRepository repository;

  WatchInventoryBySucursal({required this.repository});

  Stream<List<InventoryModel>> call(String sucursalId) {
    return repository.watchBySucursal(sucursalId);
  }
}

class GetInventoryById {
  final InventoryRepository repository;

  GetInventoryById({required this.repository});

  Future<InventoryModel?> call(String id) {
    return repository.getInventoryById(id);
  }
}

class GetInventoryBySucursalAndIngredient {
  final InventoryRepository repository;

  GetInventoryBySucursalAndIngredient({required this.repository});

  Future<InventoryModel?> call(String sucursalId, String ingredientId) {
    return repository.getInventoryBySucursalAndIngredient(
        sucursalId, ingredientId);
  }
}

class CreateInventoryItem {
  final InventoryRepository repository;

  CreateInventoryItem({required this.repository});

  Future<void> call(InventoryModel inventory) {
    return repository.createInventory(inventory);
  }
}

class UpdateInventoryItem {
  final InventoryRepository repository;

  UpdateInventoryItem({required this.repository});

  Future<void> call(InventoryModel inventory) {
    return repository.updateInventory(inventory);
  }
}

class DeleteInventoryItem {
  final InventoryRepository repository;

  DeleteInventoryItem({required this.repository});

  Future<void> call(String id) {
    return repository.deleteInventory(id);
  }
}

class DecrementInventoryStock {
  final InventoryRepository repository;

  DecrementInventoryStock({required this.repository});

  Future<void> call({required String inventoryId, required double quantity}) {
    return repository.decrementStock(inventoryId, quantity);
  }
}
