import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride.freezed.dart';
part 'ride.g.dart';

@freezed
class Ride with _$Ride {
  const factory Ride({
    required String id,
    required String creatorId,
    @Default('Unknown') String creatorGender,
    required String title,
    required String description,
    required String fromLocation,
    @Default(0.0) double fromLat,
    @Default(0.0) double fromLng,
    required String toLocation,
    @Default(0.0) double toLat,
    @Default(0.0) double toLng,
    required DateTime dateTime,
    required double validDistanceKm,
    required String difficulty, // Easy, Medium, Hard
    @Default('') String encodedPolyline,
    @Default(false) bool isPrivate,
    @Default([]) List<String> joinRequestIds,
    @Default([]) List<String> participantIds,
    @Default([]) List<String> invitedUserIds,
    @Default([]) List<String> participantGenders,
  }) = _Ride;

  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);
}
