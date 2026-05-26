import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyCardModel {
  const LoyaltyCardModel({
    required this.uid,
    required this.points,
    required this.totalEarned,
    required this.totalRedeemed,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final int points;
  final int totalEarned;
  final int totalRedeemed;
  final String level;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory LoyaltyCardModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json[FirebaseConstants.fieldCreatedAt];
    final updatedAtRaw = json[FirebaseConstants.fieldUpdatedAt];

    return LoyaltyCardModel(
      uid: json[FirebaseConstants.fieldUid] as String? ?? '',
      points:
          (json[FirebaseConstants.fieldLoyaltyPoints] as num?)?.toInt() ?? 0,
      totalEarned:
          (json[FirebaseConstants.fieldLoyaltyTotalEarned] as num?)?.toInt() ??
              0,
      totalRedeemed: (json[FirebaseConstants.fieldLoyaltyTotalRedeemed] as num?)
              ?.toInt() ??
          0,
      level: json[FirebaseConstants.fieldLoyaltyLevel] as String? ?? 'bronze',
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now(),
      updatedAt: updatedAtRaw is Timestamp
          ? updatedAtRaw.toDate()
          : DateTime.tryParse(updatedAtRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  factory LoyaltyCardModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return LoyaltyCardModel.fromJson({
      ...?doc.data(),
      FirebaseConstants.fieldUid: doc.id,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.fieldUid: uid,
      FirebaseConstants.fieldLoyaltyPoints: points,
      FirebaseConstants.fieldLoyaltyTotalEarned: totalEarned,
      FirebaseConstants.fieldLoyaltyTotalRedeemed: totalRedeemed,
      FirebaseConstants.fieldLoyaltyLevel: level,
      FirebaseConstants.fieldCreatedAt: Timestamp.fromDate(createdAt),
      FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    };
  }

  LoyaltyCardModel copyWith({
    String? uid,
    int? points,
    int? totalEarned,
    int? totalRedeemed,
    String? level,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LoyaltyCardModel(
      uid: uid ?? this.uid,
      points: points ?? this.points,
      totalEarned: totalEarned ?? this.totalEarned,
      totalRedeemed: totalRedeemed ?? this.totalRedeemed,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String resolveLevel(int points) {
    if (points >= 3000) return 'platinum';
    if (points >= 1500) return 'gold';
    if (points >= 500) return 'silver';
    return 'bronze';
  }
}
