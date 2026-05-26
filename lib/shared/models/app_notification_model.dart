import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AppNotificationModel extends Equatable {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.read = false,
    this.orderId,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool read;
  final String? orderId;

  factory AppNotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final createdRaw = data['createdAt'];
    return AppNotificationModel(
      id: doc.id,
      title: data['title'] as String? ?? 'Notificación',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      read: data['read'] as bool? ?? false,
      orderId: data['orderId'] as String?,
      createdAt: createdRaw is Timestamp
          ? createdRaw.toDate()
          : DateTime.tryParse(createdRaw?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'read': read,
      if (orderId != null) 'orderId': orderId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [id, title, body, type, createdAt, read, orderId];
}
