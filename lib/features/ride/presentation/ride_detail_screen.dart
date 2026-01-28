import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../domain/entities/ride.dart';
import 'ride_providers.dart';
import 'widgets/ride_map_widget.dart';
import 'widgets/ride_invite_bottom_sheet.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_typography.dart';
import '../../../core/presentation/widgets/gradient_button.dart';
import '../../../core/presentation/widgets/profile_avatar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class RideDetailScreen extends ConsumerWidget {
  final Ride ride;
  const RideDetailScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRide = ref.watch(rideDetailProvider(ride.id));
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.value?.id ?? '';

    return asyncRide.when(
      data: (freshRide) =>
          _buildBody(context, ref, freshRide ?? ride, currentUserId),
      loading: () =>
          _buildBody(context, ref, ride, currentUserId, isLoading: true),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    Ride ride,
    String currentUserId, {
    bool isLoading = false,
  }) {
    final isOwner = ride.creatorId == currentUserId;
    final isParticipant = ride.participantIds.contains(currentUserId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Map Banner
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  RideMapWidget(ride: ride).animate().fadeIn(duration: 600.ms),
                  // Gradient Overlay for readability - wrap with IgnorePointer to allow map interaction
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(
                0,
                -15,
              ), // Reduced negative offset for more map visibility
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 50,
                      spreadRadius: 5,
                      offset: const Offset(0, -20),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    48,
                    24,
                    24,
                  ), // Increased top padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(ride),
                      const SizedBox(height: 24),
                      _buildRideInfo(ride),
                      const SizedBox(height: 32),
                      Text(
                        'Description',
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Divider(height: 24, thickness: 1),
                      const SizedBox(height: 12),
                      Text(
                        ride.description,
                        style: AppTypography.body.copyWith(
                          color: Colors.black, // Max contrast
                          height: 1.6,
                          fontSize: 16, // Slightly larger
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildStopsList(ride),
                      const SizedBox(height: 32),
                      _buildParticipantsList(ride),
                      const SizedBox(height: 40),
                      _buildActionButton(
                        context,
                        ref,
                        ride,
                        isOwner,
                        isParticipant,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ).animate().slideY(begin: 0.2, curve: Curves.easeOutCubic).fadeIn(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Ride ride) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ride.isPrivate)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 14, color: AppColors.error),
                      SizedBox(width: 6),
                      Text(
                        'PRIVATE RIDE',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                ride.title,
                style: AppTypography.header.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.primaryAqua,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ride.toLocation,
                    style: AppTypography.body.copyWith(
                      color: AppColors.primaryAqua,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryAqua.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.primaryAqua,
            ),
            onPressed: () {
              final dateStr = DateFormat('MMM d, yyyy').format(ride.dateTime);
              Share.share(
                'Join me for this ride: ${ride.title} to ${ride.toLocation} on $dateStr!\n\n'
                'Check it out on RiderMatch.',
                subject: 'Ride Invitation: ${ride.title}',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRideInfo(Ride ride) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryAqua.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.calendar_today, 'Date', 'Tomorrow'),
          _buildInfoItem(Icons.speed, 'Difficulty', ride.difficulty),
          _buildInfoItem(
            Icons.route,
            'Distance',
            '${ride.validDistanceKm.round()}km',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textTertiary),
        const SizedBox(height: 8),
        Text(label, style: AppTypography.caption),
        Text(value, style: AppTypography.title.copyWith(fontSize: 14)),
      ],
    );
  }

  Widget _buildParticipantsList(Ride ride) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Participants', style: AppTypography.title),
            Text(
              '${ride.participantIds.length} joined',
              style: AppTypography.caption.copyWith(
                color: AppColors.primaryAqua,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ride.participantIds.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == ride.participantIds.length) {
                return GestureDetector(
                  onTap: () => _showInviteSheet(context, ride),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: AppColors.textTertiary),
                  ),
                );
              }
              return ProfileAvatar(radius: 22); // Generic for now
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    Ride ride,
    bool isOwner,
    bool isParticipant,
  ) {
    if (isOwner) {
      return Row(
        children: [
          Expanded(
            child: GradientButton(
              text: 'Manage Ride',
              onPressed: () => context.push('/create-ride', extra: ride),
              gradient: [Colors.grey[700]!, Colors.grey[800]!],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GradientButton(
              text: 'Open Chat',
              onPressed: () => context.push('/ride-chat/${ride.id}'),
              gradient: AppColors.primaryGradient,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: GradientButton(
            text: isParticipant ? 'Open Chat' : 'Join Ride',
            onPressed: () {
              if (isParticipant || isOwner) {
                context.push('/ride-chat/${ride.id}');
              } else {
                // Join logic
              }
            },
            gradient: isParticipant
                ? [AppColors.textTertiary, AppColors.textTertiary]
                : AppColors.primaryGradient,
          ),
        ),
        if (!isParticipant) ...[
          const SizedBox(width: 16),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.favorite_border,
                color: AppColors.accentOrange,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStopsList(Ride ride) {
    if (ride.stops.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stops',
          style: AppTypography.title.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Divider(height: 24, thickness: 1),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: ride.stops.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final stop = ride.stops[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAqua.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.primaryAqua,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stop ${index + 1}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        stop.address,
                        style: AppTypography.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showInviteSheet(BuildContext context, Ride ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RideInviteBottomSheet(ride: ride),
    );
  }
}
