import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RecipeModel extends Equatable {
  final String id;
  final String productId;
  final String ingredientId;
  final double quantity;

  const RecipeModel({
    required this.id,
    required this.productId,
    required this.ingredientId,
    required this.quantity,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      ingredientId: json['ingredientId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    return RecipeModel.fromJson({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'ingredientId': ingredientId,
      'quantity': quantity,
    };
  }

  RecipeModel copyWith({
    String? id,
    String? productId,
    String? ingredientId,
    double? quantity,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      ingredientId: ingredientId ?? this.ingredientId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, productId, ingredientId, quantity];
}
