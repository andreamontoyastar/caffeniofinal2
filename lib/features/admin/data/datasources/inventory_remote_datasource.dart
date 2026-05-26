import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/shared/models/inventory_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class InventoryRemoteDataSource {
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

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  InventoryRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  late final CollectionReference<Map<String, dynamic>> _inventoryRef =
      _firestore.collection(FirebaseConstants.inventoryCollection);

  @override
  Stream<List<InventoryModel>> watchBySucursal(String sucursalId) {
    return _inventoryRef
        .where('sucursalId', isEqualTo: sucursalId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<InventoryModel?> getInventoryById(String id) async {
    final doc = await _inventoryRef.doc(id).get();
    if (!doc.exists) return null;
    return InventoryModel.fromFirestore(doc);
  }

  @override
  Future<InventoryModel?> getInventoryBySucursalAndIngredient(
    String sucursalId,
    String ingredientId,
  ) async {
    final query = await _inventoryRef
        .where('sucursalId', isEqualTo: sucursalId)
        .where('ingredientId', isEqualTo: ingredientId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return InventoryModel.fromFirestore(query.docs.first);
  }

  @override
  Future<void> createInventory(InventoryModel inventory) async {
    await _inventoryRef.doc(inventory.id).set(inventory.toMap());
  }

  @override
  Future<void> updateInventory(InventoryModel inventory) async {
    await _inventoryRef.doc(inventory.id).update(inventory.toMap());
  }

  @override
  Future<void> deleteInventory(String id) async {
    await _inventoryRef.doc(id).delete();
  }

  @override
  Future<void> decrementStock(String inventoryId, double quantity) async {
    final doc = await _inventoryRef.doc(inventoryId).get();
    if (!doc.exists) return;

    final currentStock =
        (doc.data()?['currentStock'] as num?)?.toDouble() ?? 0.0;
    final newStock = (currentStock - quantity).clamp(0.0, double.infinity);

    await _inventoryRef.doc(inventoryId).update({
      'currentStock': newStock,
      'lastUpdated': Timestamp.now(),
    });
  }
}
