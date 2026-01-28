import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String phoneNumber,
    String? username,
    @Default(false) bool isProfileComplete,
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
    @Default([]) List<String> ridingPreferences,
    @Default([]) List<String> followers,
    @Default([]) List<String> following,
    @Default([]) List<String> blockedUsers,
    @Default(50.0) double rideDistancePreference,
    double? lastKnownLat,
    double? lastKnownLng,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
