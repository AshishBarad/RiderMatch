// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get id => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  bool get isProfileComplete => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get coverImageUrl => throw _privateConstructorUsedError;
  int? get age => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get vehicleModel => throw _privateConstructorUsedError;
  String? get vehicleRegNo => throw _privateConstructorUsedError;
  String? get vehicleManufacturer => throw _privateConstructorUsedError;
  String? get emergencyContactName => throw _privateConstructorUsedError;
  String? get emergencyContactRelationship =>
      throw _privateConstructorUsedError;
  String? get emergencyContactNumber => throw _privateConstructorUsedError;
  String? get bloodGroup => throw _privateConstructorUsedError;
  List<String> get ridingPreferences => throw _privateConstructorUsedError;
  List<String> get followers => throw _privateConstructorUsedError;
  List<String> get following => throw _privateConstructorUsedError;
  List<String> get blockedUsers => throw _privateConstructorUsedError;
  List<String> get savedRides => throw _privateConstructorUsedError;
  double get rideDistancePreference => throw _privateConstructorUsedError;
  double? get lastKnownLat => throw _privateConstructorUsedError;
  double? get lastKnownLng => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String id,
    String phoneNumber,
    String? username,
    bool isProfileComplete,
    String? email,
    String? fullName,
    String? photoUrl,
    String? coverImageUrl,
    int? age,
    String? gender,
    String? vehicleModel,
    String? vehicleRegNo,
    String? vehicleManufacturer,
    String? emergencyContactName,
    String? emergencyContactRelationship,
    String? emergencyContactNumber,
    String? bloodGroup,
    List<String> ridingPreferences,
    List<String> followers,
    List<String> following,
    List<String> blockedUsers,
    List<String> savedRides,
    double rideDistancePreference,
    double? lastKnownLat,
    double? lastKnownLng,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phoneNumber = null,
    Object? username = freezed,
    Object? isProfileComplete = null,
    Object? email = freezed,
    Object? fullName = freezed,
    Object? photoUrl = freezed,
    Object? coverImageUrl = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleRegNo = freezed,
    Object? vehicleManufacturer = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactRelationship = freezed,
    Object? emergencyContactNumber = freezed,
    Object? bloodGroup = freezed,
    Object? ridingPreferences = null,
    Object? followers = null,
    Object? following = null,
    Object? blockedUsers = null,
    Object? savedRides = null,
    Object? rideDistancePreference = null,
    Object? lastKnownLat = freezed,
    Object? lastKnownLng = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: null == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            isProfileComplete: null == isProfileComplete
                ? _value.isProfileComplete
                : isProfileComplete // ignore: cast_nullable_to_non_nullable
                      as bool,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            fullName: freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverImageUrl: freezed == coverImageUrl
                ? _value.coverImageUrl
                : coverImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            age: freezed == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                      as int?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            vehicleModel: freezed == vehicleModel
                ? _value.vehicleModel
                : vehicleModel // ignore: cast_nullable_to_non_nullable
                      as String?,
            vehicleRegNo: freezed == vehicleRegNo
                ? _value.vehicleRegNo
                : vehicleRegNo // ignore: cast_nullable_to_non_nullable
                      as String?,
            vehicleManufacturer: freezed == vehicleManufacturer
                ? _value.vehicleManufacturer
                : vehicleManufacturer // ignore: cast_nullable_to_non_nullable
                      as String?,
            emergencyContactName: freezed == emergencyContactName
                ? _value.emergencyContactName
                : emergencyContactName // ignore: cast_nullable_to_non_nullable
                      as String?,
            emergencyContactRelationship:
                freezed == emergencyContactRelationship
                ? _value.emergencyContactRelationship
                : emergencyContactRelationship // ignore: cast_nullable_to_non_nullable
                      as String?,
            emergencyContactNumber: freezed == emergencyContactNumber
                ? _value.emergencyContactNumber
                : emergencyContactNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            bloodGroup: freezed == bloodGroup
                ? _value.bloodGroup
                : bloodGroup // ignore: cast_nullable_to_non_nullable
                      as String?,
            ridingPreferences: null == ridingPreferences
                ? _value.ridingPreferences
                : ridingPreferences // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            followers: null == followers
                ? _value.followers
                : followers // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            following: null == following
                ? _value.following
                : following // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            blockedUsers: null == blockedUsers
                ? _value.blockedUsers
                : blockedUsers // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            savedRides: null == savedRides
                ? _value.savedRides
                : savedRides // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            rideDistancePreference: null == rideDistancePreference
                ? _value.rideDistancePreference
                : rideDistancePreference // ignore: cast_nullable_to_non_nullable
                      as double,
            lastKnownLat: freezed == lastKnownLat
                ? _value.lastKnownLat
                : lastKnownLat // ignore: cast_nullable_to_non_nullable
                      as double?,
            lastKnownLng: freezed == lastKnownLng
                ? _value.lastKnownLng
                : lastKnownLng // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String phoneNumber,
    String? username,
    bool isProfileComplete,
    String? email,
    String? fullName,
    String? photoUrl,
    String? coverImageUrl,
    int? age,
    String? gender,
    String? vehicleModel,
    String? vehicleRegNo,
    String? vehicleManufacturer,
    String? emergencyContactName,
    String? emergencyContactRelationship,
    String? emergencyContactNumber,
    String? bloodGroup,
    List<String> ridingPreferences,
    List<String> followers,
    List<String> following,
    List<String> blockedUsers,
    List<String> savedRides,
    double rideDistancePreference,
    double? lastKnownLat,
    double? lastKnownLng,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? phoneNumber = null,
    Object? username = freezed,
    Object? isProfileComplete = null,
    Object? email = freezed,
    Object? fullName = freezed,
    Object? photoUrl = freezed,
    Object? coverImageUrl = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? vehicleModel = freezed,
    Object? vehicleRegNo = freezed,
    Object? vehicleManufacturer = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactRelationship = freezed,
    Object? emergencyContactNumber = freezed,
    Object? bloodGroup = freezed,
    Object? ridingPreferences = null,
    Object? followers = null,
    Object? following = null,
    Object? blockedUsers = null,
    Object? savedRides = null,
    Object? rideDistancePreference = null,
    Object? lastKnownLat = freezed,
    Object? lastKnownLng = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: null == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        isProfileComplete: null == isProfileComplete
            ? _value.isProfileComplete
            : isProfileComplete // ignore: cast_nullable_to_non_nullable
                  as bool,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverImageUrl: freezed == coverImageUrl
            ? _value.coverImageUrl
            : coverImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        age: freezed == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        vehicleModel: freezed == vehicleModel
            ? _value.vehicleModel
            : vehicleModel // ignore: cast_nullable_to_non_nullable
                  as String?,
        vehicleRegNo: freezed == vehicleRegNo
            ? _value.vehicleRegNo
            : vehicleRegNo // ignore: cast_nullable_to_non_nullable
                  as String?,
        vehicleManufacturer: freezed == vehicleManufacturer
            ? _value.vehicleManufacturer
            : vehicleManufacturer // ignore: cast_nullable_to_non_nullable
                  as String?,
        emergencyContactName: freezed == emergencyContactName
            ? _value.emergencyContactName
            : emergencyContactName // ignore: cast_nullable_to_non_nullable
                  as String?,
        emergencyContactRelationship: freezed == emergencyContactRelationship
            ? _value.emergencyContactRelationship
            : emergencyContactRelationship // ignore: cast_nullable_to_non_nullable
                  as String?,
        emergencyContactNumber: freezed == emergencyContactNumber
            ? _value.emergencyContactNumber
            : emergencyContactNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        bloodGroup: freezed == bloodGroup
            ? _value.bloodGroup
            : bloodGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        ridingPreferences: null == ridingPreferences
            ? _value._ridingPreferences
            : ridingPreferences // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        followers: null == followers
            ? _value._followers
            : followers // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        following: null == following
            ? _value._following
            : following // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        blockedUsers: null == blockedUsers
            ? _value._blockedUsers
            : blockedUsers // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        savedRides: null == savedRides
            ? _value._savedRides
            : savedRides // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        rideDistancePreference: null == rideDistancePreference
            ? _value.rideDistancePreference
            : rideDistancePreference // ignore: cast_nullable_to_non_nullable
                  as double,
        lastKnownLat: freezed == lastKnownLat
            ? _value.lastKnownLat
            : lastKnownLat // ignore: cast_nullable_to_non_nullable
                  as double?,
        lastKnownLng: freezed == lastKnownLng
            ? _value.lastKnownLng
            : lastKnownLng // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    required this.id,
    required this.phoneNumber,
    this.username,
    this.isProfileComplete = false,
    this.email,
    this.fullName,
    this.photoUrl,
    this.coverImageUrl,
    this.age,
    this.gender,
    this.vehicleModel,
    this.vehicleRegNo,
    this.vehicleManufacturer,
    this.emergencyContactName,
    this.emergencyContactRelationship,
    this.emergencyContactNumber,
    this.bloodGroup,
    final List<String> ridingPreferences = const [],
    final List<String> followers = const [],
    final List<String> following = const [],
    final List<String> blockedUsers = const [],
    final List<String> savedRides = const [],
    this.rideDistancePreference = 50.0,
    this.lastKnownLat,
    this.lastKnownLng,
  }) : _ridingPreferences = ridingPreferences,
       _followers = followers,
       _following = following,
       _blockedUsers = blockedUsers,
       _savedRides = savedRides;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String id;
  @override
  final String phoneNumber;
  @override
  final String? username;
  @override
  @JsonKey()
  final bool isProfileComplete;
  @override
  final String? email;
  @override
  final String? fullName;
  @override
  final String? photoUrl;
  @override
  final String? coverImageUrl;
  @override
  final int? age;
  @override
  final String? gender;
  @override
  final String? vehicleModel;
  @override
  final String? vehicleRegNo;
  @override
  final String? vehicleManufacturer;
  @override
  final String? emergencyContactName;
  @override
  final String? emergencyContactRelationship;
  @override
  final String? emergencyContactNumber;
  @override
  final String? bloodGroup;
  final List<String> _ridingPreferences;
  @override
  @JsonKey()
  List<String> get ridingPreferences {
    if (_ridingPreferences is EqualUnmodifiableListView)
      return _ridingPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ridingPreferences);
  }

  final List<String> _followers;
  @override
  @JsonKey()
  List<String> get followers {
    if (_followers is EqualUnmodifiableListView) return _followers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followers);
  }

  final List<String> _following;
  @override
  @JsonKey()
  List<String> get following {
    if (_following is EqualUnmodifiableListView) return _following;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_following);
  }

  final List<String> _blockedUsers;
  @override
  @JsonKey()
  List<String> get blockedUsers {
    if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockedUsers);
  }

  final List<String> _savedRides;
  @override
  @JsonKey()
  List<String> get savedRides {
    if (_savedRides is EqualUnmodifiableListView) return _savedRides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_savedRides);
  }

  @override
  @JsonKey()
  final double rideDistancePreference;
  @override
  final double? lastKnownLat;
  @override
  final double? lastKnownLng;

  @override
  String toString() {
    return 'User(id: $id, phoneNumber: $phoneNumber, username: $username, isProfileComplete: $isProfileComplete, email: $email, fullName: $fullName, photoUrl: $photoUrl, coverImageUrl: $coverImageUrl, age: $age, gender: $gender, vehicleModel: $vehicleModel, vehicleRegNo: $vehicleRegNo, vehicleManufacturer: $vehicleManufacturer, emergencyContactName: $emergencyContactName, emergencyContactRelationship: $emergencyContactRelationship, emergencyContactNumber: $emergencyContactNumber, bloodGroup: $bloodGroup, ridingPreferences: $ridingPreferences, followers: $followers, following: $following, blockedUsers: $blockedUsers, savedRides: $savedRides, rideDistancePreference: $rideDistancePreference, lastKnownLat: $lastKnownLat, lastKnownLng: $lastKnownLng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.isProfileComplete, isProfileComplete) ||
                other.isProfileComplete == isProfileComplete) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.vehicleModel, vehicleModel) ||
                other.vehicleModel == vehicleModel) &&
            (identical(other.vehicleRegNo, vehicleRegNo) ||
                other.vehicleRegNo == vehicleRegNo) &&
            (identical(other.vehicleManufacturer, vehicleManufacturer) ||
                other.vehicleManufacturer == vehicleManufacturer) &&
            (identical(other.emergencyContactName, emergencyContactName) ||
                other.emergencyContactName == emergencyContactName) &&
            (identical(
                  other.emergencyContactRelationship,
                  emergencyContactRelationship,
                ) ||
                other.emergencyContactRelationship ==
                    emergencyContactRelationship) &&
            (identical(other.emergencyContactNumber, emergencyContactNumber) ||
                other.emergencyContactNumber == emergencyContactNumber) &&
            (identical(other.bloodGroup, bloodGroup) ||
                other.bloodGroup == bloodGroup) &&
            const DeepCollectionEquality().equals(
              other._ridingPreferences,
              _ridingPreferences,
            ) &&
            const DeepCollectionEquality().equals(
              other._followers,
              _followers,
            ) &&
            const DeepCollectionEquality().equals(
              other._following,
              _following,
            ) &&
            const DeepCollectionEquality().equals(
              other._blockedUsers,
              _blockedUsers,
            ) &&
            const DeepCollectionEquality().equals(
              other._savedRides,
              _savedRides,
            ) &&
            (identical(other.rideDistancePreference, rideDistancePreference) ||
                other.rideDistancePreference == rideDistancePreference) &&
            (identical(other.lastKnownLat, lastKnownLat) ||
                other.lastKnownLat == lastKnownLat) &&
            (identical(other.lastKnownLng, lastKnownLng) ||
                other.lastKnownLng == lastKnownLng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    phoneNumber,
    username,
    isProfileComplete,
    email,
    fullName,
    photoUrl,
    coverImageUrl,
    age,
    gender,
    vehicleModel,
    vehicleRegNo,
    vehicleManufacturer,
    emergencyContactName,
    emergencyContactRelationship,
    emergencyContactNumber,
    bloodGroup,
    const DeepCollectionEquality().hash(_ridingPreferences),
    const DeepCollectionEquality().hash(_followers),
    const DeepCollectionEquality().hash(_following),
    const DeepCollectionEquality().hash(_blockedUsers),
    const DeepCollectionEquality().hash(_savedRides),
    rideDistancePreference,
    lastKnownLat,
    lastKnownLng,
  ]);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    required final String id,
    required final String phoneNumber,
    final String? username,
    final bool isProfileComplete,
    final String? email,
    final String? fullName,
    final String? photoUrl,
    final String? coverImageUrl,
    final int? age,
    final String? gender,
    final String? vehicleModel,
    final String? vehicleRegNo,
    final String? vehicleManufacturer,
    final String? emergencyContactName,
    final String? emergencyContactRelationship,
    final String? emergencyContactNumber,
    final String? bloodGroup,
    final List<String> ridingPreferences,
    final List<String> followers,
    final List<String> following,
    final List<String> blockedUsers,
    final List<String> savedRides,
    final double rideDistancePreference,
    final double? lastKnownLat,
    final double? lastKnownLng,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get id;
  @override
  String get phoneNumber;
  @override
  String? get username;
  @override
  bool get isProfileComplete;
  @override
  String? get email;
  @override
  String? get fullName;
  @override
  String? get photoUrl;
  @override
  String? get coverImageUrl;
  @override
  int? get age;
  @override
  String? get gender;
  @override
  String? get vehicleModel;
  @override
  String? get vehicleRegNo;
  @override
  String? get vehicleManufacturer;
  @override
  String? get emergencyContactName;
  @override
  String? get emergencyContactRelationship;
  @override
  String? get emergencyContactNumber;
  @override
  String? get bloodGroup;
  @override
  List<String> get ridingPreferences;
  @override
  List<String> get followers;
  @override
  List<String> get following;
  @override
  List<String> get blockedUsers;
  @override
  List<String> get savedRides;
  @override
  double get rideDistancePreference;
  @override
  double? get lastKnownLat;
  @override
  double? get lastKnownLng;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
