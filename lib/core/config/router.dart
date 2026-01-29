import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/ride/presentation/main_screen.dart';
import '../../features/profile/presentation/profile_setup_screen.dart';
import '../../features/ride/presentation/create_ride_screen.dart';
import '../../features/ride/presentation/ride_detail_screen.dart';
import '../../features/ride/presentation/location_picker_screen.dart';
import '../../features/ride/presentation/manage_participants_screen.dart';
import '../../features/ride/domain/entities/ride.dart';
import '../../features/profile/presentation/user_profile_screen.dart';
import '../../features/profile/presentation/user_search_screen.dart';
import '../../features/profile/presentation/my_profile_loader.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/ride/presentation/notification_center_screen.dart';
import '../../features/chat/presentation/direct_chats_screen.dart';
import '../../features/chat/presentation/direct_chat_conversation_screen.dart';
import '../../features/chat/presentation/ride_chat_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier._redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/create-ride',
        builder: (context, state) {
          final ride = state.extra as Ride?;
          return CreateRideScreen(rideToEdit: ride);
        },
      ),
      GoRoute(
        path: '/ride-detail',
        builder: (context, state) {
          final ride = state.extra as Ride;
          return RideDetailScreen(ride: ride);
        },
      ),
      GoRoute(
        path: '/manage-participants',
        builder: (context, state) {
          final ride = state.extra as Ride;
          return ManageParticipantsScreen(ride: ride);
        },
      ),
      GoRoute(
        path: '/location-picker',
        builder: (context, state) => const LocationPickerScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) {
          final userToEdit = state.extra as User?;
          return ProfileSetupScreen(userToEdit: userToEdit);
        },
      ),
      GoRoute(
        path: '/user-profile',
        builder: (context, state) {
          final user = state.extra as User?;
          return UserProfileScreen(
            userId: user?.id ?? 'mock_user_1',
            initialUser: user,
          );
        },
      ),
      GoRoute(
        path: '/user-search',
        builder: (context, state) => const UserSearchScreen(),
      ),
      GoRoute(
        path: '/my-profile',
        builder: (context, state) => const MyProfileLoader(),
      ),
      GoRoute(
        path: '/notification-center',
        builder: (context, state) => const NotificationCenterScreen(),
      ),
      GoRoute(
        path: '/direct-chats',
        builder: (context, state) => const DirectChatsScreen(),
      ),
      GoRoute(
        path: '/direct-chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return DirectChatConversationScreen(chatId: chatId);
        },
      ),
      GoRoute(
        path: '/ride-chat/:rideId',
        builder: (context, state) {
          final rideId = state.pathParameters['rideId']!;
          return RideChatScreen(rideId: rideId);
        },
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<User?>>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);

    final bool isLoading = authState.isLoading;
    final bool hasUser = authState.value != null;
    final bool isLoggingIn =
        state.matchedLocation == '/login' || state.matchedLocation == '/otp';
    final bool isSplash = state.matchedLocation == '/splash';

    if (isSplash || isLoading) return null;

    if (hasUser) {
      if (isLoggingIn) return '/home';
    } else {
      // If we are NOT logging in, and we have NO user, go to login
      if (!isLoggingIn) return '/login';
    }

    return null;
  }
}
