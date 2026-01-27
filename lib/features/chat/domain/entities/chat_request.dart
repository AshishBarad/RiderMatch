enum ChatRequestStatus { pending, approved, rejected }

class ChatRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String? message; // Optional intro message
  final ChatRequestStatus status;
  final DateTime createdAt;

  const ChatRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    this.message,
    required this.status,
    required this.createdAt,
  });

  ChatRequest copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? message,
    ChatRequestStatus? status,
    DateTime? createdAt,
  }) {
    return ChatRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
