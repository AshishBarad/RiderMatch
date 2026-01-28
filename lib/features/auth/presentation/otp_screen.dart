import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_providers.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_typography.dart';
import '../../../core/presentation/widgets/gradient_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onVerify() async {
    if (_otpController.text.length != 6) {
      _showError('Please enter the 6-digit OTP');
      return;
    }
    await ref
        .read(authControllerProvider.notifier)
        .verifyOtp(_otpController.text);

    if (!mounted) return;

    final state = ref.read(authControllerProvider);

    if (!state.hasError) {
      final user = state.value;
      bool isProfileComplete = user?.isProfileComplete ?? false;

      if (isProfileComplete) {
        context.go('/home');
      } else {
        context.go('/profile-setup');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Verification',
                            style: AppTypography.header.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter the code sent to your phone',
                            style: AppTypography.body.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 48),
                          // OTP Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: AppColors.softShadow,
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 6,
                                  style: AppTypography.header.copyWith(
                                    fontSize: 32,
                                    letterSpacing: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '000000',
                                    hintStyle: AppTypography.header.copyWith(
                                      fontSize: 32,
                                      letterSpacing: 12,
                                      color: AppColors.textTertiary.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                    counterText: '',
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.textTertiary
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.primaryAqua,
                                        width: 2,
                                      ),
                                    ),
                                    fillColor: Colors.transparent,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                if (state.isLoading)
                                  const CircularProgressIndicator()
                                else
                                  GradientButton(
                                    text: 'Verify OTP',
                                    onPressed: _onVerify,
                                    gradient: AppColors.accentGradient,
                                  ),
                                const SizedBox(height: 20),
                                Text(
                                  'Use 123456 for DEV mode',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Text(
                                '${state.error}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
