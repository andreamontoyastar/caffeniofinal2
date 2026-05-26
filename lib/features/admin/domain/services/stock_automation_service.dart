import 'package:caffenio/features/admin/domain/usecases/inventory_usecases.dart';
import 'package:caffenio/features/admin/domain/usecases/purchase_order_usecases.dart';
import 'package:caffenio/features/admin/domain/usecases/recipe_usecases.dart';
import 'package:caffenio/features/admin/domain/usecases/supplier_usecases.dart';
import 'package:caffenio/shared/models/inventory_model.dart';
import 'package:caffenio/shared/models/purchase_order_detail_model.dart';
import 'package:caffenio/shared/models/purchase_order_model.dart';
import 'package:caffenio/shared/models/recipe_model.dart';
import 'package:caffenio/shared/models/supplier_model.dart';
import 'package:uuid/uuid.dart';

class StockAutomationService {
  final GetInventoryBySucursalAndIngredient getInventoryBySucursalAndIngredient;
  final DecrementInventoryStock decrementInventoryStock;
  final GetRecipesByProductId getRecipesByProductId;
  final WatchAllSuppliers watchAllSuppliers;
  final CreatePurchaseOrder createPurchaseOrder;

  StockAutomationService({
    required this.getInventoryBySucursalAndIngredient,
    required this.decrementInventoryStock,
    required this.getRecipesByProductId,
    required this.watchAllSuppliers,
    required this.createPurchaseOrder,
  });

  Future<void> consumeIngredientsForOrder({
    required String sucursalId,
    required String productId,
    required double quantity,
  }) async {
    final List<RecipeModel> recipe = await getRecipesByProductId(productId);
    if (recipe.isEmpty) {
      return;
    }

    for (final ingredient in recipe) {
      final inventory = await getInventoryBySucursalAndIngredient(
        sucursalId,
        ingredient.ingredientId,
      );
      if (inventory == null) {
        continue;
      }

      final decrementQuantity = ingredient.quantity * quantity;
      await decrementInventoryStock(
        inventoryId: inventory.id,
        quantity: decrementQuantity,
      );

      if (inventory.currentStock - decrementQuantity <= inventory.minStock) {
        await _createLowStockPurchaseOrder(
          sucursalId: sucursalId,
          ingredient: ingredient,
          currentInventory: inventory,
        );
      }
    }
  }

  Future<void> _createLowStockPurchaseOrder({
    required String sucursalId,
    required RecipeModel ingredient,
    required InventoryModel currentInventory,
  }) async {
    final suppliers = await watchAllSuppliers().first;
    final SupplierModel supplier = suppliers.firstWhere(
      (supplier) => supplier.isActive,
      orElse: () => SupplierModel(
        id: 'auto-supplier',
        name: 'Auto Reorder',
        contactName: 'System',
        email: 'noreply@caffenio.com',
        phone: '0000000000',
        address: 'Online',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final orderId = const Uuid().v4();
    final order = PurchaseOrderModel(
      id: orderId,
      supplierId: supplier.id,
      sucursalId: sucursalId,
      date: DateTime.now(),
      status: 'pending',
      details: [
        PurchaseOrderDetailModel(
          id: const Uuid().v4(),
          orderId: orderId,
          ingredientId: ingredient.ingredientId,
          quantity: currentInventory.minStock * 2,
          unitPrice: 0.0,
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await createPurchaseOrder(order);
  }
}
