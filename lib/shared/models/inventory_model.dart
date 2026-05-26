import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class InventoryModel extends Equatable {
  final String id;
  final String sucursalId;
  final String ingredientId;
  final double currentStock;
  final double minStock;
  final String unit;
  final DateTime lastUpdated;

  const InventoryModel({
    required this.id,
    required this.sucursalId,
    required this.ingredientId,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    required this.lastUpdated,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] as String? ?? '',
      sucursalId: json['sucursalId'] as String? ?? '',
      ingredientId: json['ingredientId'] as String? ?? '',
      currentStock: (json['currentStock'] as num?)?.toDouble() ?? 0.0,
      minStock: (json['minStock'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      lastUpdated: json['lastUpdated'] is Timestamp
          ? (json['lastUpdated'] as Timestamp).toDate()
          : DateTime.tryParse(json['lastUpdated'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  factory InventoryModel.fromFirestore(DocumentSnapshot doc) {
    return InventoryModel.fromJson({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sucursalId': sucursalId,
      'ingredientId': ingredientId,
      'currentStock': currentStock,
      'minStock': minStock,
      'unit': unit,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  InventoryModel copyWith({
    String? id,
    String? sucursalId,
    String? ingredientId,
    double? currentStock,
    double? minStock,
    String? unit,
    DateTime? lastUpdated,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      sucursalId: sucursalId ?? this.sucursalId,
      ingredientId: ingredientId ?? this.ingredientId,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sucursalId,
        ingredientId,
        currentStock,
        minStock,
        unit,
        lastUpdated,
      ];
}
