import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/direct_chat.dart';
import '../../domain/entities/chat_request.dart';
import '../../domain/entities/direct_message.dart';

abstract class DirectChatRemoteDataSource {
  Future<List<DirectChat>> getMyChats(String userId);
  Future<List<ChatRequest>> getChatRequests(String userId);
  Future<ChatRequest> sendChatRequest({
    required String fromUserId,
    required String toUserId,
    String? message,
  });
  Future<DirectChat> approveChatRequest(String requestId);
  Future<void> rejectChatRequest(String requestId);
  Future<DirectChat> getOrCreateChat({
    required String userId1,
    required String userId2,
  });
  Future<DirectChat?> getChatById(String chatId);
  Future<List<DirectMessage>> getMessages(String chatId);
  Future<DirectMessage> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  });
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  });
  Future<ChatRequest?> getExistingRequest({
    required String fromUserId,
    required String toUserId,
  });
}

class DirectChatRemoteDataSourceImpl implements DirectChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  DirectChatRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<DirectChat>> getMyChats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('direct_chats')
          .where('participantIds', arrayContains: userId)
          .where('status', isEqualTo: 'APPROVED')
          // .orderBy('updatedAt', descending: true) // Removed to avoid index error
          .get();

      final chats = snapshot.docs
          .map((doc) => _chatFromFirestore(doc))
          .toList();
      chats.sort((a, b) {
        // Sort by last message time if available, or updated at
        final aTime = a.lastMessageTime ?? DateTime(2000);
        final bTime = b.lastMessageTime ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      return chats;
    } catch (e) {
      throw Exception('Failed to get chats: $e');
    }
  }

  @override
  Future<List<ChatRequest>> getChatRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chat_requests')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'PENDING')
          // .orderBy('createdAt', descending: true) // Removed to avoid index error
          .get();

      return snapshot.docs.map((doc) => _requestFromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get chat requests: $e');
    }
  }

  @override
  Future<ChatRequest> sendChatRequest({
    required String fromUserId,
    required String toUserId,
    String? message,
  }) async {
    try {
      final requestRef = _firestore.collection('chat_requests').doc();

      await requestRef.set({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'message': message,
        'status': 'PENDING',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return ChatRequest(
        id: requestRef.id,
        fromUserId: fromUserId,
        toUserId: toUserId,
        message: message,
        status: ChatRequestStatus.pending,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to send chat request: $e');
    }
  }

  @override
  Future<DirectChat> approveChatRequest(String requestId) async {
    try {
      // Update request status
      await _firestore.collection('chat_requests').doc(requestId).update({
        'status': 'APPROVED',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Cloud Function will create the chat room
      // For now, wait a bit and fetch the chat
      await Future.delayed(const Duration(milliseconds: 500));

      final requestDoc = await _firestore
          .collection('chat_requests')
          .doc(requestId)
          .get();
      final requestData = requestDoc.data()!;

      // Find the chat created by Cloud Function
      final chatSnapshot = await _firestore
          .collection('direct_chats')
          .where('participantIds', arrayContains: requestData['fromUserId'])
          .where('requestedBy', isEqualTo: requestData['fromUserId'])
          .limit(1)
          .get();

      if (chatSnapshot.docs.isNotEmpty) {
        return _chatFromFirestore(chatSnapshot.docs.first);
      }

      throw Exception('Chat not created yet');
    } catch (e) {
      throw Exception('Failed to approve chat request: $e');
    }
  }

  @override
  Future<void> rejectChatRequest(String requestId) async {
    try {
      await _firestore.collection('chat_requests').doc(requestId).update({
        'status': 'REJECTED',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reject chat request: $e');
    }
  }

  @override
  Future<DirectChat> getOrCreateChat({
    required String userId1,
    required String userId2,
  }) async {
    try {
      // Check if chat already exists
      final existingSnapshot = await _firestore
          .collection('direct_chats')
          .where('participantIds', arrayContains: userId1)
          .get();

      for (final doc in existingSnapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participantIds']);
        if (participants.contains(userId2)) {
          return _chatFromFirestore(doc);
        }
      }

      // Create new chat (for mutual followers)
      final chatRef = _firestore.collection('direct_chats').doc();

      await chatRef.set({
        'chatId': chatRef.id,
        'participantIds': [userId1, userId2],
        'status': 'APPROVED',
        'requestedBy': userId1,
        'unreadCount': {userId1: 0, userId2: 0},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return DirectChat(
        id: chatRef.id,
        participantIds: [userId1, userId2],
        status: ChatStatus.approved,
        requestedBy: userId1,
        unreadCount: {userId1: 0, userId2: 0},
      );
    } catch (e) {
      throw Exception('Failed to get or create chat: $e');
    }
  }

  @override
  Future<DirectChat?> getChatById(String chatId) async {
    try {
      final doc = await _firestore.collection('direct_chats').doc(chatId).get();

      if (!doc.exists) {
        return null;
      }

      return _chatFromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  @override
  Future<List<DirectMessage>> getMessages(String chatId) async {
    try {
      final snapshot = await _firestore
          .collection('chat_messages')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map((doc) => _messageFromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Future<DirectMessage> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    try {
      final messageRef = _firestore
          .collection('chat_messages')
          .doc(chatId)
          .collection('messages')
          .doc();

      await messageRef.set({
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Cloud Function will update chat metadata and send FCM

      return DirectMessage(
        id: messageRef.id,
        chatId: chatId,
        senderId: senderId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      // Update unread count in chat document
      await _firestore.collection('direct_chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });

      // Mark messages as read
      final messagesSnapshot = await _firestore
          .collection('chat_messages')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  @override
  Future<ChatRequest?> getExistingRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('chat_requests')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'PENDING')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return _requestFromFirestore(snapshot.docs.first);
    } catch (e) {
      return null;
    }
  }

  DirectChat _chatFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DirectChat(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds']),
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
      status: data['status'] == 'APPROVED'
          ? ChatStatus.approved
          : data['status'] == 'PENDING'
          ? ChatStatus.pending
          : ChatStatus.rejected,
      requestedBy: data['requestedBy'] ?? '',
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }

  ChatRequest _requestFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatRequest(
      id: doc.id,
      fromUserId: data['fromUserId'],
      toUserId: data['toUserId'],
      message: data['message'],
      status: data['status'] == 'APPROVED'
          ? ChatRequestStatus.approved
          : data['status'] == 'PENDING'
          ? ChatRequestStatus.pending
          : ChatRequestStatus.rejected,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  DirectMessage _messageFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DirectMessage(
      id: doc.id,
      chatId: data['chatId'],
      senderId: data['senderId'],
      content: data['content'],
      timestamp: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }
}
