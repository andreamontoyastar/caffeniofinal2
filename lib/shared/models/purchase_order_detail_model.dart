import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PurchaseOrderDetailModel extends Equatable {
  final String id;
  final String orderId;
  final String ingredientId;
  final double quantity;
  final double unitPrice;

  const PurchaseOrderDetailModel({
    required this.id,
    required this.orderId,
    required this.ingredientId,
    required this.quantity,
    required this.unitPrice,
  });

  factory PurchaseOrderDetailModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDetailModel(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      ingredientId: json['ingredientId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory PurchaseOrderDetailModel.fromFirestore(DocumentSnapshot doc) {
    return PurchaseOrderDetailModel.fromJson({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'ingredientId': ingredientId,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  PurchaseOrderDetailModel copyWith({
    String? id,
    String? orderId,
    String? ingredientId,
    double? quantity,
    double? unitPrice,
  }) {
    return PurchaseOrderDetailModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      ingredientId: ingredientId ?? this.ingredientId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  List<Object?> get props => [id, orderId, ingredientId, quantity, unitPrice];
}
