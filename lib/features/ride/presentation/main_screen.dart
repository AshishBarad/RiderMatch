import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';
import 'my_rides_screen.dart';
import '../../chat/presentation/direct_chats_screen.dart';
import '../../profile/presentation/my_profile_loader.dart';
import '../../../core/presentation/theme/app_colors.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyRidesScreen(),
    const DirectChatsScreen(),
    const MyProfileLoader(),
  ];

  Future<void> _showExitDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit RiderMatch?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => true,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (_currentIndex != 0) {
            setState(() => _currentIndex = 0);
          } else {
            await _showExitDialog();
          }
        },
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(index: _currentIndex, children: _screens),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/create-ride'),
            elevation: 8,
            backgroundColor: AppColors.primaryAqua,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
          floatingActionButtonLocation: const _NudgedCenterDockedLocation(),
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            elevation: 20,
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    0,
                    Icons.explore_outlined,
                    Icons.explore,
                    'Discover',
                  ),
                  _buildNavItem(
                    1,
                    Icons.motorcycle_outlined,
                    Icons.motorcycle,
                    'Rides',
                  ),
                  const SizedBox(width: 40), // Space for FAB
                  _buildNavItem(
                    2,
                    Icons.chat_bubble_outline,
                    Icons.chat_bubble,
                    'Chats',
                  ),
                  _buildNavItem(
                    3,
                    Icons.person_outline,
                    Icons.person,
                    'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? AppColors.primaryAqua
                    : AppColors.textTertiary,
                size: 26,
              )
              .animate(target: isSelected ? 1 : 0)
              .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? AppColors.primaryAqua
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NudgedCenterDockedLocation extends FloatingActionButtonLocation {
  const _NudgedCenterDockedLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset standardDocked = FloatingActionButtonLocation.centerDocked
        .getOffset(scaffoldGeometry);
    return Offset(standardDocked.dx, standardDocked.dy + 8);
  }
}
