import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/ride.dart';
import '../ride_providers.dart';
import '../../../profile/presentation/profile_providers.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/presentation/theme/app_colors.dart';

class RideInviteBottomSheet extends ConsumerStatefulWidget {
  final Ride ride;

  const RideInviteBottomSheet({super.key, required this.ride});

  @override
  ConsumerState<RideInviteBottomSheet> createState() =>
      _RideInviteBottomSheetState();
}

class _RideInviteBottomSheetState extends ConsumerState<RideInviteBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _shareButtonKey = GlobalKey();
  List<User> _searchResults = [];
  bool _isLoading = false;
  final Map<String, bool> _invitingUserIds = {};

  Future<void> _onSearch(String query) async {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final searchUseCase = ref.read(searchUsersUseCaseProvider);
      final results = await searchUseCase(query);

      // Filter out users who are already in the ride
      final filteredResults = results
          .where(
            (user) =>
                !widget.ride.participantIds.contains(user.id) &&
                widget.ride.creatorId != user.id,
          )
          .toList();

      if (mounted) {
        setState(() {
          _searchResults = filteredResults;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error searching users: ${ErrorHandler.getErrorMessage(e)}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _inviteUser(User user) async {
    setState(() {
      _invitingUserIds[user.id] = true;
    });

    try {
      // Call the controller to persist invitation
      await ref
          .read(rideControllerProvider.notifier)
          .inviteUser(widget.ride.id, user.id);

      // Simulate Notification
      ref
          .read(notificationServiceProvider.notifier)
          .showNotification(
            title: 'Ride Invitation',
            body: 'You have been invited to join "${widget.ride.title}"',
            rideId: widget.ride.id,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to ${user.fullName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to invite user: ${ErrorHandler.getErrorMessage(e)}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _invitingUserIds.remove(user.id);
        });
      }
    }
  }

  Future<void> _shareRide() async {
    final String shareText =
        'Check out this ride on RiderMatch: ${widget.ride.title}!\n'
        'Details: ${widget.ride.description}\n'
        'Distance: ${widget.ride.validDistanceKm} km\n'
        'Join me here: ridermatch://ride/${widget.ride.id}';

    debugPrint('📤 Sharing ride: $shareText');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opening share menu...'),
          duration: Duration(milliseconds: 800),
        ),
      );
    }

    try {
      final box =
          _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      await Share.share(
        shareText,
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
      debugPrint('✅ Share call completed');
    } catch (e) {
      debugPrint('❌ Share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: ${ErrorHandler.getErrorMessage(e)}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for updates to this specific ride to get latest invitedUserIds
    // Watch for updates to this specific ride to get latest invitedUserIds
    final asyncRide = ref.watch(rideDetailProvider(widget.ride.id));
    final currentRide = asyncRide.value ?? widget.ride;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Invite People',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or vehicle...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: _onSearch,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Search for riders to invite'
                              : 'No riders found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _searchResults.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      final isInviting = _invitingUserIds[user.id] ?? false;
                      final isInvited = currentRide.invitedUserIds.contains(
                        user.id,
                      );

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(user.fullName ?? 'Unknown User'),
                        subtitle: Text(user.vehicleModel ?? 'Rider'),
                        trailing: SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            onPressed: (isInvited || isInviting)
                                ? null
                                : () => _inviteUser(user),
                            style: ElevatedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              backgroundColor: isInvited
                                  ? Colors.grey[200]
                                  : null,
                              foregroundColor: isInvited
                                  ? Colors.grey[600]
                                  : null,
                            ),
                            child: isInviting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryAqua,
                                      ),
                                    ),
                                  )
                                : Text(isInvited ? 'Invited' : 'Invite'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: _shareButtonKey,
              onPressed: _shareRide,
              icon: const Icon(Icons.share),
              label: const Text('Share Ride Link'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[800],
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
