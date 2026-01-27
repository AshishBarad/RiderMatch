// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderPhotoUrl: json['senderPhotoUrl'] as String?,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mediaUrl: json['mediaUrl'] as String?,
      type:
          $enumDecodeNullable(_$ChatMessageTypeEnumMap, json['type']) ??
          ChatMessageType.text,
      repliedToId: json['repliedToId'] as String?,
      repliedToText: json['repliedToText'] as String?,
      repliedToSenderName: json['repliedToSenderName'] as String?,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rideId': instance.rideId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderPhotoUrl': instance.senderPhotoUrl,
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'mediaUrl': instance.mediaUrl,
      'type': _$ChatMessageTypeEnumMap[instance.type]!,
      'repliedToId': instance.repliedToId,
      'repliedToText': instance.repliedToText,
      'repliedToSenderName': instance.repliedToSenderName,
    };

const _$ChatMessageTypeEnumMap = {
  ChatMessageType.text: 'text',
  ChatMessageType.image: 'image',
  ChatMessageType.link: 'link',
};
