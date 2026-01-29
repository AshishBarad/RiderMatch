import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Artificial delay to show animations and allow initial data fetch
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      // Trigger initial data fetches if any
      // ref.read(myRidesProvider.future),
    ]);

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Animation
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
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.motorcycle_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                )
                .animate()
                .slideY(
                  begin: 1.5,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 600.ms)
                .shimmer(delay: 1500.ms, duration: 1500.ms),
            const SizedBox(height: 24),
            // App Name Animation
            Text(
                  'RiderMatch',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                )
                .animate()
                .fadeIn(delay: 500.ms, duration: 800.ms)
                .slideY(
                  begin: 0.5,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 8),
            // Tagline Animation
            Text(
              'Ride Together. Explore More.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
