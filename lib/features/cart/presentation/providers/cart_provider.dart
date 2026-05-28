import 'package:flutter/material.dart';
import '../../../../shared/models/cart_item_model.dart';
import '../../../../shared/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  final Set<String> _selectedItemIds = {};

  List<CartItemModel> get items => _items;

  Set<String> get selectedItemIds => _selectedItemIds;

  List<CartItemModel> get selectedItems =>
      _items.where((item) => _selectedItemIds.contains(item.id)).toList();

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get selectedItemCount => _items
      .where((item) => _selectedItemIds.contains(item.id))
      .fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get selectedSubtotal => _items
      .where((item) => _selectedItemIds.contains(item.id))
      .fold(0.0, (sum, item) => sum + item.subtotal);

  double get total => subtotal;

  bool isSelected(String itemId) => _selectedItemIds.contains(itemId);

  void toggleSelection(String itemId) {
    if (_selectedItemIds.contains(itemId)) {
      _selectedItemIds.remove(itemId);
    } else {
      _selectedItemIds.add(itemId);
    }
    notifyListeners();
  }

  void selectAll(bool select) {
    if (select) {
      _selectedItemIds.addAll(_items.map((item) => item.id));
    } else {
      _selectedItemIds.clear();
    }
    notifyListeners();
  }

  void addItem({
    required ProductModel product,
    required int quantity,
    required CustomizationOption selectedSize,
    required List<CustomizationOption> selectedExtras,
    CustomizationOption? selectedMilk,
  }) {
    final double extraCost = selectedSize.priceExtra +
        (selectedMilk != null ? selectedMilk.priceExtra : 0.0) +
        selectedExtras.fold(0.0, (sum, ext) => sum + ext.priceExtra);
    
    final double unitPrice = product.price + extraCost;
    final double itemSubtotal = unitPrice * quantity;

    final String mixId = '${product.id}_${selectedSize.name}_${selectedMilk?.name ?? "none"}_${selectedExtras.map((e) => e.name).join("-")}';

    final int index = _items.indexWhere((item) => item.id == mixId);

    if (index >= 0) {
      final int newQuantity = _items[index].quantity + quantity;
      _items[index] = _items[index].copyWith(
        quantity: newQuantity,
        subtotal: unitPrice * newQuantity,
      );
    } else {
      _items.add(
        CartItemModel(
          id: mixId,
          product: product,
          quantity: quantity,
          selectedSize: selectedSize,
          selectedMilk: selectedMilk,
          selectedExtras: selectedExtras,
          subtotal: itemSubtotal,
        ),
      );
    }
    // Auto-select newly added items
    _selectedItemIds.add(mixId);
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _selectedItemIds.remove(itemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _selectedItemIds.clear();
    notifyListeners();
  }

  void clearSelectedItems() {
    _items.removeWhere((item) => _selectedItemIds.contains(item.id));
    _selectedItemIds.clear();
    notifyListeners();
  }
}
