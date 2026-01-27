import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/domain/entities/user.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../chat/presentation/direct_chat_providers.dart';
import '../../chat/presentation/widgets/chat_request_dialog.dart';
import '../../ride/domain/entities/ride.dart';
import '../../ride/presentation/ride_providers.dart';

import 'followers_list_screen.dart';
import 'profile_providers.dart';
import '../../../core/utils/error_handler.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  final User? initialUser;

  const UserProfileScreen({super.key, required this.userId, this.initialUser});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  User? _user;
  List<Ride> _createdRides = [];
  bool _isLoading = true;
  bool _hasError = false;

  // Local UI state
  bool _isFollowing = false;
  bool _isBlockedByMe = false;
  int _followerCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final getProfile = ref.read(getUserProfileUseCaseProvider);
      final getCreatedRides = ref.read(getCreatedRidesUseCaseProvider);
      final authState = ref.read(authControllerProvider);
      final currentUserId = authState.value?.id ?? '';

      // Use initialUser if provided, otherwise fetch
      // Always fetch to ensure we have full details for Edit Profile
      User? fetchedUser = await getProfile(widget.userId);
      if (fetchedUser == null && widget.initialUser != null) {
        fetchedUser = widget.initialUser;
      }

      User? fetchedCurrentUser;
      List<Ride> fetchedRides = [];

      if (currentUserId.isNotEmpty) {
        final results = await Future.wait([
          getProfile(currentUserId),
          getCreatedRides(currentUserId),
        ]);
        fetchedCurrentUser = results[0] as User?;
        fetchedRides = results[1] as List<Ride>;
      }

      if (fetchedUser != null) {
        if (mounted) {
          setState(() {
            _user = fetchedUser;
            _createdRides = fetchedRides;

            // Initialize synchronous state
            _followerCount = fetchedUser!.followers.length;
            _followingCount = fetchedUser!.following.length;

            if (fetchedCurrentUser != null) {
              _isFollowing = fetchedCurrentUser!.following.contains(
                widget.userId,
              );
              _isBlockedByMe = fetchedCurrentUser!.blockedUsers.contains(
                widget.userId,
              );
            }

            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access widget properties via widget.userId etc.
    final userId = widget.userId;

    // Use actual current user ID from provider for reactive updates if needed,
    // but primarily relying on _currentUser loaded in initState for this logic
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.value?.id ?? '';
    final isMe = userId == currentUserId;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasError || _user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    // Capture local variables for use in closures
    final user = _user!;
    // local _isFollowing and _isBlockedByMe are used directly

    // Check if I am a ride admin for ANY ride this user is in
    bool isUserInAnyOfMyRides = _createdRides.any(
      (ride) => ride.participantIds.contains(user.id),
    );
    final canSeeSafety = isMe || isUserInAnyOfMyRides;

    // Check if mutual followers for messaging logic
    // We update _isFollowing locally, but for mutual calculation we also need to know
    // if THEY follow US. That comes from _user.following.contains(currentUserId).
    // _user.following might be stale if they just followed us, but usually that's fine.
    // Ideally we'd check the updated user object.
    final isMutualFollower =
        _isFollowing && (user.following.contains(currentUserId));

    return Scaffold(
      appBar: AppBar(
        title: Text(user.fullName ?? 'Rider Profile'),
        actions: [
          if (isMe)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await context.push('/profile-setup', extra: user);
                if (mounted) {
                  _loadData(); // Re-fetch entire data after edit
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName ?? 'Unknown Rider',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              (user.username != null && user.username!.isNotEmpty)
                  ? '@${user.username}'
                  : 'ID: ${user.id}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(
                  'Followers',
                  _followerCount.toString(),
                  onTap: () {
                    // Pass the latest list from _user, but note that locally incremented count
                    // might eventually desync if we don't refetch. For now, pass existing list.
                    // If we successfully followed, we should ideally add ourselves to the list passed.
                    List<String> userIds = List<String>.from(user.followers);
                    if (_isFollowing && !userIds.contains(currentUserId)) {
                      userIds.add(currentUserId);
                    } else if (!_isFollowing &&
                        userIds.contains(currentUserId)) {
                      userIds.remove(currentUserId);
                    }

                    if (userIds.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FollowersListScreen(
                            userIds: userIds,
                            title: 'Followers',
                            isFollowersList: true,
                            profileUserId: user.id,
                          ),
                        ),
                      );
                    }
                  },
                ),
                _buildStat(
                  'Following',
                  _followingCount.toString(),
                  onTap: () {
                    if (user.following.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FollowersListScreen(
                            userIds: List<String>.from(user.following),
                            title: 'Following',
                            isFollowersList: false,
                            profileUserId: user.id,
                          ),
                        ),
                      );
                    }
                  },
                ),
                _buildStat('Rides', '0'), // TODO: Fetch real ride count
              ],
            ),
            const SizedBox(height: 24),
            if (!isMe)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isBlockedByMe
                          ? null // Cannot follow if blocked
                          : () async {
                              final wasFollowing = _isFollowing;
                              // Optimistic Update
                              setState(() {
                                if (wasFollowing) {
                                  _isFollowing = false;
                                  _followerCount--;
                                } else {
                                  _isFollowing = true;
                                  _followerCount++;
                                }
                              });

                              try {
                                final followUser = ref.read(
                                  followUserUseCaseProvider,
                                );
                                final unfollowUser = ref.read(
                                  unfollowUserUseCaseProvider,
                                );

                                if (wasFollowing) {
                                  await unfollowUser(currentUserId, userId);
                                } else {
                                  await followUser(currentUserId, userId);
                                }

                                // Success - UI is already updated.
                                // Optionally show quiet snackbar or nothing.
                              } catch (e) {
                                // Revert on failure
                                if (mounted) {
                                  setState(() {
                                    _isFollowing = wasFollowing;
                                    if (wasFollowing) {
                                      _followerCount++;
                                    } else {
                                      _followerCount--;
                                    }
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Action failed'),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowing
                            ? Colors.grey
                            : (_isBlockedByMe ? Colors.grey.shade300 : null),
                      ),
                      child: Text(
                        _isBlockedByMe
                            ? 'Blocked'
                            : (_isFollowing ? 'Following' : 'Follow'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMessageButton(
                      context,
                      currentUserId,
                      userId,
                      user.fullName ?? 'User',
                      isMutualFollower,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Vehicle Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.two_wheeler),
              title: const Text('Motorcycle'),
              subtitle: Text(
                user.vehicleManufacturer != null && user.vehicleModel != null
                    ? '${user.vehicleManufacturer} ${user.vehicleModel}'
                    : (user.vehicleModel ?? 'Not specified'),
              ),
            ),
            if (user.vehicleRegNo != null && user.vehicleRegNo!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.pin),
                title: const Text('Registration Number'),
                subtitle: Text(user.vehicleRegNo!),
              ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Safety & Health',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bloodtype, color: Colors.red),
              title: const Text('Blood Group'),
              subtitle: Text(user.bloodGroup ?? 'Not specified'),
            ),
            if (canSeeSafety &&
                user.emergencyContactName != null &&
                user.emergencyContactName!.isNotEmpty)
              ListTile(
                leading: const Icon(
                  Icons.contact_emergency,
                  color: Colors.blue,
                ),
                title: const Text('Emergency Contact'),
                subtitle: Text(
                  '${user.emergencyContactName} (${user.emergencyContactRelationship ?? 'Unknown'})\n${user.emergencyContactNumber ?? ''}',
                ),
              ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.terrain),
              title: const Text('Riding Preferences'),
              subtitle: Text(
                user.ridingPreferences.isEmpty
                    ? 'None'
                    : user.ridingPreferences.join(', '),
              ),
            ),
            const SizedBox(height: 32),
            if (isMe) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    await ref.read(authControllerProvider.notifier).logout();
                    // Redirection will be handled by the router listener
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
            if (!isMe) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        _showReportDialog(context, currentUserId, userId),
                    icon: const Icon(Icons.flag, color: Colors.orange),
                    label: const Text(
                      'Flag User',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () => _isBlockedByMe
                        ? _showUnblockConfirmation(
                            context,
                            currentUserId,
                            userId,
                          )
                        : _showBlockConfirmation(
                            context,
                            currentUserId,
                            userId,
                          ),
                    icon: Icon(
                      _isBlockedByMe ? Icons.check_circle : Icons.block,
                      color: _isBlockedByMe ? Colors.green : Colors.red,
                    ),
                    label: Text(
                      _isBlockedByMe ? 'Unblock User' : 'Block User',
                      style: TextStyle(
                        color: _isBlockedByMe ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReportDialog(
    BuildContext context,
    String currentUserId,
    String targetUserId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final reasons = [
          'Inappropriate Content',
          'Spam',
          'Harassment',
          'Other',
        ];
        final selectedReasons = <String>{};
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Report User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: reasons.map((reason) {
                  return CheckboxListTile(
                    title: Text(reason),
                    value: selectedReasons.contains(reason),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedReasons.add(reason);
                        } else {
                          selectedReasons.remove(reason);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Call Report Use Case
                    ref
                        .read(reportUserUseCaseProvider)
                        .call(
                          currentUserId,
                          targetUserId,
                          selectedReasons.join(', '),
                        );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User reported. Admins will review.'),
                      ),
                    );
                    // Implementing auto-block:
                    // Optimistically update block state
                    final prevBlocked = _isBlockedByMe;
                    if (mounted)
                      setState(() {
                        _isBlockedByMe = true;
                      });

                    ref
                        .read(blockUserUseCaseProvider)
                        .call(currentUserId, targetUserId)
                        .catchError((e) {
                          if (mounted)
                            setState(() {
                              _isBlockedByMe = prevBlocked;
                            });
                        });
                  },
                  child: const Text('Report & Block'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBlockConfirmation(
    BuildContext context,
    String currentUserId,
    String targetUserId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User?'),
        content: const Text(
          'Blocked users will not be able to find you or see your profile. This action cannot be easily undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Pop dialog

              // Optimistic update
              final prevBlocked = _isBlockedByMe;
              if (mounted)
                setState(() {
                  _isBlockedByMe = true;
                });

              ref
                  .read(blockUserUseCaseProvider)
                  .call(currentUserId, targetUserId)
                  .then((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User blocked.')),
                      );
                    }
                  })
                  .catchError((e) {
                    if (mounted)
                      setState(() {
                        _isBlockedByMe = prevBlocked;
                      });
                  });
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUnblockConfirmation(
    BuildContext context,
    String currentUserId,
    String targetUserId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User?'),
        content: const Text(
          'They will be able to see your profile and you can follow them again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Pop dialog

              // Optimistic update
              final prevBlocked = _isBlockedByMe;
              if (mounted)
                setState(() {
                  _isBlockedByMe = false;
                });

              ref
                  .read(unblockUserUseCaseProvider)
                  .call(currentUserId, targetUserId)
                  .then((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User unblocked.')),
                      );
                    }
                  })
                  .catchError((e) {
                    if (mounted)
                      setState(() {
                        _isBlockedByMe = prevBlocked;
                      });
                  });
            },
            child: const Text('Unblock', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageButton(
    BuildContext context,
    String currentUserId,
    String otherUserId,
    String otherUserName,
    bool isMutualFollower,
  ) {
    return FutureBuilder(
      future: ref.read(getExistingRequestUseCaseProvider)(
        fromUserId: currentUserId,
        toUserId: otherUserId,
      ),
      builder: (context, snapshot) {
        final hasPendingRequest = snapshot.data != null;

        return ElevatedButton.icon(
          onPressed: hasPendingRequest
              ? null
              : () async {
                  try {
                    if (isMutualFollower) {
                      // Direct chat for mutual followers
                      final chat = await ref.read(
                        getOrCreateChatUseCaseProvider,
                      )(userId1: currentUserId, userId2: otherUserId);
                      if (mounted) {
                        context.push('/direct-chat/${chat.id}');
                      }
                    } else {
                      // Show request dialog for non-followers
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => ChatRequestDialog(
                            toUserName: otherUserName,
                            onSend: (message) async {
                              await ref.read(sendChatRequestUseCaseProvider)(
                                fromUserId: currentUserId,
                                toUserId: otherUserId,
                                message: message,
                              );
                              if (mounted) {
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Chat request sent!'),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error: ${ErrorHandler.getErrorMessage(e)}',
                          ),
                        ),
                      );
                    }
                  }
                },
          icon: const Icon(Icons.message),
          label: Text(hasPendingRequest ? 'Pending' : 'Message'),
          style: ElevatedButton.styleFrom(
            backgroundColor: hasPendingRequest
                ? Colors.grey.shade300
                : Colors.blue,
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
