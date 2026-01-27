// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get rideId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get senderName => throw _privateConstructorUsedError;
  String? get senderPhotoUrl => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get mediaUrl => throw _privateConstructorUsedError;
  ChatMessageType get type => throw _privateConstructorUsedError;
  String? get repliedToId => throw _privateConstructorUsedError;
  String? get repliedToText => throw _privateConstructorUsedError;
  String? get repliedToSenderName => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String rideId,
    String senderId,
    String senderName,
    String? senderPhotoUrl,
    String text,
    DateTime timestamp,
    String? mediaUrl,
    ChatMessageType type,
    String? repliedToId,
    String? repliedToText,
    String? repliedToSenderName,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rideId = null,
    Object? senderId = null,
    Object? senderName = null,
    Object? senderPhotoUrl = freezed,
    Object? text = null,
    Object? timestamp = null,
    Object? mediaUrl = freezed,
    Object? type = null,
    Object? repliedToId = freezed,
    Object? repliedToText = freezed,
    Object? repliedToSenderName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            rideId: null == rideId
                ? _value.rideId
                : rideId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderName: null == senderName
                ? _value.senderName
                : senderName // ignore: cast_nullable_to_non_nullable
                      as String,
            senderPhotoUrl: freezed == senderPhotoUrl
                ? _value.senderPhotoUrl
                : senderPhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            mediaUrl: freezed == mediaUrl
                ? _value.mediaUrl
                : mediaUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ChatMessageType,
            repliedToId: freezed == repliedToId
                ? _value.repliedToId
                : repliedToId // ignore: cast_nullable_to_non_nullable
                      as String?,
            repliedToText: freezed == repliedToText
                ? _value.repliedToText
                : repliedToText // ignore: cast_nullable_to_non_nullable
                      as String?,
            repliedToSenderName: freezed == repliedToSenderName
                ? _value.repliedToSenderName
                : repliedToSenderName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String rideId,
    String senderId,
    String senderName,
    String? senderPhotoUrl,
    String text,
    DateTime timestamp,
    String? mediaUrl,
    ChatMessageType type,
    String? repliedToId,
    String? repliedToText,
    String? repliedToSenderName,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rideId = null,
    Object? senderId = null,
    Object? senderName = null,
    Object? senderPhotoUrl = freezed,
    Object? text = null,
    Object? timestamp = null,
    Object? mediaUrl = freezed,
    Object? type = null,
    Object? repliedToId = freezed,
    Object? repliedToText = freezed,
    Object? repliedToSenderName = freezed,
  }) {
    return _then(
      _$ChatMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        rideId: null == rideId
            ? _value.rideId
            : rideId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderName: null == senderName
            ? _value.senderName
            : senderName // ignore: cast_nullable_to_non_nullable
                  as String,
        senderPhotoUrl: freezed == senderPhotoUrl
            ? _value.senderPhotoUrl
            : senderPhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        mediaUrl: freezed == mediaUrl
            ? _value.mediaUrl
            : mediaUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ChatMessageType,
        repliedToId: freezed == repliedToId
            ? _value.repliedToId
            : repliedToId // ignore: cast_nullable_to_non_nullable
                  as String?,
        repliedToText: freezed == repliedToText
            ? _value.repliedToText
            : repliedToText // ignore: cast_nullable_to_non_nullable
                  as String?,
        repliedToSenderName: freezed == repliedToSenderName
            ? _value.repliedToSenderName
            : repliedToSenderName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.rideId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.text,
    required this.timestamp,
    this.mediaUrl,
    this.type = ChatMessageType.text,
    this.repliedToId,
    this.repliedToText,
    this.repliedToSenderName,
  });

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String rideId;
  @override
  final String senderId;
  @override
  final String senderName;
  @override
  final String? senderPhotoUrl;
  @override
  final String text;
  @override
  final DateTime timestamp;
  @override
  final String? mediaUrl;
  @override
  @JsonKey()
  final ChatMessageType type;
  @override
  final String? repliedToId;
  @override
  final String? repliedToText;
  @override
  final String? repliedToSenderName;

  @override
  String toString() {
    return 'ChatMessage(id: $id, rideId: $rideId, senderId: $senderId, senderName: $senderName, senderPhotoUrl: $senderPhotoUrl, text: $text, timestamp: $timestamp, mediaUrl: $mediaUrl, type: $type, repliedToId: $repliedToId, repliedToText: $repliedToText, repliedToSenderName: $repliedToSenderName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rideId, rideId) || other.rideId == rideId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderPhotoUrl, senderPhotoUrl) ||
                other.senderPhotoUrl == senderPhotoUrl) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.repliedToId, repliedToId) ||
                other.repliedToId == repliedToId) &&
            (identical(other.repliedToText, repliedToText) ||
                other.repliedToText == repliedToText) &&
            (identical(other.repliedToSenderName, repliedToSenderName) ||
                other.repliedToSenderName == repliedToSenderName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    rideId,
    senderId,
    senderName,
    senderPhotoUrl,
    text,
    timestamp,
    mediaUrl,
    type,
    repliedToId,
    repliedToText,
    repliedToSenderName,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String rideId,
    required final String senderId,
    required final String senderName,
    final String? senderPhotoUrl,
    required final String text,
    required final DateTime timestamp,
    final String? mediaUrl,
    final ChatMessageType type,
    final String? repliedToId,
    final String? repliedToText,
    final String? repliedToSenderName,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get rideId;
  @override
  String get senderId;
  @override
  String get senderName;
  @override
  String? get senderPhotoUrl;
  @override
  String get text;
  @override
  DateTime get timestamp;
  @override
  String? get mediaUrl;
  @override
  ChatMessageType get type;
  @override
  String? get repliedToId;
  @override
  String? get repliedToText;
  @override
  String? get repliedToSenderName;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
