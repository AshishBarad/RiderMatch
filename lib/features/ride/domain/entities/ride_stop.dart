import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_stop.freezed.dart';
part 'ride_stop.g.dart';

@freezed
class RideStop with _$RideStop {
  const factory RideStop({
    required String address,
    required double lat,
    required double lng,
  }) = _RideStop;

  factory RideStop.fromJson(Map<String, dynamic> json) =>
      _$RideStopFromJson(json);
}
