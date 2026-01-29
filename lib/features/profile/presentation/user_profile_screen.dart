import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../ride/presentation/ride_providers.dart';
import '../../../core/presentation/widgets/ride_card.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_typography.dart';
import '../../../core/presentation/widgets/profile_avatar.dart';
import '../../../core/presentation/widgets/section_header.dart';
import '../../../core/presentation/theme/theme_mode_provider.dart';
import 'profile_providers.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;
  final dynamic initialUser;
  const UserProfileScreen({super.key, required this.userId, this.initialUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.value?.id ?? '';
    final isMe = userId == currentUserId;
    final userAsync = ref.watch(userProfileProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        image: user.coverImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(user.coverImageUrl!),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withValues(alpha: 0.1),
                                  BlendMode.darken,
                                ),
                              )
                            : null,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 140,
                      child:
                          ProfileAvatar(
                            imageUrl: user.photoUrl,
                            radius: 60,
                            borderWidth: 4,
                            borderColor: Colors.white,
                          ).animate().scale(
                            delay: 200.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                Text(user.fullName ?? 'Rider', style: AppTypography.header),
                Text(
                  user.username != null
                      ? '@${user.username}'
                      : 'Joined Recently',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildStatsRow(
                  user.followers.length,
                  user.following.length,
                  12,
                ),
                const SizedBox(height: 32),
                if (isMe) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SectionHeader(title: 'My Saved Rides'),
                  ),
                  const SizedBox(height: 12),
                  _buildSavedRidesCarousel(),
                ],
                const SizedBox(height: 24),
                _buildActionsList(context, ref, isMe, user),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildStatsRow(int followers, int following, int rides) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Followers', followers.toString()),
        Container(
          height: 30,
          width: 1,
          color: AppColors.textTertiary.withValues(alpha: 0.2),
        ),
        _buildStatItem('Following', following.toString()),
        Container(
          height: 30,
          width: 1,
          color: AppColors.textTertiary.withValues(alpha: 0.2),
        ),
        _buildStatItem('Rides', rides.toString()),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.title.copyWith(color: AppColors.primaryAqua),
        ),
        Text(label, style: AppTypography.caption),
      ],
    );
  }

  Widget _buildSavedRidesCarousel() {
    return SizedBox(
      height: 350, // Increased further to be safe
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            child: RideCard(
              rideName: 'Munnar Expedition',
              distance: '240 km',
              date: 'Weekend',
              onTap: () {},
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionsList(
    BuildContext context,
    WidgetRef ref,
    bool isMe,
    dynamic user,
  ) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildActionTile(
            Icons.person_outline,
            isMe ? 'Edit Profile' : 'View Details',
            () {
              if (isMe) context.push('/profile-setup', extra: user);
            },
          ),
          _buildActionTile(
            Icons.notifications_outlined,
            'Notifications',
            () {},
          ),
          // Dark Mode Toggle
          if (isMe) _buildDarkModeToggle(context, ref, isDarkMode),
          _buildActionTile(Icons.shield_outlined, 'Privacy & Safety', () {}),
          _buildActionTile(Icons.help_outline, 'Help & Support', () {}),
          if (isMe)
            _buildActionTile(
              Icons.logout,
              'Logout',
              () => _showLogoutDialog(context, ref),
              isDestructive: true,
            ),
          if (isMe && kDebugMode)
            _buildActionTile(
              Icons.bug_report_outlined,
              'Seed Test Data (100 Rides)',
              () => _showSeedDialog(context, ref),
            ),
        ],
      ),
    );
  }

  void _showSeedDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seed Test Data?'),
        content: const Text(
          'This will clear ALL existing rides and add 100 new ones across India. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⏳ Seeding 100 rides across India...'),
                ),
              );
              await ref.read(rideControllerProvider.notifier).seedTestData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '✅ Seeding complete! Discover rides near you.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Seed Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : AppColors.primaryAqua.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.primaryAqua,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.title.copyWith(
          fontSize: 16,
          color: isDestructive ? Colors.red : AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: AppColors.textTertiary,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to ride out?'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Stay')),
          TextButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.pop();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle(
    BuildContext context,
    WidgetRef ref,
    bool isDarkMode,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.primaryAqua.withValues(alpha: 0.2)
              : AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: isDarkMode ? AppColors.primaryAqua : AppColors.warning,
          size: 20,
        ),
      ),
      title: Text(
        'Dark Mode',
        style: AppTypography.title.copyWith(fontSize: 16),
      ),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (_) {
          ref.read(themeModeProvider.notifier).toggleTheme();
        },
        activeColor: AppColors.primaryAqua,
      ),
    );
  }
}
