// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String,
  phoneNumber: json['phoneNumber'] as String,
  username: json['username'] as String?,
  isProfileComplete: json['isProfileComplete'] as bool? ?? false,
  email: json['email'] as String?,
  fullName: json['fullName'] as String?,
  photoUrl: json['photoUrl'] as String?,
  coverImageUrl: json['coverImageUrl'] as String?,
  age: (json['age'] as num?)?.toInt(),
  gender: json['gender'] as String?,
  vehicleModel: json['vehicleModel'] as String?,
  vehicleRegNo: json['vehicleRegNo'] as String?,
  vehicleManufacturer: json['vehicleManufacturer'] as String?,
  emergencyContactName: json['emergencyContactName'] as String?,
  emergencyContactRelationship: json['emergencyContactRelationship'] as String?,
  emergencyContactNumber: json['emergencyContactNumber'] as String?,
  bloodGroup: json['bloodGroup'] as String?,
  ridingPreferences:
      (json['ridingPreferences'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  followers:
      (json['followers'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  following:
      (json['following'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  blockedUsers:
      (json['blockedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  rideDistancePreference:
      (json['rideDistancePreference'] as num?)?.toDouble() ?? 50.0,
  lastKnownLat: (json['lastKnownLat'] as num?)?.toDouble(),
  lastKnownLng: (json['lastKnownLng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phoneNumber': instance.phoneNumber,
      'username': instance.username,
      'isProfileComplete': instance.isProfileComplete,
      'email': instance.email,
      'fullName': instance.fullName,
      'photoUrl': instance.photoUrl,
      'coverImageUrl': instance.coverImageUrl,
      'age': instance.age,
      'gender': instance.gender,
      'vehicleModel': instance.vehicleModel,
      'vehicleRegNo': instance.vehicleRegNo,
      'vehicleManufacturer': instance.vehicleManufacturer,
      'emergencyContactName': instance.emergencyContactName,
      'emergencyContactRelationship': instance.emergencyContactRelationship,
      'emergencyContactNumber': instance.emergencyContactNumber,
      'bloodGroup': instance.bloodGroup,
      'ridingPreferences': instance.ridingPreferences,
      'followers': instance.followers,
      'following': instance.following,
      'blockedUsers': instance.blockedUsers,
      'rideDistancePreference': instance.rideDistancePreference,
      'lastKnownLat': instance.lastKnownLat,
      'lastKnownLng': instance.lastKnownLng,
    };
