import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import 'user_profile_screen.dart';

class MyProfileLoader extends ConsumerWidget {
  const MyProfileLoader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Not logged in')));
        }

        // Show the user's own profile using UserProfileScreen
        // This screen has view mode with edit button and logout button
        return UserProfileScreen(userId: user.id, initialUser: user);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error loading profile: $error'))),
    );
  }
}
