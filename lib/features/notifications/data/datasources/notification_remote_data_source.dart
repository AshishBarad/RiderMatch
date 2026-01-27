import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/notification_service.dart';

abstract class NotificationRemoteDataSource {
  Future<void> createNotification(
    String targetUserId,
    AppNotification notification,
  );
  Stream<List<AppNotification>> getUserNotifications(String userId);
  Future<void> markAsRead(String userId, String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createNotification(
    String targetUserId,
    AppNotification notification,
  ) async {
    try {
      // Store in a subcollection: users/{userId}/notifications/{notificationId}
      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('notifications')
          .doc(notification.id)
          .set({
            'id': notification.id,
            'title': notification.title,
            'body': notification.body,
            'rideId': notification.rideId,
            'type': notification.type,
            'senderId': notification.senderId,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': notification.isRead,
          });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  @override
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return AppNotification(
              id: data['id'],
              title: data['title'],
              body: data['body'],
              rideId: data['rideId'],
              type: data['type'],
              senderId: data['senderId'],
              // Handle potential null or Timestamp types
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isRead: data['isRead'] ?? false,
            );
          }).toList();
        });
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}
