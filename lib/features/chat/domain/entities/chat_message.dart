import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum ChatMessageType { text, image, link }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String rideId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String text,
    required DateTime timestamp,
    String? mediaUrl,
    @Default(ChatMessageType.text) ChatMessageType type,
    String? repliedToId,
    String? repliedToText,
    String? repliedToSenderName,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
