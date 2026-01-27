import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/ride.dart';
import 'ride_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import 'package:go_router/go_router.dart';
import '../../auth/domain/entities/user.dart';
import '../../../../core/utils/error_handler.dart';

class ManageParticipantsScreen extends ConsumerStatefulWidget {
  final Ride ride;
  const ManageParticipantsScreen({super.key, required this.ride});

  @override
  ConsumerState<ManageParticipantsScreen> createState() =>
      _ManageParticipantsScreenState();
}

class _ManageParticipantsScreenState
    extends ConsumerState<ManageParticipantsScreen> {
  late Ride _currentRide;

  @override
  void initState() {
    super.initState();
    _currentRide = widget.ride;
  }

  @override
  Widget build(BuildContext context) {
    // Watch specific ride provider for fresh data (fetches by ID)
    final rideAsync = ref.watch(rideDetailProvider(widget.ride.id));

    _currentRide = rideAsync.value ?? _currentRide;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Participants'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(rideDetailProvider(widget.ride.id));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              tooltip: 'Delete Ride',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Ride?'),
                    content: const Text(
                      'This will permanently delete the ride and notify all participants. This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close dialog
                          try {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Deleting ride...')),
                            );
                            await ref
                                .read(rideControllerProvider.notifier)
                                .deleteRide(_currentRide.id, _currentRide);

                            if (context.mounted) {
                              // Pop to home (pop manage, pop details)
                              context.go('/home');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ride deleted')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error deleting: ${ErrorHandler.getErrorMessage(e)}',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Participants'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: rideAsync.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [_buildParticipantsList(), _buildRequestsList()],
              ),
      ),
    );
  }

  Widget _buildParticipantsList() {
    if (_currentRide.participantIds.isEmpty) {
      return const Center(child: Text('No participants yet.'));
    }
    return ListView.builder(
      itemCount: _currentRide.participantIds.length,
      itemBuilder: (context, index) {
        final userId = _currentRide.participantIds[index];

        return FutureBuilder<User?>(
          future: ref.read(getUserProfileUseCaseProvider)(userId),
          builder: (context, snapshot) {
            final user = snapshot.data;
            final hasEmergencyInfo =
                user?.emergencyContactName != null &&
                user!.emergencyContactName!.isNotEmpty;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(user?.fullName ?? 'User $userId'),
              subtitle: user?.vehicleModel != null
                  ? Text(user!.vehicleModel!)
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasEmergencyInfo)
                    IconButton(
                      icon: const Icon(
                        Icons.contact_emergency,
                        color: Colors.blue,
                      ),
                      tooltip: 'View Emergency Info',
                      onPressed: () => _showEmergencyInfo(context, user),
                    ),
                  if (userId == _currentRide.creatorId)
                    const Chip(label: Text('Creator'))
                  else
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        ref
                            .read(rideControllerProvider.notifier)
                            .removeParticipant(_currentRide.id, userId);
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEmergencyInfo(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Info: ${user.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blood Group: ${user.bloodGroup ?? 'Not specified'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Emergency Contact:',
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            Text('Name: ${user.emergencyContactName}'),
            Text('Relation: ${user.emergencyContactRelationship ?? 'Unknown'}'),
            Text('Phone: ${user.emergencyContactNumber ?? 'No number'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    if (_currentRide.joinRequestIds.isEmpty) {
      return const Center(child: Text('No join requests.'));
    }
    return ListView.builder(
      itemCount: _currentRide.joinRequestIds.length,
      itemBuilder: (context, index) {
        final userId = _currentRide.joinRequestIds[index];

        return FutureBuilder<User?>(
          future: ref.read(getUserProfileUseCaseProvider)(userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Loading...'),
              );
            }

            final user = snapshot.data;
            final subtitle = [
              if (user?.age != null) '${user!.age} yrs',
              if (user?.vehicleModel != null) user!.vehicleModel,
            ].join(' • ');

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'User $userId',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (subtitle.isNotEmpty)
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          icon: Icons.check,
                          color: Colors.green,
                          onPressed: () {
                            ref
                                .read(rideControllerProvider.notifier)
                                .acceptJoinRequest(_currentRide.id, userId);
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.close,
                          color: Colors.red,
                          onPressed: () {
                            ref
                                .read(rideControllerProvider.notifier)
                                .rejectJoinRequest(_currentRide.id, userId);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          // color: color.withOpacity(0.1), // Optional: light fill
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
