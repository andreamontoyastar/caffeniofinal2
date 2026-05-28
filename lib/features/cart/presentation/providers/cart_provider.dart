import 'package:flutter/material.dart';
import '../../../../shared/models/cart_item_model.dart';
import '../../../../shared/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get total => subtotal; // Aquí se sumará el IVA o restarán cupones más adelante

  void addItem({
    required ProductModel product,
    required int quantity,
    required CustomizationOption selectedSize,
    required List<CustomizationOption> selectedExtras,
    CustomizationOption? selectedMilk,
  }) {
    // Calcular precio unitario con personalizaciones
    final double extraCost = selectedSize.priceExtra +
        (selectedMilk != null ? selectedMilk.priceExtra : 0.0) +
        selectedExtras.fold(0.0, (sum, ext) => sum + ext.priceExtra);
    
    final double unitPrice = product.price + extraCost;
    final double itemSubtotal = unitPrice * quantity;

    // Generar un ID único basado en la combinación para agrupar duplicados idénticos
    final String mixId = '${product.id}_${selectedSize.name}_${selectedMilk?.name ?? "none"}_${selectedExtras.map((e) => e.name).join("-")}';

    final int index = _items.indexWhere((item) => item.id == mixId);

    if (index >= 0) {
      // Si ya existe un producto exactamente igual, incrementamos cantidad y subtotal
      final int newQuantity = _items[index].quantity + quantity;
      _items[index] = _items[index].copyWith(
        quantity: newQuantity,
        subtotal: unitPrice * newQuantity,
      );
    } else {
      // Si es nuevo o varía en un extra, se agrega como línea independiente
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
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
