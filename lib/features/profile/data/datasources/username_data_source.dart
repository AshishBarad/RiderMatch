import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

abstract class UsernameDataSource {
  Future<bool> checkUsernameAvailability(String username);
  Future<void> reserveUsername(String userId, String username);
  Future<void> releaseUsername(String username);
}

class UsernameDataSourceImpl implements UsernameDataSource {
  final FirebaseFirestore _firestore;

  UsernameDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final normalizedUsername = username.toLowerCase().trim();

      if (kDebugMode) {
        debugPrint('🔍 Checking username availability: $normalizedUsername');
      }

      final doc = await _firestore
          .collection('usernames')
          .doc(normalizedUsername)
          .get();

      final isAvailable = !doc.exists;

      if (kDebugMode) {
        debugPrint(
          '✅ Username $normalizedUsername is ${isAvailable ? "available" : "taken"}',
        );
      }

      return isAvailable;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking username: $e');
      }
      throw Exception('Failed to check username availability: $e');
    }
  }

  @override
  Future<void> reserveUsername(String userId, String username) async {
    try {
      final normalizedUsername = username.toLowerCase().trim();

      if (kDebugMode) {
        debugPrint(
          '🔒 Reserving username: $normalizedUsername for user: $userId',
        );
      }

      // Use a transaction to prevent race conditions
      await _firestore.runTransaction((transaction) async {
        final usernameDoc = _firestore
            .collection('usernames')
            .doc(normalizedUsername);

        final snapshot = await transaction.get(usernameDoc);

        if (snapshot.exists) {
          final existingUserId = snapshot.data()?['userId'];
          // Allow if it's the same user updating their profile
          if (existingUserId != userId) {
            throw Exception('Username already taken');
          }
        }

        transaction.set(usernameDoc, {
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      if (kDebugMode) {
        debugPrint('✅ Username reserved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error reserving username: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> releaseUsername(String username) async {
    try {
      final normalizedUsername = username.toLowerCase().trim();

      if (kDebugMode) {
        debugPrint('🔓 Releasing username: $normalizedUsername');
      }

      await _firestore.collection('usernames').doc(normalizedUsername).delete();

      if (kDebugMode) {
        debugPrint('✅ Username released successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error releasing username: $e');
      }
      throw Exception('Failed to release username: $e');
    }
  }
}
