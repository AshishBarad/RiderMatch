// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Ride _$RideFromJson(Map<String, dynamic> json) {
  return _Ride.fromJson(json);
}

/// @nodoc
mixin _$Ride {
  String get id => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  String get creatorGender => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get fromLocation => throw _privateConstructorUsedError;
  double get fromLat => throw _privateConstructorUsedError;
  double get fromLng => throw _privateConstructorUsedError;
  String get toLocation => throw _privateConstructorUsedError;
  double get toLat => throw _privateConstructorUsedError;
  double get toLng => throw _privateConstructorUsedError;
  DateTime get dateTime => throw _privateConstructorUsedError;
  double get validDistanceKm => throw _privateConstructorUsedError;
  String get difficulty =>
      throw _privateConstructorUsedError; // Easy, Medium, Hard
  String get encodedPolyline => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;
  List<String> get joinRequestIds => throw _privateConstructorUsedError;
  List<String> get participantIds => throw _privateConstructorUsedError;
  List<String> get invitedUserIds => throw _privateConstructorUsedError;
  List<String> get participantGenders => throw _privateConstructorUsedError;

  /// Serializes this Ride to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Ride
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RideCopyWith<Ride> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RideCopyWith<$Res> {
  factory $RideCopyWith(Ride value, $Res Function(Ride) then) =
      _$RideCopyWithImpl<$Res, Ride>;
  @useResult
  $Res call({
    String id,
    String creatorId,
    String creatorGender,
    String title,
    String description,
    String fromLocation,
    double fromLat,
    double fromLng,
    String toLocation,
    double toLat,
    double toLng,
    DateTime dateTime,
    double validDistanceKm,
    String difficulty,
    String encodedPolyline,
    bool isPrivate,
    List<String> joinRequestIds,
    List<String> participantIds,
    List<String> invitedUserIds,
    List<String> participantGenders,
  });
}

/// @nodoc
class _$RideCopyWithImpl<$Res, $Val extends Ride>
    implements $RideCopyWith<$Res> {
  _$RideCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Ride
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? creatorGender = null,
    Object? title = null,
    Object? description = null,
    Object? fromLocation = null,
    Object? fromLat = null,
    Object? fromLng = null,
    Object? toLocation = null,
    Object? toLat = null,
    Object? toLng = null,
    Object? dateTime = null,
    Object? validDistanceKm = null,
    Object? difficulty = null,
    Object? encodedPolyline = null,
    Object? isPrivate = null,
    Object? joinRequestIds = null,
    Object? participantIds = null,
    Object? invitedUserIds = null,
    Object? participantGenders = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            creatorId: null == creatorId
                ? _value.creatorId
                : creatorId // ignore: cast_nullable_to_non_nullable
                      as String,
            creatorGender: null == creatorGender
                ? _value.creatorGender
                : creatorGender // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            fromLocation: null == fromLocation
                ? _value.fromLocation
                : fromLocation // ignore: cast_nullable_to_non_nullable
                      as String,
            fromLat: null == fromLat
                ? _value.fromLat
                : fromLat // ignore: cast_nullable_to_non_nullable
                      as double,
            fromLng: null == fromLng
                ? _value.fromLng
                : fromLng // ignore: cast_nullable_to_non_nullable
                      as double,
            toLocation: null == toLocation
                ? _value.toLocation
                : toLocation // ignore: cast_nullable_to_non_nullable
                      as String,
            toLat: null == toLat
                ? _value.toLat
                : toLat // ignore: cast_nullable_to_non_nullable
                      as double,
            toLng: null == toLng
                ? _value.toLng
                : toLng // ignore: cast_nullable_to_non_nullable
                      as double,
            dateTime: null == dateTime
                ? _value.dateTime
                : dateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            validDistanceKm: null == validDistanceKm
                ? _value.validDistanceKm
                : validDistanceKm // ignore: cast_nullable_to_non_nullable
                      as double,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String,
            encodedPolyline: null == encodedPolyline
                ? _value.encodedPolyline
                : encodedPolyline // ignore: cast_nullable_to_non_nullable
                      as String,
            isPrivate: null == isPrivate
                ? _value.isPrivate
                : isPrivate // ignore: cast_nullable_to_non_nullable
                      as bool,
            joinRequestIds: null == joinRequestIds
                ? _value.joinRequestIds
                : joinRequestIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            participantIds: null == participantIds
                ? _value.participantIds
                : participantIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            invitedUserIds: null == invitedUserIds
                ? _value.invitedUserIds
                : invitedUserIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            participantGenders: null == participantGenders
                ? _value.participantGenders
                : participantGenders // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RideImplCopyWith<$Res> implements $RideCopyWith<$Res> {
  factory _$$RideImplCopyWith(
    _$RideImpl value,
    $Res Function(_$RideImpl) then,
  ) = __$$RideImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String creatorId,
    String creatorGender,
    String title,
    String description,
    String fromLocation,
    double fromLat,
    double fromLng,
    String toLocation,
    double toLat,
    double toLng,
    DateTime dateTime,
    double validDistanceKm,
    String difficulty,
    String encodedPolyline,
    bool isPrivate,
    List<String> joinRequestIds,
    List<String> participantIds,
    List<String> invitedUserIds,
    List<String> participantGenders,
  });
}

/// @nodoc
class __$$RideImplCopyWithImpl<$Res>
    extends _$RideCopyWithImpl<$Res, _$RideImpl>
    implements _$$RideImplCopyWith<$Res> {
  __$$RideImplCopyWithImpl(_$RideImpl _value, $Res Function(_$RideImpl) _then)
    : super(_value, _then);

  /// Create a copy of Ride
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? creatorGender = null,
    Object? title = null,
    Object? description = null,
    Object? fromLocation = null,
    Object? fromLat = null,
    Object? fromLng = null,
    Object? toLocation = null,
    Object? toLat = null,
    Object? toLng = null,
    Object? dateTime = null,
    Object? validDistanceKm = null,
    Object? difficulty = null,
    Object? encodedPolyline = null,
    Object? isPrivate = null,
    Object? joinRequestIds = null,
    Object? participantIds = null,
    Object? invitedUserIds = null,
    Object? participantGenders = null,
  }) {
    return _then(
      _$RideImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        creatorId: null == creatorId
            ? _value.creatorId
            : creatorId // ignore: cast_nullable_to_non_nullable
                  as String,
        creatorGender: null == creatorGender
            ? _value.creatorGender
            : creatorGender // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        fromLocation: null == fromLocation
            ? _value.fromLocation
            : fromLocation // ignore: cast_nullable_to_non_nullable
                  as String,
        fromLat: null == fromLat
            ? _value.fromLat
            : fromLat // ignore: cast_nullable_to_non_nullable
                  as double,
        fromLng: null == fromLng
            ? _value.fromLng
            : fromLng // ignore: cast_nullable_to_non_nullable
                  as double,
        toLocation: null == toLocation
            ? _value.toLocation
            : toLocation // ignore: cast_nullable_to_non_nullable
                  as String,
        toLat: null == toLat
            ? _value.toLat
            : toLat // ignore: cast_nullable_to_non_nullable
                  as double,
        toLng: null == toLng
            ? _value.toLng
            : toLng // ignore: cast_nullable_to_non_nullable
                  as double,
        dateTime: null == dateTime
            ? _value.dateTime
            : dateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        validDistanceKm: null == validDistanceKm
            ? _value.validDistanceKm
            : validDistanceKm // ignore: cast_nullable_to_non_nullable
                  as double,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String,
        encodedPolyline: null == encodedPolyline
            ? _value.encodedPolyline
            : encodedPolyline // ignore: cast_nullable_to_non_nullable
                  as String,
        isPrivate: null == isPrivate
            ? _value.isPrivate
            : isPrivate // ignore: cast_nullable_to_non_nullable
                  as bool,
        joinRequestIds: null == joinRequestIds
            ? _value._joinRequestIds
            : joinRequestIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        participantIds: null == participantIds
            ? _value._participantIds
            : participantIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        invitedUserIds: null == invitedUserIds
            ? _value._invitedUserIds
            : invitedUserIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        participantGenders: null == participantGenders
            ? _value._participantGenders
            : participantGenders // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RideImpl implements _Ride {
  const _$RideImpl({
    required this.id,
    required this.creatorId,
    this.creatorGender = 'Unknown',
    required this.title,
    required this.description,
    required this.fromLocation,
    this.fromLat = 0.0,
    this.fromLng = 0.0,
    required this.toLocation,
    this.toLat = 0.0,
    this.toLng = 0.0,
    required this.dateTime,
    required this.validDistanceKm,
    required this.difficulty,
    this.encodedPolyline = '',
    this.isPrivate = false,
    final List<String> joinRequestIds = const [],
    final List<String> participantIds = const [],
    final List<String> invitedUserIds = const [],
    final List<String> participantGenders = const [],
  }) : _joinRequestIds = joinRequestIds,
       _participantIds = participantIds,
       _invitedUserIds = invitedUserIds,
       _participantGenders = participantGenders;

  factory _$RideImpl.fromJson(Map<String, dynamic> json) =>
      _$$RideImplFromJson(json);

  @override
  final String id;
  @override
  final String creatorId;
  @override
  @JsonKey()
  final String creatorGender;
  @override
  final String title;
  @override
  final String description;
  @override
  final String fromLocation;
  @override
  @JsonKey()
  final double fromLat;
  @override
  @JsonKey()
  final double fromLng;
  @override
  final String toLocation;
  @override
  @JsonKey()
  final double toLat;
  @override
  @JsonKey()
  final double toLng;
  @override
  final DateTime dateTime;
  @override
  final double validDistanceKm;
  @override
  final String difficulty;
  // Easy, Medium, Hard
  @override
  @JsonKey()
  final String encodedPolyline;
  @override
  @JsonKey()
  final bool isPrivate;
  final List<String> _joinRequestIds;
  @override
  @JsonKey()
  List<String> get joinRequestIds {
    if (_joinRequestIds is EqualUnmodifiableListView) return _joinRequestIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_joinRequestIds);
  }

  final List<String> _participantIds;
  @override
  @JsonKey()
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  final List<String> _invitedUserIds;
  @override
  @JsonKey()
  List<String> get invitedUserIds {
    if (_invitedUserIds is EqualUnmodifiableListView) return _invitedUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_invitedUserIds);
  }

  final List<String> _participantGenders;
  @override
  @JsonKey()
  List<String> get participantGenders {
    if (_participantGenders is EqualUnmodifiableListView)
      return _participantGenders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantGenders);
  }

  @override
  String toString() {
    return 'Ride(id: $id, creatorId: $creatorId, creatorGender: $creatorGender, title: $title, description: $description, fromLocation: $fromLocation, fromLat: $fromLat, fromLng: $fromLng, toLocation: $toLocation, toLat: $toLat, toLng: $toLng, dateTime: $dateTime, validDistanceKm: $validDistanceKm, difficulty: $difficulty, encodedPolyline: $encodedPolyline, isPrivate: $isPrivate, joinRequestIds: $joinRequestIds, participantIds: $participantIds, invitedUserIds: $invitedUserIds, participantGenders: $participantGenders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.creatorGender, creatorGender) ||
                other.creatorGender == creatorGender) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.fromLocation, fromLocation) ||
                other.fromLocation == fromLocation) &&
            (identical(other.fromLat, fromLat) || other.fromLat == fromLat) &&
            (identical(other.fromLng, fromLng) || other.fromLng == fromLng) &&
            (identical(other.toLocation, toLocation) ||
                other.toLocation == toLocation) &&
            (identical(other.toLat, toLat) || other.toLat == toLat) &&
            (identical(other.toLng, toLng) || other.toLng == toLng) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.validDistanceKm, validDistanceKm) ||
                other.validDistanceKm == validDistanceKm) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.encodedPolyline, encodedPolyline) ||
                other.encodedPolyline == encodedPolyline) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            const DeepCollectionEquality().equals(
              other._joinRequestIds,
              _joinRequestIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._participantIds,
              _participantIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._invitedUserIds,
              _invitedUserIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._participantGenders,
              _participantGenders,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    creatorId,
    creatorGender,
    title,
    description,
    fromLocation,
    fromLat,
    fromLng,
    toLocation,
    toLat,
    toLng,
    dateTime,
    validDistanceKm,
    difficulty,
    encodedPolyline,
    isPrivate,
    const DeepCollectionEquality().hash(_joinRequestIds),
    const DeepCollectionEquality().hash(_participantIds),
    const DeepCollectionEquality().hash(_invitedUserIds),
    const DeepCollectionEquality().hash(_participantGenders),
  ]);

  /// Create a copy of Ride
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RideImplCopyWith<_$RideImpl> get copyWith =>
      __$$RideImplCopyWithImpl<_$RideImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RideImplToJson(this);
  }
}

abstract class _Ride implements Ride {
  const factory _Ride({
    required final String id,
    required final String creatorId,
    final String creatorGender,
    required final String title,
    required final String description,
    required final String fromLocation,
    final double fromLat,
    final double fromLng,
    required final String toLocation,
    final double toLat,
    final double toLng,
    required final DateTime dateTime,
    required final double validDistanceKm,
    required final String difficulty,
    final String encodedPolyline,
    final bool isPrivate,
    final List<String> joinRequestIds,
    final List<String> participantIds,
    final List<String> invitedUserIds,
    final List<String> participantGenders,
  }) = _$RideImpl;

  factory _Ride.fromJson(Map<String, dynamic> json) = _$RideImpl.fromJson;

  @override
  String get id;
  @override
  String get creatorId;
  @override
  String get creatorGender;
  @override
  String get title;
  @override
  String get description;
  @override
  String get fromLocation;
  @override
  double get fromLat;
  @override
  double get fromLng;
  @override
  String get toLocation;
  @override
  double get toLat;
  @override
  double get toLng;
  @override
  DateTime get dateTime;
  @override
  double get validDistanceKm;
  @override
  String get difficulty; // Easy, Medium, Hard
  @override
  String get encodedPolyline;
  @override
  bool get isPrivate;
  @override
  List<String> get joinRequestIds;
  @override
  List<String> get participantIds;
  @override
  List<String> get invitedUserIds;
  @override
  List<String> get participantGenders;

  /// Create a copy of Ride
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RideImplCopyWith<_$RideImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
