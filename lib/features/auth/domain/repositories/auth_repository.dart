import '../entities/user.dart';

abstract class AuthRepository {
  Future<void> loginWithPhone(String phoneNumber);
  Future<User> verifyOtp(String verificationId, String otp);
  Future<User?> getCurrentUser();
  Future<void> logout();
  String? getVerificationId();
}
