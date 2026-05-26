import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItemModel extends Equatable {
  final String id;
  final ProductModel product;
  final int quantity;
  final CustomizationOption selectedSize;
  final CustomizationOption? selectedMilk;
  final List<CustomizationOption> selectedExtras;
  final double subtotal;

  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedExtras,
    required this.subtotal,
    this.selectedMilk,
  });

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    CustomizationOption? selectedSize,
    CustomizationOption? selectedMilk,
    List<CustomizationOption>? selectedExtras,
    double? subtotal,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedMilk: selectedMilk ?? this.selectedMilk,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  /// Ítems guardados en pedidos de Firestore (formato denormalizado de [toMap]).
  factory CartItemModel.fromOrderItemMap(Map<String, dynamic> json) {
    final productId = json['productId'] as String? ?? json['id'] as String? ?? '';
    final product = ProductModel(
      id: productId,
      name: json['productName'] as String? ?? 'Producto',
      description: '',
      price: (json['productPrice'] as num?)?.toDouble() ?? 0,
      categoryId: 'general',
      preparationTimeMinutes: 0,
      sizes: const [],
      milkTypes: const [],
      extras: const [],
      imageUrl: json['productImageUrl'] as String?,
    );

    final sizeMap = json['selectedSize'];
    final milkMap = json['selectedMilk'];
    final extrasRaw = json['selectedExtras'];

    return CartItemModel(
      id: json['id'] as String? ?? productId,
      product: product,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      selectedSize: sizeMap is Map
          ? CustomizationOption.fromJson(Map<String, dynamic>.from(sizeMap))
          : const CustomizationOption(name: 'Mediano', priceExtra: 0),
      selectedMilk: milkMap is Map
          ? CustomizationOption.fromJson(Map<String, dynamic>.from(milkMap))
          : null,
      selectedExtras: extrasRaw is List
          ? extrasRaw
              .map((e) => CustomizationOption.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : const [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> json) {
    if (json.containsKey('productName') && !json.containsKey('product')) {
      return CartItemModel.fromOrderItemMap(json);
    }
    return CartItemModel(
      id: json['id'] as String? ?? '',
      product: ProductModel.fromJson(
        Map<String, dynamic>.from(
            json['product'] as Map<String, dynamic>? ?? {}),
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      selectedSize: CustomizationOption.fromJson(
        Map<String, dynamic>.from(
            json['selectedSize'] as Map<String, dynamic>? ?? {}),
      ),
      selectedMilk: json['selectedMilk'] != null
          ? CustomizationOption.fromJson(
              Map<String, dynamic>.from(
                  json['selectedMilk'] as Map<String, dynamic>),
            )
          : null,
      selectedExtras: (json['selectedExtras'] as List<dynamic>?)
              ?.map((item) => CustomizationOption.fromJson(
                    Map<String, dynamic>.from(item as Map<String, dynamic>),
                  ))
              .toList() ??
          const [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': product.id,
      'productName': product.name,
      'productPrice': product.price,
      'productImageUrl': product.imageUrl,
      'quantity': quantity,
      'subtotal': subtotal,
      'selectedSize': {
        'name': selectedSize.name,
        'priceExtra': selectedSize.priceExtra,
      },
      'selectedMilk': selectedMilk != null
          ? {
              'name': selectedMilk!.name,
              'priceExtra': selectedMilk!.priceExtra,
            }
          : null,
      'selectedExtras': selectedExtras
          .map((extra) => {
                'name': extra.name,
                'priceExtra': extra.priceExtra,
              })
          .toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        product,
        quantity,
        selectedSize,
        selectedMilk,
        selectedExtras,
        subtotal,
      ];
}
