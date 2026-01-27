import '../entities/direct_chat.dart';
import '../entities/chat_request.dart';
import '../entities/direct_message.dart';
import '../repositories/direct_chat_repository.dart';

class GetMyChatsUseCase {
  final DirectChatRepository repository;
  GetMyChatsUseCase(this.repository);

  Future<List<DirectChat>> call(String userId) => repository.getMyChats(userId);
}

class GetChatRequestsUseCase {
  final DirectChatRepository repository;
  GetChatRequestsUseCase(this.repository);

  Future<List<ChatRequest>> call(String userId) =>
      repository.getChatRequests(userId);
}

class SendChatRequestUseCase {
  final DirectChatRepository repository;
  SendChatRequestUseCase(this.repository);

  Future<ChatRequest> call({
    required String fromUserId,
    required String toUserId,
    String? message,
  }) => repository.sendChatRequest(
    fromUserId: fromUserId,
    toUserId: toUserId,
    message: message,
  );
}

class ApproveChatRequestUseCase {
  final DirectChatRepository repository;
  ApproveChatRequestUseCase(this.repository);

  Future<DirectChat> call(String requestId) =>
      repository.approveChatRequest(requestId);
}

class RejectChatRequestUseCase {
  final DirectChatRepository repository;
  RejectChatRequestUseCase(this.repository);

  Future<void> call(String requestId) =>
      repository.rejectChatRequest(requestId);
}

class GetOrCreateChatUseCase {
  final DirectChatRepository repository;
  GetOrCreateChatUseCase(this.repository);

  Future<DirectChat> call({required String userId1, required String userId2}) =>
      repository.getOrCreateChat(userId1: userId1, userId2: userId2);
}

class GetChatByIdUseCase {
  final DirectChatRepository repository;
  GetChatByIdUseCase(this.repository);

  Future<DirectChat?> call(String chatId) => repository.getChatById(chatId);
}

class GetMessagesUseCase {
  final DirectChatRepository repository;
  GetMessagesUseCase(this.repository);

  Future<List<DirectMessage>> call(String chatId) =>
      repository.getMessages(chatId);
}

class SendDirectMessageUseCase {
  final DirectChatRepository repository;
  SendDirectMessageUseCase(this.repository);

  Future<DirectMessage> call({
    required String chatId,
    required String senderId,
    required String content,
  }) => repository.sendMessage(
    chatId: chatId,
    senderId: senderId,
    content: content,
  );
}

class MarkMessagesAsReadUseCase {
  final DirectChatRepository repository;
  MarkMessagesAsReadUseCase(this.repository);

  Future<void> call({required String chatId, required String userId}) =>
      repository.markMessagesAsRead(chatId: chatId, userId: userId);
}

class GetExistingRequestUseCase {
  final DirectChatRepository repository;
  GetExistingRequestUseCase(this.repository);

  Future<ChatRequest?> call({
    required String fromUserId,
    required String toUserId,
  }) =>
      repository.getExistingRequest(fromUserId: fromUserId, toUserId: toUserId);
}
