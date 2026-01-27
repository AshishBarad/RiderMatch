import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/entities/chat_message.dart';
import 'chat_providers.dart';
import '../../auth/domain/entities/user.dart';

class RideChatWidget extends ConsumerStatefulWidget {
  final String rideId;
  final bool isMember;
  final String currentUserId;

  const RideChatWidget({
    super.key,
    required this.rideId,
    required this.isMember,
    required this.currentUserId,
  });

  @override
  ConsumerState<RideChatWidget> createState() => _RideChatWidgetState();
}

class _RideChatWidgetState extends ConsumerState<RideChatWidget>
    with AutomaticKeepAliveClientMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  @override
  bool get wantKeepAlive => true;
  List<User> _allParticipants = [];
  List<User> _filteredParticipants = [];
  bool _showMentions = false;
  String _mentionQuery = '';
  ChatMessage? _replyingTo;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentChatRideIdProvider.notifier).state = widget.rideId;
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    // Use a delay or a specific check to avoid clearing if another widget is already setting it
    Future.microtask(() {
      if (ref.read(currentChatRideIdProvider) == widget.rideId) {
        debugPrint('🔔 Chat: Clearing currentChatRideId');
        ref.read(currentChatRideIdProvider.notifier).state = null;
      }
    });
    super.dispose();
  }

  void _onReply(ChatMessage message) {
    setState(() {
      _replyingTo = message;
    });
  }

  void _onTextChanged() {
    final text = _messageController.text;
    final selection = _messageController.selection;
    if (selection.baseOffset < 0) return;

    final cursorPosition = selection.baseOffset;
    final textBeforeCursor = text.substring(0, cursorPosition);

    if (textBeforeCursor.contains('@')) {
      final lastAtIndex = textBeforeCursor.lastIndexOf('@');
      final query = textBeforeCursor.substring(lastAtIndex + 1);

      if (!query.contains(' ')) {
        setState(() {
          _showMentions = true;
          _mentionQuery = query.toLowerCase();
          _filterParticipants();
        });
      } else {
        setState(() => _showMentions = false);
      }
    } else {
      setState(() => _showMentions = false);
    }
  }

  void _filterParticipants() {
    _filteredParticipants = _allParticipants.where((user) {
      final name = (user.fullName ?? '').toLowerCase();
      return name.contains(_mentionQuery);
    }).toList();
  }

  void _selectMention(User user) {
    final text = _messageController.text;
    final selection = _messageController.selection;
    final cursorPosition = selection.baseOffset;
    final textBeforeCursor = text.substring(0, cursorPosition);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    final newText = text.replaceRange(
      lastAtIndex,
      cursorPosition,
      '@${user.fullName} ',
    );

    _messageController.text = newText;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: lastAtIndex + user.fullName!.length + 2),
    );

    setState(() => _showMentions = false);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    debugPrint('📤 UI: Sending message for ride ${widget.rideId}: "$text"');

    // Use the notifier to send the message for reactivity
    ref
        .read(rideChatNotifierProvider(widget.rideId).notifier)
        .sendMessage(
          text,
          senderId: widget.currentUserId,
          repliedToId: _replyingTo?.id,
          repliedToText: _replyingTo?.text,
          repliedToSenderName: _replyingTo?.senderName,
        );

    _messageController.clear();
    setState(() {
      _replyingTo = null;
    });

    // Keep focus
    _focusNode.requestFocus();

    // Scroll to bottom
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showFeatureGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Chat Features'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGuideItem(
              Icons.alternate_email,
              'Mentions',
              'Type @ followed by a name to mention someone.',
            ),
            const SizedBox(height: 12),
            _buildGuideItem(
              Icons.reply,
              'Replies',
              'Long-press any message to quote and reply to it.',
            ),
            const SizedBox(height: 12),
            _buildGuideItem(
              Icons.image_outlined,
              'Media',
              'Tap the + icon to share photos or screenshots.',
            ),
            const SizedBox(height: 12),
            _buildGuideItem(
              Icons.link,
              'Links',
              'URLs like Google Maps links are clickable.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                description,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!widget.isMember) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Chat is for members only',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join this ride to participate in the conversation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final asyncMessages = ref.watch(rideChatNotifierProvider(widget.rideId));
    final asyncParticipants = ref.watch(
      rideParticipantsProvider(widget.rideId),
    );

    asyncParticipants.whenData((p) {
      _allParticipants = p;
      if (_showMentions) _filterParticipants();
    });

    // Auto-scroll when new messages arrive
    ref.listen(rideChatNotifierProvider(widget.rideId), (previous, next) {
      if (next is AsyncData && next.value != null) {
        // Only scroll if a new message was actually added (not just a rebuild)
        if (previous?.value?.length != next.value!.length) {
          _scrollToBottom();
        }
      }
    });

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: asyncMessages.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('No messages yet. Say hi! 👋'),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == widget.currentUserId;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
            if (_replyingTo != null) _buildReplyPreview(),
            _buildInputBar(),
          ],
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey[400]),
            onPressed: _showFeatureGuide,
          ),
        ),
        if (_showMentions && _filteredParticipants.isNotEmpty)
          Positioned(
            bottom: 70, // Above input bar
            left: 10,
            right: 10,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _filteredParticipants.length,
                  itemBuilder: (context, index) {
                    final user = _filteredParticipants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? const Icon(Icons.person, size: 12)
                            : null,
                      ),
                      title: Text(user.fullName ?? 'Unknown'),
                      onTap: () => _selectMention(user),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    final timeStr = DateFormat('h:mm a').format(message.timestamp);

    return GestureDetector(
      onLongPress: () => _onReply(message),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  message.senderName,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue[600] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isMe ? const Radius.circular(0) : null,
                  bottomLeft: !isMe ? const Radius.circular(0) : null,
                ),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.repliedToId != null)
                    _buildQuotedMessage(
                      message.repliedToSenderName ?? 'Unknown',
                      message.repliedToText ?? '',
                      isMe,
                    ),
                  if (message.type == ChatMessageType.image &&
                      message.mediaUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message.mediaUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  _buildMessageText(message, isMe),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageText(ChatMessage message, bool isMe) {
    if (message.type == ChatMessageType.link) {
      return InkWell(
        onTap: () async {
          final uri = Uri.parse(message.text);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.blue,
            fontSize: 15,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }

    // Handle Mentions
    final text = message.text;
    final mentionRegex = RegExp(r'(@[a-zA-Z0-9_\s]+)');
    // Simple regex for mentions. In real app, name might be limited.

    final spans = <TextSpan>[];

    text.splitMapJoin(
      mentionRegex,
      onMatch: (match) {
        final mention = match.group(0)!;
        spans.add(
          TextSpan(
            text: mention,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isMe ? Colors.yellow[200] : Colors.blue[800],
            ),
          ),
        );
        return mention;
      },
      onNonMatch: (nonMatch) {
        if (nonMatch.isNotEmpty) {
          spans.add(
            TextSpan(
              text: nonMatch,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
          );
        }
        return nonMatch;
      },
    );

    return RichText(
      text: TextSpan(style: const TextStyle(fontSize: 15), children: spans),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replying to ${_replyingTo!.senderName}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  _replyingTo!.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => setState(() => _replyingTo = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotedMessage(String sender, String text, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.black.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white70 : Colors.blue,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isMe ? Colors.white : Colors.blue[800],
            ),
          ),
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isMe ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined, color: Colors.blue),
            onPressed: () {
              // Simulate media selection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Media selection simulated...')),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
