import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../core/presentation/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for animations to complete and auth to initialize
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);

    // Navigate based on auth state
    authState.when(
      data: (user) {
        if (user != null &&
            user.username != null &&
            user.username!.isNotEmpty) {
          context.go('/home');
        } else if (user != null) {
          context.go('/profile-setup');
        } else {
          context.go('/login');
        }
      },
      loading: () {
        // Stay on splash a bit longer
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) context.go('/login');
        });
      },
      error: (_, __) {
        context.go('/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with scale and fade animation
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAqua.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.two_wheeler,
                    size: 60,
                    color: Colors.white,
                  ),
                )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // App Name with shimmer effect
            ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ).createShader(bounds),
                  child: const Text(
                    'RiderMatch',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: 1800.ms,
                  color: Colors.white.withValues(alpha: 0.3),
                )
                .fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 48),

            // Loading indicator with pulse animation
            SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.primaryAqua : AppColors.primaryBlue,
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(delay: 400.ms)
                .scale(
                  duration: 1000.ms,
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                ),
          ],
        ),
      ),
    );
  }
}
