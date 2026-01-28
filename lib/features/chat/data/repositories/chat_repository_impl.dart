import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> getMessages(String rideId);
  Future<void> sendMessage(ChatMessage message);
  Future<void> uploadMedia(String filePath); // Stub for now
  Future<void> deleteMessages(String rideId);
}

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ChatMessage>> getMessages(String rideId) {
    return _firestore
        .collection('rides')
        .doc(rideId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return ChatMessage.fromJson({...data, 'id': doc.id});
          }).toList();
        });
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    try {
      final docRef = _firestore
          .collection('rides')
          .doc(message.rideId)
          .collection('messages')
          .doc();

      final messageData = message.toJson();
      // Use Firestore server timestamp for consistency if possible,
      // but ChatMessage expects a DateTime. For now, keep the client timestamp
      // or map it if we really wanted server-side.

      await docRef.set({...messageData, 'id': docRef.id});
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> uploadMedia(String filePath) async {
    // Media upload logic would go here (e.g., Firebase Storage)
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> deleteMessages(String rideId) async {
    try {
      final snapshot = await _firestore
          .collection('rides')
          .doc(rideId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete messages: $e');
    }
  }
}
