import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'cart_item_model.dart';

/// Estado del pedido a lo largo de su ciclo de vida.
enum OrderStatus {
  pending,
  preparing,
  ready,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.preparing:
        return 'Preparando';
      case OrderStatus.ready:
        return 'Listo';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  static OrderStatus fromFirestoreValue(String? raw) {
    switch (raw) {
      case 'confirmed':
        return OrderStatus.pending;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}

/// Tipo de entrega seleccionado por el usuario en checkout.
enum DeliveryType {
  pickup,
  delivery;

  String get label {
    switch (this) {
      case DeliveryType.pickup:
        return 'Para recoger';
      case DeliveryType.delivery:
        return 'A domicilio';
    }
  }
}

/// Método de pago seleccionado por el usuario en checkout.
enum PaymentMethod {
  cash,
  card,
  wallet;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.wallet:
        return 'Monedero Caffenio';
    }
  }
}

/// Representa un pedido confirmado generado desde el carrito.
class OrderModel extends Equatable {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double tax;
  final double total;
  final OrderStatus status;
  final DeliveryType deliveryType;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final String? branchId;
  final String? notes;
  final DateTime? pickupTime;
  final DateTime? estimatedReadyTime;
  final int pointsEarned;
  final int pointsRedeemed;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.deliveryType,
    required this.paymentMethod,
    required this.createdAt,
    this.branchId,
    this.notes,
    this.pickupTime,
    this.estimatedReadyTime,
    this.pointsEarned = 0,
    this.pointsRedeemed = 0,
  });

  /// Genera el folio legible para mostrar en pantalla, ej. "ORD-2024-0001"
  String get displayId {
    final year = createdAt.year;
    final seq = id.substring(id.length - 4).toUpperCase();
    return 'ORD-$year-$seq';
  }

  String get statusLabel => status.label;

  String get paymentMethodLabel => paymentMethod.label;

  int get itemsCount => items.length;

  String get dateLabel {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json[FirebaseConstants.fieldCreatedAt];
    final createdAt = rawCreatedAt is Timestamp
        ? rawCreatedAt.toDate()
        : DateTime.tryParse(rawCreatedAt?.toString() ?? '') ?? DateTime.now();

    final rawPickupTime = json[FirebaseConstants.fieldOrderPickupTime];
    final pickupTime = rawPickupTime is Timestamp
        ? rawPickupTime.toDate()
        : DateTime.tryParse(rawPickupTime?.toString() ?? '');

    final rawEstimatedReadyTime =
        json[FirebaseConstants.fieldOrderEstimatedTime];
    final estimatedReadyTime = rawEstimatedReadyTime is Timestamp
        ? rawEstimatedReadyTime.toDate()
        : DateTime.tryParse(rawEstimatedReadyTime?.toString() ?? '');

    return OrderModel(
      id: json[FirebaseConstants.fieldUid] as String? ?? '',
      userId: json[FirebaseConstants.fieldOrderUserId] as String? ?? '',
      items: _parseItems(json['items']),
      subtotal:
          (json[FirebaseConstants.fieldOrderSubtotal] as num?)?.toDouble() ??
              0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total:
          (json[FirebaseConstants.fieldOrderTotal] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromFirestoreValue(
        json[FirebaseConstants.fieldOrderStatus] as String?,
      ),
      deliveryType: DeliveryType.values.firstWhere(
        (type) => type.name == json['deliveryType'],
        orElse: () => DeliveryType.pickup,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (method) =>
            method.name == json[FirebaseConstants.fieldOrderPaymentMethod],
        orElse: () => PaymentMethod.card,
      ),
      createdAt: createdAt,
      branchId: json[FirebaseConstants.fieldOrderBranchId] as String?,
      notes: json[FirebaseConstants.fieldOrderNotes] as String?,
      pickupTime: pickupTime,
      estimatedReadyTime: estimatedReadyTime,
      pointsEarned:
          (json[FirebaseConstants.fieldOrderPointsEarned] as num?)?.toInt() ??
              0,
      pointsRedeemed:
          (json[FirebaseConstants.fieldOrderPointsRedeemed] as num?)?.toInt() ??
              0,
    );
  }

  factory OrderModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return OrderModel.fromJson({
      ...?doc.data(),
      FirebaseConstants.fieldUid: doc.id,
    });
  }

  static List<CartItemModel> _parseItems(dynamic raw) {
    if (raw is! List) return const [];
    final items = <CartItemModel>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      try {
        final map = Map<String, dynamic>.from(entry);
        items.add(CartItemModel.fromMap(map));
      } catch (_) {
        // Omite ítems corruptos sin tumbar el historial completo.
      }
    }
    return items;
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    double? subtotal,
    double? tax,
    double? total,
    OrderStatus? status,
    DeliveryType? deliveryType,
    PaymentMethod? paymentMethod,
    DateTime? createdAt,
    String? branchId,
    String? notes,
    DateTime? pickupTime,
    DateTime? estimatedReadyTime,
    int? pointsEarned,
    int? pointsRedeemed,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      deliveryType: deliveryType ?? this.deliveryType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      branchId: branchId ?? this.branchId,
      notes: notes ?? this.notes,
      pickupTime: pickupTime ?? this.pickupTime,
      estimatedReadyTime: estimatedReadyTime ?? this.estimatedReadyTime,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      pointsRedeemed: pointsRedeemed ?? this.pointsRedeemed,
    );
  }

  Map<String, dynamic> toMap({required String userId}) {
    return {
      'userId': userId,
      'status': status.name,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'deliveryType': deliveryType.name,
      'paymentMethod': paymentMethod.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'items': items.map((item) => item.toMap()).toList(),
      if (branchId != null) FirebaseConstants.fieldOrderBranchId: branchId,
      if (notes != null) FirebaseConstants.fieldOrderNotes: notes,
      if (pickupTime != null)
        FirebaseConstants.fieldOrderPickupTime: Timestamp.fromDate(pickupTime!),
      if (estimatedReadyTime != null)
        FirebaseConstants.fieldOrderEstimatedTime:
            Timestamp.fromDate(estimatedReadyTime!),
      FirebaseConstants.fieldOrderPointsEarned: pointsEarned,
      FirebaseConstants.fieldOrderPointsRedeemed: pointsRedeemed,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        subtotal,
        tax,
        total,
        status,
        deliveryType,
        paymentMethod,
        createdAt,
        branchId,
        notes,
        pickupTime,
        estimatedReadyTime,
        pointsEarned,
        pointsRedeemed,
      ];
}
