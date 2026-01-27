enum ChatStatus { pending, approved, rejected }

class DirectChat {
  final String id;
  final List<String> participantIds; // Always 2 users
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final ChatStatus status;
  final String requestedBy; // User who initiated the chat
  final Map<String, int> unreadCount; // userId -> count

  const DirectChat({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTime,
    required this.status,
    required this.requestedBy,
    required this.unreadCount,
  });

  DirectChat copyWith({
    String? id,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    ChatStatus? status,
    String? requestedBy,
    Map<String, int>? unreadCount,
  }) {
    return DirectChat(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  // Get the other participant's ID
  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere((id) => id != currentUserId);
  }

  // Get unread count for a specific user
  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }
}
