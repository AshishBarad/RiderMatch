import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/entities/user.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/verify_otp_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import 'controller/auth_controller.dart';

final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
      return AuthController(
        ref.watch(loginUseCaseProvider),
        ref.watch(verifyOtpUseCaseProvider),
        ref.watch(getCurrentUserUseCaseProvider),
        ref.watch(logoutUseCaseProvider),
        ref.watch(authRepositoryProvider),
      );
    });
