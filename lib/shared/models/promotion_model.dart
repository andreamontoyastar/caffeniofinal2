import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PromotionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? bannerUrl;
  final String type; // 'percentage' | 'fixed' | '2x1' | 'free_item'
  final double value;
  final double? minPurchase;
  final List<String> applicableProducts; // empty = todos
  final String? code; // cupón
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int? usageLimit;
  final int usageCount;
  final DateTime createdAt;

  const PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type, required this.value, required this.applicableProducts, required this.startDate, required this.endDate, required this.isActive, required this.usageCount, required this.createdAt, this.bannerUrl,
    this.minPurchase,
    this.code,
    this.usageLimit,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bannerUrl: json['bannerUrl'] as String?,
      type: json['type'] as String? ?? 'percentage',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      minPurchase: (json['minPurchase'] as num?)?.toDouble(),
      applicableProducts:
          List<String>.from(json['applicableProducts'] as List? ?? []),
      code: json['code'] as String?,
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['startDate'] as String? ?? '') ??
              DateTime.now(),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['endDate'] as String? ?? '') ??
              DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      usageLimit: json['usageLimit'] as int?,
      usageCount: json['usageCount'] as int? ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  factory PromotionModel.fromFirestore(DocumentSnapshot doc) {
    return PromotionModel.fromJson({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      if (bannerUrl != null) 'bannerUrl': bannerUrl,
      'type': type,
      'value': value,
      if (minPurchase != null) 'minPurchase': minPurchase,
      'applicableProducts': applicableProducts,
      if (code != null) 'code': code,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      if (usageLimit != null) 'usageLimit': usageLimit,
      'usageCount': usageCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PromotionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? bannerUrl,
    String? type,
    double? value,
    double? minPurchase,
    List<String>? applicableProducts,
    String? code,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? usageLimit,
    int? usageCount,
    DateTime? createdAt,
  }) {
    return PromotionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      type: type ?? this.type,
      value: value ?? this.value,
      minPurchase: minPurchase ?? this.minPurchase,
      applicableProducts: applicableProducts ?? this.applicableProducts,
      code: code ?? this.code,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        bannerUrl,
        type,
        value,
        minPurchase,
        applicableProducts,
        code,
        startDate,
        endDate,
        isActive,
        usageLimit,
        usageCount,
        createdAt,
      ];
}
