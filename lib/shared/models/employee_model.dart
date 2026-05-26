import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final String uid; // mismo que el UID en users collection
  final String name;
  final String email;
  final String role; // 'customer' | 'barista' | 'admin'
  final String? sucursalId;
  final DateTime? hireDate;
  final bool isActive;

  const EmployeeModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive, this.sucursalId,
    this.hireDate,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      uid: json['uid'] as String? ?? '',
      name: json['displayName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      sucursalId: json['sucursalId'] as String?,
      hireDate: json['hireDate'] is Timestamp
          ? (json['hireDate'] as Timestamp).toDate()
          : json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  factory EmployeeModel.fromFirestore(DocumentSnapshot doc) {
    return EmployeeModel.fromJson({
      'uid': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': name,
      'email': email,
      'role': role,
      if (sucursalId != null) 'sucursalId': sucursalId,
      if (hireDate != null) 'hireDate': Timestamp.fromDate(hireDate!),
      'isActive': isActive,
    };
  }

  EmployeeModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? sucursalId,
    DateTime? hireDate,
    bool? isActive,
  }) {
    return EmployeeModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      sucursalId: sucursalId ?? this.sucursalId,
      hireDate: hireDate ?? this.hireDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props =>
      [uid, name, email, role, sucursalId, hireDate, isActive];
}
