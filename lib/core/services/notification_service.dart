import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/ride/presentation/ride_providers.dart';
import '../../features/auth/presentation/auth_providers.dart';
import 'package:uuid/uuid.dart';

class NotificationService extends StateNotifier<NotificationCenterState> {
  final Ref ref;
  StreamSubscription? _subscription;

  NotificationService(this.ref)
    : super(NotificationCenterState(notifications: [])) {
    _init();
  }

  void _init() {
    final userId = ref.read(authControllerProvider).value?.id;
    if (userId != null) {
      _subscribeToNotifications(userId);
    }

    // Listen to auth changes to resubscribe if user changes
    ref.listen(authControllerProvider, (previous, next) {
      final newUserId = next.value?.id;
      if (newUserId != null && newUserId != previous?.value?.id) {
        _subscribeToNotifications(newUserId);
      } else if (newUserId == null) {
        _subscription?.cancel();
        state = NotificationCenterState(notifications: []);
      }
    });
  }

  final _uuid = const Uuid();

  void showNotification({
    required String title,
    required String body,
    required String rideId,
  }) {
    // For local simulation or backward compatibility
    // In new architecture, we prefer creating via Firestore
    final newNotification = AppNotification(
      id: _uuid.v4(),
      title: title,
      body: body,
      rideId: rideId,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      notifications: [newNotification, ...state.notifications],
      latestNotification: newNotification,
    );
  }

  void _subscribeToNotifications(String userId) {
    _subscription?.cancel();
    final dataSource = ref.read(notificationRemoteDataSourceProvider);
    _subscription = dataSource.getUserNotifications(userId).listen((
      notifications,
    ) {
      // Check for new notification to set latest
      AppNotification? newLatest;
      if (notifications.isNotEmpty &&
          (state.notifications.isEmpty ||
              notifications.first.id != state.notifications.firstOrNull?.id)) {
        newLatest = notifications.first;
      }

      state = state.copyWith(
        notifications: notifications,
        latestNotification: newLatest,
      );
    });
  }

  Future<void> markAsRead(String id) async {
    final userId = ref.read(authControllerProvider).value?.id;
    if (userId != null) {
      // Optimistic update
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          if (n.id == id) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList(),
      );

      try {
        await ref
            .read(notificationRemoteDataSourceProvider)
            .markAsRead(userId, id);
      } catch (e) {
        // Revert if failed? For read status it's probably fine to ignore or retry silently
      }
    }
  }

  Future<void> markAllAsRead() async {
    final userId = ref.read(authControllerProvider).value?.id;
    if (userId != null) {
      // Optimistic
      state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList(),
      );

      // In a real app we'd have a batch markAsRead API or iterate
      for (var n in state.notifications.where((n) => !n.isRead)) {
        ref.read(notificationRemoteDataSourceProvider).markAsRead(userId, n.id);
      }
    }
  }

  void clearLatest() {
    state = state.copyWith(latestNotification: null);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String rideId;
  final String? type; // e.g., 'join_request', 'info'
  final String? senderId; // The user who triggered the notification
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.rideId,
    this.type,
    this.senderId,
    required this.timestamp,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? rideId,
    String? type,
    String? senderId,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      rideId: rideId ?? this.rideId,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationCenterState {
  final List<AppNotification> notifications;
  final AppNotification? latestNotification;

  NotificationCenterState({
    required this.notifications,
    this.latestNotification,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationCenterState copyWith({
    List<AppNotification>? notifications,
    AppNotification? latestNotification,
  }) {
    return NotificationCenterState(
      notifications: notifications ?? this.notifications,
      // If passing null explicitly, we want to clear it.
      // But if omitted, keep existing? Logic above passes null to clear.
      // Simplify: if latestNotification passed, use it. If not passed, keep current?
      // Actually standard copyWith uses `?? this.field`.
      // To allow clearing, we usually use a sentinel or nullable wrapper.
      // For now, let's assume if it's passed it's the new value (even if null).
      // Wait, standard copyWith pattern prevents setting to null if argument is optional.
      // Let's rely on logic:
      latestNotification: latestNotification,
    );
  }
}

final notificationServiceProvider =
    StateNotifierProvider<NotificationService, NotificationCenterState>((ref) {
      return NotificationService(ref);
    });
