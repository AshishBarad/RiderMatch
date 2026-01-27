import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final LoginUseCase _loginUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _authRepository;

  AuthController(
    this._loginUseCase,
    this._verifyOtpUseCase,
    this._getCurrentUserUseCase,
    this._logoutUseCase,
    this._authRepository,
  ) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    state = await AsyncValue.guard(() => _getCurrentUserUseCase());
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _logoutUseCase();
    state = const AsyncValue.data(null);
  }

  Future<void> login(String phoneNumber) async {
    state = const AsyncValue.loading();
    try {
      debugPrint('🔌 AuthController: Calling loginUseCase for $phoneNumber');
      await _loginUseCase(phoneNumber);
      debugPrint('✅ AuthController: loginUseCase completed');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('❌ AuthController: loginUseCase failed: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> verifyOtp(String otp) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Get the actual verification ID from the repository
      final verificationId = _authRepository.getVerificationId();

      if (verificationId == null || verificationId.isEmpty) {
        throw Exception('No verification ID found. Please request OTP again.');
      }

      return await _verifyOtpUseCase(verificationId, otp);
    });
  }
}
