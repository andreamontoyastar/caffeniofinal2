import 'package:caffenio/core/constants/firebase_constants.dart';
import 'package:caffenio/shared/models/app_notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class NotificationsRemoteDataSource {
  Stream<List<AppNotificationModel>> watchForUser(String uid);
  Future<void> sendToUser({
    required String uid,
    required String title,
    required String body,
    String type = 'general',
    String? orderId,
  });
  Future<void> markAsRead(String uid, String notificationId);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _userNotifications(String uid) =>
      _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .collection(FirebaseConstants.userNotificationsSubcollection);

  @override
  Stream<List<AppNotificationModel>> watchForUser(String uid) {
    return _userNotifications(uid).snapshots().map((snapshot) {
      final list = snapshot.docs
          .map(AppNotificationModel.fromFirestore)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> sendToUser({
    required String uid,
    required String title,
    required String body,
    String type = 'general',
    String? orderId,
  }) async {
    final notification = AppNotificationModel(
      id: '',
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      orderId: orderId,
    );
    await _userNotifications(uid).add(notification.toMap());
  }

  @override
  Future<void> markAsRead(String uid, String notificationId) async {
    await _userNotifications(uid).doc(notificationId).update({'read': true});
  }
}
