// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_stop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RideStopImpl _$$RideStopImplFromJson(Map<String, dynamic> json) =>
    _$RideStopImpl(
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$$RideStopImplToJson(_$RideStopImpl instance) =>
    <String, dynamic>{
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
    };
