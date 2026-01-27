import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart';
import 'my_rides_screen.dart';
import 'ride_providers.dart';
import '../../profile/presentation/my_profile_loader.dart';
import '../../../core/services/notification_service.dart';
import '../../chat/presentation/chat_providers.dart';
import '../../chat/presentation/direct_chats_screen.dart';

// ... imports

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
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(notificationServiceProvider, (previous, next) {
      final latest = next.latestNotification;
      if (latest != null) {
        // If user is already looking at this ride's chat, ignore the notification
        final currentActiveChat = ref.read(currentChatRideIdProvider);
        if (latest.rideId == currentActiveChat) {
          ref.read(notificationServiceProvider.notifier).markAsRead(latest.id);
          ref.read(notificationServiceProvider.notifier).clearLatest();
          return;
        }

        // Use post-frame callback to avoid showing SnackBar during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latest.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          latest.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.blue[800],
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'VIEW',
                textColor: Colors.white,
                onPressed: () async {
                  final rideId = latest.rideId;
                  // Mark as read
                  ref
                      .read(notificationServiceProvider.notifier)
                      .markAsRead(latest.id);
                  // Fetch ride details if not available
                  final ride = await ref.read(getRideByIdUseCaseProvider)(
                    rideId,
                  );
                  if (ride != null && context.mounted) {
                    context.push('/ride-detail', extra: ride);
                  }
                },
              ),
            ),
          );
          // Clear latest after showing snackbar so it doesn't trigger again on rebuild if state changes
          ref.read(notificationServiceProvider.notifier).clearLatest();
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        } else {
          await _showExitDialog();
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.motorcycle),
              label: 'My Rides',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
