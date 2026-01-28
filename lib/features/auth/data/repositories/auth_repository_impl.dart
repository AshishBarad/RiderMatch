import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> loginWithPhone(String phoneNumber) async {
    return remoteDataSource.loginWithPhone(phoneNumber);
  }

  @override
  Future<User> verifyOtp(String verificationId, String otp) async {
    return remoteDataSource.verifyOtp(verificationId, otp);
  }

  @override
  Future<User?> getCurrentUser() async {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Stream<User?> watchCurrentUser() {
    return remoteDataSource.watchCurrentUser();
  }

  @override
  Future<void> logout() async {
    return remoteDataSource.logout();
  }

  @override
  String? getVerificationId() {
    return remoteDataSource.getVerificationId();
  }
}
