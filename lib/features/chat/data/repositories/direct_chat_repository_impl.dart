import '../../domain/entities/direct_chat.dart';
import '../../domain/entities/chat_request.dart';
import '../../domain/entities/direct_message.dart';
import '../../domain/repositories/direct_chat_repository.dart';
import '../datasources/direct_chat_remote_data_source.dart';

class DirectChatRepositoryImpl implements DirectChatRepository {
  final DirectChatRemoteDataSource remoteDataSource;

  DirectChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<DirectChat>> getMyChats(String userId) {
    return remoteDataSource.getMyChats(userId);
  }

  @override
  Future<List<ChatRequest>> getChatRequests(String userId) {
    return remoteDataSource.getChatRequests(userId);
  }

  @override
  Future<ChatRequest> sendChatRequest({
    required String fromUserId,
    required String toUserId,
    String? message,
  }) {
    return remoteDataSource.sendChatRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
      message: message,
    );
  }

  @override
  Future<DirectChat> approveChatRequest(String requestId) {
    return remoteDataSource.approveChatRequest(requestId);
  }

  @override
  Future<void> rejectChatRequest(String requestId) {
    return remoteDataSource.rejectChatRequest(requestId);
  }

  @override
  Future<DirectChat> getOrCreateChat({
    required String userId1,
    required String userId2,
  }) {
    return remoteDataSource.getOrCreateChat(userId1: userId1, userId2: userId2);
  }

  @override
  Future<DirectChat?> getChatById(String chatId) {
    return remoteDataSource.getChatById(chatId);
  }

  @override
  Future<List<DirectMessage>> getMessages(String chatId) {
    return remoteDataSource.getMessages(chatId);
  }

  @override
  Future<DirectMessage> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) {
    return remoteDataSource.sendMessage(
      chatId: chatId,
      senderId: senderId,
      content: content,
    );
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) {
    return remoteDataSource.markMessagesAsRead(chatId: chatId, userId: userId);
  }

  @override
  Future<ChatRequest?> getExistingRequest({
    required String fromUserId,
    required String toUserId,
  }) {
    return remoteDataSource.getExistingRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
    );
  }
}
