import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/domain/entities/user.dart';
import '../../auth/presentation/auth_providers.dart';
import 'profile_providers.dart';
import '../../../core/utils/error_handler.dart';

class FollowersListScreen extends ConsumerStatefulWidget {
  final List<String> userIds;
  final String title;
  final bool isFollowersList; // True if showing followers, false if following
  final String profileUserId; // The ID of the user whose profile we are viewing

  const FollowersListScreen({
    super.key,
    required this.userIds,
    required this.title,
    required this.isFollowersList,
    required this.profileUserId,
  });

  @override
  ConsumerState<FollowersListScreen> createState() =>
      _FollowersListScreenState();
}

class _FollowersListScreenState extends ConsumerState<FollowersListScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    if (widget.userIds.isEmpty) {
      _usersFuture = Future.value([]);
    } else {
      _usersFuture = ref.read(getUsersByIdsUseCaseProvider)(widget.userIds);
    }
  }

  Future<void> _removeFollower(String followerId) async {
    final currentUserState = ref.read(authControllerProvider);
    final currentUserId = currentUserState.value?.id;

    if (currentUserId == null) return;

    try {
      // Remove follower is equivalent to the follower unfollowing me
      // So we call unfollowUser(followerId, currentUserId)
      await ref.read(unfollowUserUseCaseProvider)(followerId, currentUserId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Follower removed')));
        setState(() {
          widget.userIds.remove(followerId);
          _loadUsers();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error removing follower: ${ErrorHandler.getErrorMessage(e)}',
            ),
          ),
        );
      }
    }
  }

  Future<void> _blockUser(String userId) async {
    final currentUserState = ref.read(authControllerProvider);
    final currentUserId = currentUserState.value?.id;

    if (currentUserId == null) return;

    try {
      await ref.read(blockUserUseCaseProvider)(currentUserId, userId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User blocked')));
        setState(() {
          widget.userIds.remove(userId);
          _loadUsers();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error blocking user: ${ErrorHandler.getErrorMessage(e)}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserState = ref.watch(authControllerProvider);
    final currentUserId = currentUserState.value?.id;
    final isMyProfile = currentUserId == widget.profileUserId;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading users: ${ErrorHandler.getErrorMessage(snapshot.error!)}',
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
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
                subtitle: Text('@${user.username ?? user.id}'),
                trailing: (isMyProfile && widget.isFollowersList)
                    ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'remove') {
                            _removeFollower(user.id);
                          } else if (value == 'block') {
                            _blockUser(user.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'remove',
                            child: Text('Remove Follower'),
                          ),
                          const PopupMenuItem(
                            value: 'block',
                            child: Text(
                              'Block User',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      )
                    : null,
                onTap: () {
                  context.push('/user-profile', extra: user);
                },
              );
            },
          );
        },
      ),
    );
  }
}
