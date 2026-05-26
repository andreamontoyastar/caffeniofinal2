import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CustomizationOption extends Equatable {
  final String name;
  final double priceExtra;

  const CustomizationOption({
    required this.name,
    required this.priceExtra,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      name: json['name'] as String? ?? '',
      priceExtra: (json['priceExtra'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'priceExtra': priceExtra,
    };
  }

  @override
  List<Object?> get props => [name, priceExtra];
}

class ProductModel extends Equatable {
  static const String githubImageBaseUrl =
      'https://raw.githubusercontent.com/montoya06470/Imagenes-para-flutter-6to-I-fecha-11-feb-2026/refs/heads/main';

  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String categoryId;
  final int preparationTimeMinutes;
  final List<CustomizationOption> sizes;
  final List<CustomizationOption> milkTypes;
  final List<CustomizationOption> extras;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.preparationTimeMinutes,
    required this.sizes,
    required this.milkTypes,
    required this.extras,
    this.imageUrl,
  });

  String get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!;
    }
    // Fallback to a high-quality coffee image hosted on Unsplash
    return 'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=800&q=80';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        categoryId,
        preparationTimeMinutes,
        imageUrl,
        sizes,
        milkTypes,
        extras,
      ];

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['categoryId'] as String? ?? 'general',
      preparationTimeMinutes:
          (json['preparationTimeMinutes'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String?,
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((item) => CustomizationOption.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const [],
      milkTypes: (json['milkTypes'] as List<dynamic>?)
              ?.map((item) => CustomizationOption.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const [],
      extras: (json['extras'] as List<dynamic>?)
              ?.map((item) => CustomizationOption.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const [],
    );
  }

  factory ProductModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ProductModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'preparationTimeMinutes': preparationTimeMinutes,
      'imageUrl': imageUrl,
      'sizes': sizes.map((option) => option.toJson()).toList(),
      'milkTypes': milkTypes.map((option) => option.toJson()).toList(),
      'extras': extras.map((option) => option.toJson()).toList(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    int? preparationTimeMinutes,
    String? imageUrl,
    List<CustomizationOption>? sizes,
    List<CustomizationOption>? milkTypes,
    List<CustomizationOption>? extras,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      sizes: sizes ?? this.sizes,
      milkTypes: milkTypes ?? this.milkTypes,
      extras: extras ?? this.extras,
    );
  }

  // Helper static mock data for Catalog
  static const List<ProductModel> mockProducts = [
    ProductModel(
      id: '1',
      name: 'Café Americano',
      description:
          'Café negro clásico elaborado con granos seleccionados de la casa, suave y aromático.',
      price: 35.0,
      categoryId: 'bebidas-calientes',
      preparationTimeMinutes: 4,
      imageUrl: '$githubImageBaseUrl/americano.png',
      sizes: [
        CustomizationOption(name: 'Chico', priceExtra: 0.0),
        CustomizationOption(name: 'Mediano', priceExtra: 5.0),
        CustomizationOption(name: 'Grande', priceExtra: 10.0),
      ],
      milkTypes: [],
      extras: [
        CustomizationOption(name: 'Shot Extra de Espresso', priceExtra: 12.0),
        CustomizationOption(name: 'Endulzante Splenda', priceExtra: 0.0),
      ],
    ),
    ProductModel(
      id: '2',
      name: 'Capuchino Clásico',
      description:
          'Equilibrio perfecto de espresso robusto, leche vaporizada y abundante espuma cremosa.',
      price: 45.0,
      categoryId: 'bebidas-calientes',
      preparationTimeMinutes: 6,
      imageUrl: '$githubImageBaseUrl/capuchino.png',
      sizes: [
        CustomizationOption(name: 'Chico', priceExtra: 0.0),
        CustomizationOption(name: 'Mediano', priceExtra: 6.0),
        CustomizationOption(name: 'Grande', priceExtra: 12.0),
      ],
      milkTypes: [
        CustomizationOption(name: 'Leche Regular', priceExtra: 0.0),
        CustomizationOption(name: 'Leche Deslactosada', priceExtra: 5.0),
        CustomizationOption(name: 'Leche de Almendra', priceExtra: 8.0),
        CustomizationOption(name: 'Leche de Soya', priceExtra: 8.0),
      ],
      extras: [
        CustomizationOption(name: 'Shot Extra de Espresso', priceExtra: 12.0),
        CustomizationOption(name: 'Canela en Polvo', priceExtra: 0.0),
        CustomizationOption(name: 'Jarabe de Vainilla', priceExtra: 7.0),
      ],
    ),
    ProductModel(
      id: '3',
      name: 'Latte Frío Caramel',
      description:
          'Bebida helada de café con leche cremosa y un toque dulce de jarabe de caramelo premium.',
      price: 49.0,
      categoryId: 'bebidas-frias',
      preparationTimeMinutes: 7,
      imageUrl: '$githubImageBaseUrl/cafe1.png',
      sizes: [
        CustomizationOption(name: 'Chico', priceExtra: 0.0),
        CustomizationOption(name: 'Mediano', priceExtra: 6.0),
        CustomizationOption(name: 'Grande', priceExtra: 12.0),
      ],
      milkTypes: [
        CustomizationOption(name: 'Leche Regular', priceExtra: 0.0),
        CustomizationOption(name: 'Leche Deslactosada', priceExtra: 5.0),
        CustomizationOption(name: 'Leche de Almendra', priceExtra: 8.0),
      ],
      extras: [
        CustomizationOption(name: 'Salsa de Caramelo Extra', priceExtra: 8.0),
        CustomizationOption(name: 'Shot Extra de Espresso', priceExtra: 12.0),
      ],
    ),
    ProductModel(
      id: '4',
      name: 'Café Moka',
      description:
          'Una deliciosa combinación de rico chocolate amargo, café espresso y leche vaporizada.',
      price: 48.0,
      categoryId: 'bebidas-calientes',
      preparationTimeMinutes: 6,
      imageUrl: '$githubImageBaseUrl/cafe2.png',
      sizes: [
        CustomizationOption(name: 'Chico', priceExtra: 0.0),
        CustomizationOption(name: 'Mediano', priceExtra: 8.0),
        CustomizationOption(name: 'Grande', priceExtra: 15.0),
      ],
      milkTypes: [
        CustomizationOption(name: 'Leche Regular', priceExtra: 0.0),
        CustomizationOption(name: 'Leche Deslactosada', priceExtra: 5.0),
        CustomizationOption(name: 'Leche de Almendra', priceExtra: 8.0),
      ],
      extras: [
        CustomizationOption(name: 'Crema Batida', priceExtra: 8.0),
        CustomizationOption(name: 'Chispas de Chocolate', priceExtra: 5.0),
        CustomizationOption(name: 'Shot Extra de Espresso', priceExtra: 12.0),
      ],
    ),
    ProductModel(
      id: '5',
      name: 'K\'Freeze Caramelo',
      description:
          'Nuestra bebida congelada con base cremosa y listones de caramelo premium.',
      price: 55.0,
      categoryId: 'bebidas-frias',
      preparationTimeMinutes: 8,
      imageUrl: '$githubImageBaseUrl/cafe3.png',
      sizes: [
        CustomizationOption(name: 'Mediano', priceExtra: 0.0),
        CustomizationOption(name: 'Grande', priceExtra: 14.0),
      ],
      milkTypes: [
        CustomizationOption(name: 'Leche Entera', priceExtra: 0.0),
        CustomizationOption(name: 'Leche Deslactosada', priceExtra: 5.0),
      ],
      extras: [
        CustomizationOption(name: 'Crema Batida', priceExtra: 10.0),
        CustomizationOption(name: 'Chispas de Chocolate', priceExtra: 7.0),
      ],
    ),
    ProductModel(
      id: '6',
      name: 'K\'Freeze Moka Intenso',
      description:
          'Fusión helada de café espresso y jarabe de chocolate semi-amargo.',
      price: 58.0,
      categoryId: 'bebidas-frias',
      preparationTimeMinutes: 9,
      imageUrl: '$githubImageBaseUrl/cafe4.png',
      sizes: [
        CustomizationOption(name: 'Mediano', priceExtra: 0.0),
        CustomizationOption(name: 'Grande', priceExtra: 14.0),
      ],
      milkTypes: [
        CustomizationOption(name: 'Leche Entera', priceExtra: 0.0),
        CustomizationOption(name: 'Leche Deslactosada', priceExtra: 5.0),
      ],
      extras: [
        CustomizationOption(name: 'Extra Jarabe de Chocolate', priceExtra: 8.0),
        CustomizationOption(name: 'Crema Batida', priceExtra: 10.0),
      ],
    ),
  ];
}
