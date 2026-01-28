// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_stop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RideStop _$RideStopFromJson(Map<String, dynamic> json) {
  return _RideStop.fromJson(json);
}

/// @nodoc
mixin _$RideStop {
  String get address => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;

  /// Serializes this RideStop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RideStop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RideStopCopyWith<RideStop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RideStopCopyWith<$Res> {
  factory $RideStopCopyWith(RideStop value, $Res Function(RideStop) then) =
      _$RideStopCopyWithImpl<$Res, RideStop>;
  @useResult
  $Res call({String address, double lat, double lng});
}

/// @nodoc
class _$RideStopCopyWithImpl<$Res, $Val extends RideStop>
    implements $RideStopCopyWith<$Res> {
  _$RideStopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RideStop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? address = null, Object? lat = null, Object? lng = null}) {
    return _then(
      _value.copyWith(
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RideStopImplCopyWith<$Res>
    implements $RideStopCopyWith<$Res> {
  factory _$$RideStopImplCopyWith(
    _$RideStopImpl value,
    $Res Function(_$RideStopImpl) then,
  ) = __$$RideStopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String address, double lat, double lng});
}

/// @nodoc
class __$$RideStopImplCopyWithImpl<$Res>
    extends _$RideStopCopyWithImpl<$Res, _$RideStopImpl>
    implements _$$RideStopImplCopyWith<$Res> {
  __$$RideStopImplCopyWithImpl(
    _$RideStopImpl _value,
    $Res Function(_$RideStopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RideStop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? address = null, Object? lat = null, Object? lng = null}) {
    return _then(
      _$RideStopImpl(
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RideStopImpl implements _RideStop {
  const _$RideStopImpl({
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory _$RideStopImpl.fromJson(Map<String, dynamic> json) =>
      _$$RideStopImplFromJson(json);

  @override
  final String address;
  @override
  final double lat;
  @override
  final double lng;

  @override
  String toString() {
    return 'RideStop(address: $address, lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RideStopImpl &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, address, lat, lng);

  /// Create a copy of RideStop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RideStopImplCopyWith<_$RideStopImpl> get copyWith =>
      __$$RideStopImplCopyWithImpl<_$RideStopImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RideStopImplToJson(this);
  }
}

abstract class _RideStop implements RideStop {
  const factory _RideStop({
    required final String address,
    required final double lat,
    required final double lng,
  }) = _$RideStopImpl;

  factory _RideStop.fromJson(Map<String, dynamic> json) =
      _$RideStopImpl.fromJson;

  @override
  String get address;
  @override
  double get lat;
  @override
  double get lng;

  /// Create a copy of RideStop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RideStopImplCopyWith<_$RideStopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
