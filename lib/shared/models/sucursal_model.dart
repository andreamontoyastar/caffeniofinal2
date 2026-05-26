import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SucursalModel extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String schedule;
  final double lat;
  final double lng;
  final bool isActive;
  final List<String> employees; // UIDs de empleados
  final DateTime createdAt;
  final DateTime updatedAt;

  const SucursalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.schedule,
    required this.lat,
    required this.lng,
    required this.isActive,
    required this.employees,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SucursalModel.fromJson(Map<String, dynamic> json) {
    return SucursalModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      schedule: json['schedule'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      employees: List<String>.from(json['employees'] as List? ?? []),
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

  factory SucursalModel.fromFirestore(DocumentSnapshot doc) {
    return SucursalModel.fromJson({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'phone': phone,
      'schedule': schedule,
      'lat': lat,
      'lng': lng,
      'isActive': isActive,
      'employees': employees,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SucursalModel copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? phone,
    String? schedule,
    double? lat,
    double? lng,
    bool? isActive,
    List<String>? employees,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SucursalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      schedule: schedule ?? this.schedule,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isActive: isActive ?? this.isActive,
      employees: employees ?? this.employees,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        phone,
        schedule,
        lat,
        lng,
        isActive,
        employees,
        createdAt,
        updatedAt,
      ];
}
