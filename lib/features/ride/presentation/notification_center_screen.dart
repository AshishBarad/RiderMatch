import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/services/notification_service.dart';
import '../presentation/ride_providers.dart';
import '../../../../core/utils/error_handler.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationServiceProvider);
    final notifications = notificationState.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications (DEBUG MODE)'),
        backgroundColor: Colors.red[100], // VISUAL CONFIRMATION
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                ref.read(notificationServiceProvider.notifier).markAllAsRead();
              },
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationItem(notification: notification);
              },
            ),
    );
  }
}

// Using a separate widget for cleaner code
class NotificationItem extends ConsumerWidget {
  final AppNotification notification;
  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: notification.isRead
                ? Colors.grey[200]
                : Colors.blue[50],
            child: Icon(
              Icons.notifications_outlined,
              color: notification.isRead ? Colors.grey : Colors.blue,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.body),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d, h:mm a').format(notification.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              // TEMPORARY DEBUG TEXT
              Text(
                'Debug: Type=${notification.type}, Sender=${notification.senderId}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),

              // Unified action block for join_request AND ride_invite
              if ((notification.type == 'join_request' ||
                      notification.type == 'ride_invite') &&
                  notification.senderId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.check,
                        color: Colors.green,
                        label: 'Accept',
                        onPressed: () async {
                          try {
                            if (notification.type == 'join_request') {
                              await ref
                                  .read(rideControllerProvider.notifier)
                                  .acceptJoinRequest(
                                    notification.rideId,
                                    notification.senderId!,
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Request Accepted'),
                                  ),
                                );
                              }
                            } else if (notification.type == 'ride_invite') {
                              await ref
                                  .read(rideControllerProvider.notifier)
                                  .acceptRideInvite(notification.rideId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invitation Accepted!'),
                                  ),
                                );
                              }
                            }
                            // Mark read
                            ref
                                .read(notificationServiceProvider.notifier)
                                .markAsRead(notification.id);
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
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.close,
                        color: Colors.red,
                        label: 'Decline',
                        onPressed: () async {
                          try {
                            if (notification.type == 'join_request') {
                              await ref
                                  .read(rideControllerProvider.notifier)
                                  .rejectJoinRequest(
                                    notification.rideId,
                                    notification.senderId!,
                                  );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Request Declined'),
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invitation Declined'),
                                  ),
                                );
                              }
                            }
                            ref
                                .read(notificationServiceProvider.notifier)
                                .markAsRead(notification.id);
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
                ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () async {
            // Default tap behavior
            ref
                .read(notificationServiceProvider.notifier)
                .markAsRead(notification.id);
            final ride = await ref.read(getRideByIdUseCaseProvider)(
              notification.rideId,
            );
            if (ride != null && context.mounted) {
              context.push('/ride-detail', extra: ride);
            }
          },
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
