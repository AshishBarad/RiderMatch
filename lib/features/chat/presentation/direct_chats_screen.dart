import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'direct_chat_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../../../core/utils/error_handler.dart';
import '../../ride/presentation/ride_providers.dart';
import '../../ride/domain/entities/ride.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_typography.dart';
import '../../auth/presentation/auth_providers.dart';

class DirectChatsScreen extends ConsumerStatefulWidget {
  const DirectChatsScreen({super.key});

  @override
  ConsumerState<DirectChatsScreen> createState() => _DirectChatsScreenState();
}

class _DirectChatsScreenState extends ConsumerState<DirectChatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // No hardcoded ID here anymore

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Chats'),
            Tab(
              child: ref
                  .watch(
                    chatRequestsProvider(
                      ref.watch(authControllerProvider).value?.id ?? '',
                    ),
                  )
                  .when(
                    data: (requests) {
                      final count = requests.length;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Requests'),
                          if (count > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const Text('Requests'),
                    error: (_, __) => const Text('Requests'),
                  ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildChatsTab(), _buildRequestsTab()],
      ),
    );
  }

  Widget _buildChatsTab() {
    final userId = ref.watch(authControllerProvider).value?.id ?? '';
    final personalChatsAsync = ref.watch(myChatsProvider(userId));
    final createdRidesAsync = ref.watch(createdRidesProvider);
    final joinedRidesAsync = ref.watch(joinedRidesProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Personal Chats Section
        _buildSectionHeader(
          title: 'PERSONAL CHATS',
          icon: Icons.person_outline,
          initiallyExpanded: true,
          child: personalChatsAsync.when(
            data: (chats) => _buildPersonalChatsList(chats),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) =>
                Center(child: Text(ErrorHandler.getErrorMessage(e))),
          ),
        ),

        const SizedBox(height: 8),

        // Ride Chats Section
        _buildSectionHeader(
          title: 'RIDE CHATS',
          icon: Icons.motorcycle_outlined,
          initiallyExpanded: true,
          child: _buildRideChatsList(createdRidesAsync, joinedRidesAsync),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Widget child,
    bool initiallyExpanded = true,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: AppColors.primaryAqua, size: 20),
        title: Text(
          title,
          style: AppTypography.title.copyWith(
            fontSize: 13,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
          ),
        ),
        children: [child],
      ),
    );
  }

  Widget _buildPersonalChatsList(List<dynamic> chats) {
    if (chats.isEmpty) {
      return _buildEmptySection('No personal chats yet');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chats.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final chat = chats[index];
        final userId = ref.read(authControllerProvider).value?.id ?? '';
        final otherUserId = chat.getOtherParticipantId(userId);
        final unreadCount = chat.getUnreadCountForUser(userId);

        return FutureBuilder(
          future: ref.read(getUserProfileUseCaseProvider)(otherUserId),
          builder: (context, userSnapshot) {
            final user = userSnapshot.data;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryAqua.withValues(alpha: 0.1),
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? const Icon(Icons.person, color: AppColors.primaryAqua)
                    : null,
              ),
              title: Text(
                user?.fullName ?? 'User',
                style: AppTypography.title.copyWith(
                  fontSize: 16,
                  fontWeight: unreadCount > 0
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
              subtitle: Text(
                chat.lastMessage ?? 'No messages yet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body.copyWith(
                  fontSize: 14,
                  color: unreadCount > 0
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (chat.lastMessageTime != null)
                    Text(
                      _formatDate(chat.lastMessageTime!),
                      style: AppTypography.caption,
                    ),
                  if (unreadCount > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAqua,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () => context.push('/direct-chat/${chat.id}'),
            );
          },
        );
      },
    );
  }

  Widget _buildRideChatsList(
    AsyncValue<List<Ride>> createdRides,
    AsyncValue<List<Ride>> joinedRides,
  ) {
    return createdRides.when(
      data: (created) {
        return joinedRides.when(
          data: (joined) {
            // Combine and deduplicate
            final allRidesMap = <String, Ride>{};
            for (final r in created) {
              allRidesMap[r.id] = r;
            }
            for (final r in joined) {
              allRidesMap[r.id] = r;
            }
            final allRides = allRidesMap.values.toList()
              ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

            if (allRides.isEmpty) {
              return _buildEmptySection('No ride chats yet');
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allRides.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final ride = allRides[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAqua.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.group_outlined,
                      color: AppColors.primaryAqua,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    ride.title,
                    style: AppTypography.title.copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    '${ride.toLocation} • Group Chat',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body.copyWith(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                  onTap: () => context.push('/ride-chat/${ride.id}'),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildEmptySection(String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          message,
          style: AppTypography.body.copyWith(color: AppColors.textTertiary),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(date);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  Widget _buildRequestsTab() {
    final userId = ref.watch(authControllerProvider).value?.id ?? '';
    final requestsAsync = ref.watch(chatRequestsProvider(userId));

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No pending requests',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: requests.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final request = requests[index];

            return FutureBuilder(
              future: ref.read(getUserProfileUseCaseProvider)(
                request.fromUserId,
              ),
              builder: (context, userSnapshot) {
                final user = userSnapshot.data;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(user?.fullName ?? 'User'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (request.message != null) ...[
                        Text(
                          request.message!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        DateFormat('MMM d, h:mm a').format(request.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          try {
                            await ref.read(approveChatRequestUseCaseProvider)(
                              request.id,
                            );
                            ref.invalidate(chatRequestsProvider(userId));
                            ref.invalidate(myChatsProvider(userId));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Request approved'),
                                ),
                              );
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
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          try {
                            await ref.read(rejectChatRequestUseCaseProvider)(
                              request.id,
                            );
                            ref.invalidate(chatRequestsProvider(userId));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Request rejected'),
                                ),
                              );
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
                      ),
                    ],
                  ),
                  isThreeLine: request.message != null,
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(ErrorHandler.getErrorMessage(e))),
    );
  }
}
