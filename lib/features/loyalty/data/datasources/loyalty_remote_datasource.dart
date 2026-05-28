import 'package:caffenio/core/constants/app_constants.dart';
import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/features/loyalty/data/models/loyalty_card_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class LoyaltyRemoteDataSource {
  Stream<LoyaltyCardModel?> watchLoyaltyCard(String uid);
  Future<void> updateLoyaltyPoints({
    required String uid,
    required int pointsEarned,
  });
}

class LoyaltyRemoteDataSourceImpl implements LoyaltyRemoteDataSource {
  LoyaltyRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _loyaltyRef =>
      _firestore.collection(FirebaseConstants.loyaltyCardsCollection);

  DocumentReference<Map<String, dynamic>> _legacyRef(String uid) =>
      _firestore.collection(FirebaseConstants.loyaltyLegacyCollection).doc(uid);

  @override
  Stream<LoyaltyCardModel?> watchLoyaltyCard(String uid) {
    return _loyaltyRef.doc(uid).snapshots().asyncMap((doc) async {
      if (doc.exists && doc.data() != null) {
        return LoyaltyCardModel.fromFirestore(doc);
      }

      final legacy = await _legacyRef(uid).get();
      if (!legacy.exists || legacy.data() == null) return null;

      final card = LoyaltyCardModel.fromFirestore(legacy);
      await _loyaltyRef.doc(uid).set(legacy.data()!, SetOptions(merge: true));
      return card;
    });
  }

  @override
  Future<void> updateLoyaltyPoints({
    required String uid,
    required int pointsEarned,
  }) async {
    final docRef = _loyaltyRef.doc(uid);

    final snapshot = await docRef.get();
    if (!snapshot.exists || snapshot.data() == null) {
      await docRef.set({
        FirebaseConstants.fieldUid: uid,
        FirebaseConstants.fieldLoyaltyPoints: pointsEarned,
        FirebaseConstants.fieldLoyaltyTotalEarned: pointsEarned,
        FirebaseConstants.fieldLoyaltyTotalRedeemed: 0,
        FirebaseConstants.fieldLoyaltyLevel:
            LoyaltyCardModel.resolveLevel(pointsEarned),
        FirebaseConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
        FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    final currentData = snapshot.data()!;
    final currentPoints =
        (currentData[FirebaseConstants.fieldLoyaltyPoints] as num?)?.toInt() ??
            0;
    final currentTotalEarned =
        (currentData[FirebaseConstants.fieldLoyaltyTotalEarned] as num?)
                ?.toInt() ??
            0;
    final updatedTotalPoints = currentPoints + pointsEarned;
    final updatedTotalEarned = currentTotalEarned + pointsEarned;

    await docRef.set({
      FirebaseConstants.fieldLoyaltyPoints: updatedTotalPoints,
      FirebaseConstants.fieldLoyaltyTotalEarned: updatedTotalEarned,
      FirebaseConstants.fieldLoyaltyLevel:
          LoyaltyCardModel.resolveLevel(updatedTotalPoints),
      FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Tarjeta inicial según plan: 0 puntos al registrarse.
  Future<void> ensureWelcomeCard(String uid) async {
    final docRef = _loyaltyRef.doc(uid);
    final snapshot = await docRef.get();
    if (snapshot.exists) return;

    final legacy = await _legacyRef(uid).get();
    if (legacy.exists) {
      await docRef.set(legacy.data()!, SetOptions(merge: true));
      return;
    }

    await docRef.set({
      FirebaseConstants.fieldUid: uid,
      FirebaseConstants.fieldLoyaltyPoints: AppConstants.welcomeBonusPoints,
      FirebaseConstants.fieldLoyaltyTotalEarned: AppConstants.welcomeBonusPoints,
      FirebaseConstants.fieldLoyaltyTotalRedeemed: 0,
      FirebaseConstants.fieldLoyaltyLevel:
          LoyaltyCardModel.resolveLevel(AppConstants.welcomeBonusPoints),
      FirebaseConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
      FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
    });
  }
}
