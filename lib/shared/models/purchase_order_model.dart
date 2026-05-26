import 'package:caffenio/shared/models/purchase_order_detail_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PurchaseOrderModel extends Equatable {
  final String id;
  final String supplierId;
  final String sucursalId;
  final DateTime date;
  final String status; // 'pending' | 'received' | 'cancelled'
  final List<PurchaseOrderDetailModel> details;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PurchaseOrderModel({
    required this.id,
    required this.supplierId,
    required this.sucursalId,
    required this.date,
    required this.status,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderModel(
      id: json['id'] as String? ?? '',
      supplierId: json['supplierId'] as String? ?? '',
      sucursalId: json['sucursalId'] as String? ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      details: (json['details'] as List<dynamic>?)
              ?.map((item) => PurchaseOrderDetailModel.fromJson(
                  item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  factory PurchaseOrderModel.fromFirestore(DocumentSnapshot doc) {
    return PurchaseOrderModel.fromJson({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierId': supplierId,
      'sucursalId': sucursalId,
      'date': Timestamp.fromDate(date),
      'status': status,
      'details': details.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PurchaseOrderModel copyWith({
    String? id,
    String? supplierId,
    String? sucursalId,
    DateTime? date,
    String? status,
    List<PurchaseOrderDetailModel>? details,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrderModel(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      sucursalId: sucursalId ?? this.sucursalId,
      date: date ?? this.date,
      status: status ?? this.status,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        supplierId,
        sucursalId,
        date,
        status,
        details,
        createdAt,
        updatedAt,
      ];
}
