import '../entities/direct_chat.dart';
import '../entities/chat_request.dart';
import '../entities/direct_message.dart';

abstract class DirectChatRepository {
  /// Get all approved chats for a user
  Future<List<DirectChat>> getMyChats(String userId);

  /// Get all pending chat requests for a user
  Future<List<ChatRequest>> getChatRequests(String userId);

  /// Send a chat request to another user
  Future<ChatRequest> sendChatRequest({
    required String fromUserId,
    required String toUserId,
    String? message,
  });

  /// Approve a chat request
  Future<DirectChat> approveChatRequest(String requestId);

  /// Reject a chat request
  Future<void> rejectChatRequest(String requestId);

  /// Get or create a chat between two users (for mutual followers)
  Future<DirectChat> getOrCreateChat({
    required String userId1,
    required String userId2,
  });

  /// Get a specific chat by ID
  Future<DirectChat?> getChatById(String chatId);

  /// Get messages for a chat
  Future<List<DirectMessage>> getMessages(String chatId);

  /// Send a message in a chat
  Future<DirectMessage> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  });

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  });

  /// Check if a chat request exists between two users
  Future<ChatRequest?> getExistingRequest({
    required String fromUserId,
    required String toUserId,
  });
}
