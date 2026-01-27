import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// FCM Service for handling push notifications
class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize FCM and request permissions
  Future<void> initialize(String userId) async {
    try {
      // Request notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('User granted notification permission');
        }

        // Get FCM token
        final token = await _messaging.getToken();
        if (token != null) {
          if (kDebugMode) {
            print('FCM Token: $token');
          }

          // Save token to Firestore
          await _saveTokenToFirestore(userId, token);

          // Subscribe to user-specific topic
          await _messaging.subscribeToTopic('user_$userId');
        }

        // Handle token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _saveTokenToFirestore(userId, newToken);
        });

        // Setup message handlers
        _setupMessageHandlers();
      } else {
        if (kDebugMode) {
          print('User declined notification permission');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing FCM: $e');
      }
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
    }
  }

  /// Setup message handlers for foreground, background, and terminated states
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message received: ${message.notification?.title}');
      }

      // Show local notification or update UI
      _handleMessage(message);
    });

    // Handle background messages (app in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message opened app: ${message.notification?.title}');
      }

      // Navigate to appropriate screen based on message data
      _handleMessageNavigation(message);
    });

    // Check if app was opened from a terminated state
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print(
            'App opened from terminated state: ${message.notification?.title}',
          );
        }
        _handleMessageNavigation(message);
      }
    });
  }

  /// Handle incoming message
  void _handleMessage(RemoteMessage message) {
    // Extract notification data
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      // Show local notification using flutter_local_notifications
      // or display in-app notification
      if (kDebugMode) {
        print('Title: ${notification.title}');
        print('Body: ${notification.body}');
        print('Data: $data');
      }
    }
  }

  /// Handle navigation based on message data
  void _handleMessageNavigation(RemoteMessage message) {
    final data = message.data;

    // Navigate based on notification type
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'ride_invite':
          // Navigate to ride detail screen
          final rideId = data['rideId'];
          if (kDebugMode) {
            print('Navigate to ride: $rideId');
          }
          break;
        case 'chat_message':
          // Navigate to chat screen
          final chatId = data['chatId'];
          if (kDebugMode) {
            print('Navigate to chat: $chatId');
          }
          break;
        case 'ride_join_request':
          // Navigate to ride participants screen
          final rideId = data['rideId'];
          if (kDebugMode) {
            print('Navigate to ride participants: $rideId');
          }
          break;
        default:
          if (kDebugMode) {
            print('Unknown notification type: ${data['type']}');
          }
      }
    }
  }

  /// Unsubscribe from user topic (call on logout)
  Future<void> unsubscribeFromUserTopic(String userId) async {
    try {
      await _messaging.unsubscribeFromTopic('user_$userId');
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic: $e');
      }
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message: ${message.notification?.title}');
  }
  // Handle background message
}
