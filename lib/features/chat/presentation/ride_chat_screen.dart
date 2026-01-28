import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ride/presentation/ride_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import 'ride_chat_widget.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_typography.dart';

class RideChatScreen extends ConsumerWidget {
  final String rideId;

  const RideChatScreen({super.key, required this.rideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideAsync = ref.watch(rideDetailProvider(rideId));
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.value?.id ?? '';

    return rideAsync.when(
      data: (ride) {
        if (ride == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chat')),
            body: const Center(child: Text('Ride not found')),
          );
        }

        final isMember =
            ride.participantIds.contains(currentUserId) ||
            ride.creatorId == currentUserId;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.title,
                  style: AppTypography.title.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Group Chat',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryAqua,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0.5,
          ),
          body: RideChatWidget(
            rideId: rideId,
            isMember: isMember,
            currentUserId: currentUserId,
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
