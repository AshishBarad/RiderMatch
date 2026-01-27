import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> getMessages(String rideId);
  Future<void> sendMessage(ChatMessage message);
  Future<void> uploadMedia(String filePath); // Stub for now
}

class ChatRepositoryImpl implements ChatRepository {
  // Simple in-memory storage for mock
  final Map<String, List<ChatMessage>> _messages = {};

  // StreamControllers to handle updates per ride
  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  @override
  Stream<List<ChatMessage>> getMessages(String rideId) {
    debugPrint('💬 ChatRepo: getMessages requested for ride $rideId');
    _messages[rideId] ??= _getInitialMockMessages(rideId);

    // Create a broadcast controller if it doesn't exist or is closed
    if (!_controllers.containsKey(rideId) || _controllers[rideId]!.isClosed) {
      debugPrint(
        '💬 ChatRepo: Creating new broadcast controller for ride $rideId',
      );
      _controllers[rideId] = StreamController<List<ChatMessage>>.broadcast();
    }

    // Immediately emit the current state for new listeners
    final currentList = _messages[rideId]!;
    debugPrint(
      '💬 ChatRepo: Emitting initial ${currentList.length} messages for $rideId',
    );

    Future.microtask(() {
      if (_controllers.containsKey(rideId) && !_controllers[rideId]!.isClosed) {
        _controllers[rideId]!.add(currentList);
      }
    });

    return _controllers[rideId]!.stream;
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    final rideId = message.rideId;
    debugPrint(
      '💬 ChatRepo: sendMessage called for $rideId - "${message.text}"',
    );

    await Future.delayed(const Duration(milliseconds: 300));
    _messages[rideId] = [...(_messages[rideId] ?? []), message];

    // Notify listeners
    if (_controllers.containsKey(rideId) && !_controllers[rideId]!.isClosed) {
      debugPrint(
        '💬 ChatRepo: Pushing updated list (${_messages[rideId]!.length} messages) to stream',
      );
      _controllers[rideId]!.add(_messages[rideId]!);
    } else {
      debugPrint(
        '⚠️ ChatRepo: No active listener for ride $rideId. Message saved but not pushed.',
      );
    }
  }

  @override
  Future<void> uploadMedia(String filePath) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  List<ChatMessage> _getInitialMockMessages(String rideId) {
    if (rideId == '1' || rideId == '4') {
      return [
        ChatMessage(
          id: 'm1',
          rideId: rideId,
          senderId: 'mock_user_1',
          senderName: 'John Doe',
          text: 'Hey everyone! Excited for the ride. 🏍️',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        ChatMessage(
          id: 'm2',
          rideId: rideId,
          senderId: 'mock_user_2',
          senderName: 'Jane Smith',
          text: 'Same here! What time are we meeting at the starting point?',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        ChatMessage(
          id: 'm3',
          rideId: rideId,
          senderId: 'mock_user_1',
          senderName: 'John Doe',
          text: 'Check out the route here: https://maps.google.com',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          type: ChatMessageType.link,
        ),
      ];
    }
    return [];
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
