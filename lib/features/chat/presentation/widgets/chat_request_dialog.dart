import 'package:flutter/material.dart';

class ChatRequestDialog extends StatefulWidget {
  final String toUserName;
  final Function(String? message) onSend;

  const ChatRequestDialog({
    super.key,
    required this.toUserName,
    required this.onSend,
  });

  @override
  State<ChatRequestDialog> createState() => _ChatRequestDialogState();
}

class _ChatRequestDialogState extends State<ChatRequestDialog> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send message request to ${widget.toUserName}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You need to send a request before you can message ${widget.toUserName}.',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Add a message (optional)',
              hintText: 'Say hi...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final message = _messageController.text.trim();
            widget.onSend(message.isEmpty ? null : message);
            Navigator.pop(context);
          },
          child: const Text('Send Request'),
        ),
      ],
    );
  }
}
