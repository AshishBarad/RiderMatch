// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RideImpl _$$RideImplFromJson(Map<String, dynamic> json) => _$RideImpl(
  id: json['id'] as String,
  creatorId: json['creatorId'] as String,
  creatorGender: json['creatorGender'] as String? ?? 'Unknown',
  title: json['title'] as String,
  description: json['description'] as String,
  fromLocation: json['fromLocation'] as String,
  fromLat: (json['fromLat'] as num?)?.toDouble() ?? 0.0,
  fromLng: (json['fromLng'] as num?)?.toDouble() ?? 0.0,
  toLocation: json['toLocation'] as String,
  toLat: (json['toLat'] as num?)?.toDouble() ?? 0.0,
  toLng: (json['toLng'] as num?)?.toDouble() ?? 0.0,
  dateTime: DateTime.parse(json['dateTime'] as String),
  validDistanceKm: (json['validDistanceKm'] as num).toDouble(),
  difficulty: json['difficulty'] as String,
  encodedPolyline: json['encodedPolyline'] as String? ?? '',
  isPrivate: json['isPrivate'] as bool? ?? false,
  joinRequestIds:
      (json['joinRequestIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  invitedUserIds:
      (json['invitedUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  participantGenders:
      (json['participantGenders'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$RideImplToJson(_$RideImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorId': instance.creatorId,
      'creatorGender': instance.creatorGender,
      'title': instance.title,
      'description': instance.description,
      'fromLocation': instance.fromLocation,
      'fromLat': instance.fromLat,
      'fromLng': instance.fromLng,
      'toLocation': instance.toLocation,
      'toLat': instance.toLat,
      'toLng': instance.toLng,
      'dateTime': instance.dateTime.toIso8601String(),
      'validDistanceKm': instance.validDistanceKm,
      'difficulty': instance.difficulty,
      'encodedPolyline': instance.encodedPolyline,
      'isPrivate': instance.isPrivate,
      'joinRequestIds': instance.joinRequestIds,
      'participantIds': instance.participantIds,
      'invitedUserIds': instance.invitedUserIds,
      'participantGenders': instance.participantGenders,
    };
