import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/ride.dart';
import 'widgets/ride_map_widget.dart';
import 'ride_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../auth/domain/entities/user.dart' as domain; // Aliased import
import '../../chat/presentation/ride_chat_widget.dart';
import 'widgets/ride_invite_bottom_sheet.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../../core/utils/error_handler.dart';

class RideDetailScreen extends ConsumerWidget {
  final Ride ride;

  const RideDetailScreen({super.key, required this.ride});

  Future<void> _launchNavigation(BuildContext context) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${ride.fromLat},${ride.fromLng}';
    final uri = Uri.parse(url);

    debugPrint(
      '🔔 Navigating to: $url (Coords: ${ride.fromLat}, ${ride.fromLng})',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Google Maps...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint(
          '⚠️ External app launch failed, trying platform default (browser)...',
        );
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Could not open maps or browser.'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('🚨 Error launching navigation URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${ErrorHandler.getErrorMessage(e)}')),
        );
      }
    }
  }

  void _showInviteSheet(BuildContext context, Ride ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RideInviteBottomSheet(ride: ride),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.value?.id ?? '';

    // Watch for FRESH updates to this specific ride
    final asyncRide = ref.watch(rideDetailProvider(ride.id));

    // Logic: Use fresh data if available.
    // If loading, fall back to 'ride' passed in arg but be aware it might be partial.
    // If error, show error or fallback.

    return asyncRide.when(
      data: (freshRide) {
        // If null (deleted?), fallback to passed ride but maybe show deleted state?
        final currentRide = freshRide ?? ride;
        return _buildScaffold(context, ref, currentRide, currentUserId);
      },
      loading: () =>
          _buildScaffold(context, ref, ride, currentUserId, isLoading: true),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(ErrorHandler.getErrorMessage(e))),
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    WidgetRef ref,
    Ride currentRide,
    String currentUserId, {
    bool isLoading = false,
  }) {
    final isCreator = currentRide.creatorId == currentUserId;
    final isParticipant = currentRide.participantIds.contains(currentUserId);
    final isMember = isCreator || isParticipant;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ride Details'),
          actions: [
            if (isCreator)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.push('/create-ride', extra: currentRide),
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details', icon: Icon(Icons.info_outline)),
              Tab(text: 'Chat', icon: Icon(Icons.chat_bubble_outline)),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  Stack(
                    children: [
                      _buildDetailsTab(context, ref, currentRide),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildStickyBottomBar(
                          context,
                          ref,
                          currentRide,
                          currentUserId,
                        ),
                      ),
                    ],
                  ),
                  RideChatWidget(
                    rideId: currentRide.id,
                    isMember: isCreator || isParticipant,
                    currentUserId: currentUserId,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, WidgetRef ref, Ride ride) {
    final dateStr = DateFormat(
      'EEEE, MMM d, yyyy • h:mm a',
    ).format(ride.dateTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ride.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ride.difficulty == 'Hard'
                      ? Colors.red[100]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ride.difficulty,
                  style: TextStyle(
                    color: ride.difficulty == 'Hard'
                        ? Colors.red[800]
                        : Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.people, size: 20, color: Colors.grey),
              const SizedBox(width: 4),
              // Use participants count or length of array
              Text('${ride.participantIds.length} Riders'),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(Icons.calendar_today, dateStr),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.location_on,
            'Total Distance: ${ride.validDistanceKm} km',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            ride.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Participants',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildParticipantsList(ref, ride),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Route',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          RideMapWidget(ride: ride),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () => _launchNavigation(context),
              icon: const Icon(Icons.directions),
              label: const Text(
                'Start navigation to starting point',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildParticipantsList(WidgetRef ref, Ride ride) {
    if (ride.participantIds.isEmpty) {
      return const Text('No participants yet.');
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ride.participantIds.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final userId = ride.participantIds[index];
          return ParticipantItem(userId: userId);
        },
      ),
    );
  }

  Widget _buildStickyBottomBar(
    BuildContext context,
    WidgetRef ref,
    Ride ride,
    String currentUserId,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: _buildActionButtons(context, ref, ride, currentUserId),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    Ride ride,
    String currentUserId,
  ) {
    final isCreator = ride.creatorId == currentUserId;
    final isParticipant = ride.participantIds.contains(currentUserId);
    final isPending = ride.joinRequestIds.contains(currentUserId);

    if (isCreator) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showInviteSheet(context, ride),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
              ),
              child: const Text('Invite'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  context.push('/manage-participants', extra: ride),
              child: const Text('Manage'),
            ),
          ),
        ],
      );
    }

    if (isPending) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.grey[200],
        ),
        child: const Text('Awaiting Confirmation'),
      );
    }

    if (isParticipant) {
      return ElevatedButton(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cancel Ride?'),
              content: const Text(
                'Are you sure you want to leave this ride? The creator will be notified.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Back'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Confirm Leave',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await ref
                .read(rideControllerProvider.notifier)
                .removeParticipant(ride.id, currentUserId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You have left the ride.')),
              );
              context.pop();
            }
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Text('Cancel My Participation'),
      );
    }

    return ElevatedButton(
      onPressed: () async {
        await ref
            .read(rideControllerProvider.notifier)
            .requestToJoin(ride.id, currentUserId);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Join Request Sent!')));
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Join Ride'),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}

class ParticipantItem extends ConsumerWidget {
  final String userId;
  const ParticipantItem({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Explicitly cast or rely on provider type
    final AsyncValue<domain.User?> userAsync = ref.watch(
      userProfileProvider(userId),
    );

    return userAsync.when(
      data: (user) {
        final displayName = user?.fullName ?? 'Unknown';
        return GestureDetector(
          onTap: () {
            if (user != null) {
              context.push('/user-profile', extra: user);
            }
          },
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: (user?.photoUrl != null)
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: (user?.photoUrl == null)
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 70,
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: CircleAvatar(radius: 30, child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: CircleAvatar(radius: 30, child: Icon(Icons.error_outline)),
      ),
    );
  }
}
