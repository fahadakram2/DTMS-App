import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotificationToUser({
    required String recipientId,
    required String senderId,
    required String senderName,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'recipientUid': recipientId, // ✅ fixed field name
        'senderId': senderId,
        'senderName': senderName,
        'title': title,
        'message': message,
        'type': type,
        'timestamp': Timestamp.now(),
        'isRead': false,
      });
    } catch (e) {
      print('❌ Failed to send notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }
}
