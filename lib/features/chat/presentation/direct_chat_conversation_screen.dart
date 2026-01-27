import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'direct_chat_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../domain/entities/direct_message.dart';

class DirectChatConversationScreen extends ConsumerStatefulWidget {
  final String chatId;

  const DirectChatConversationScreen({super.key, required this.chatId});

  @override
  ConsumerState<DirectChatConversationScreen> createState() =>
      _DirectChatConversationScreenState();
}

class _DirectChatConversationScreenState
    extends ConsumerState<DirectChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String _currentUserId = 'mock_user_123';
  List<DirectMessage> _messages = [];
  String? _otherUserId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final chat = await ref.read(getChatByIdUseCaseProvider)(widget.chatId);
    if (chat != null) {
      _otherUserId = chat.getOtherParticipantId(_currentUserId);
      final messages = await ref.read(getMessagesUseCaseProvider)(
        widget.chatId,
      );
      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
      // Mark as read
      await ref.read(markMessagesAsReadUseCaseProvider)(
        chatId: widget.chatId,
        userId: _currentUserId,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    final message = await ref.read(sendDirectMessageUseCaseProvider)(
      chatId: widget.chatId,
      senderId: _currentUserId,
      content: content,
    );

    setState(() {
      _messages = [..._messages, message];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _otherUserId != null
            ? FutureBuilder(
                future: ref.read(getUserProfileUseCaseProvider)(_otherUserId!),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                        child: user?.photoUrl == null
                            ? const Icon(Icons.person, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(user?.fullName ?? 'User'),
                    ],
                  );
                },
              )
            : const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderId == _currentUserId;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('h:mm a').format(message.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
