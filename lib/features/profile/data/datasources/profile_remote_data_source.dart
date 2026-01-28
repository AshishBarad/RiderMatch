import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../auth/domain/entities/user.dart';

abstract class ProfileRemoteDataSource {
  Future<User?> getUserProfile(String userId);
  Stream<User?> watchUserProfile(String userId);
  Future<void> updateUserProfile(User user);
  Future<void> followUser(String currentUserId, String targetUserId);
  Future<void> unfollowUser(String currentUserId, String targetUserId);
  Future<List<User>> searchUsers(String query);
  Future<void> blockUser(String currentUserId, String targetUserId);
  Future<void> unblockUser(String currentUserId, String targetUserId);
  Future<void> reportUser(
    String currentUserId,
    String targetUserId,
    String reason,
  );
  Future<List<User>> getUsersByIds(List<String> userIds);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProfileRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<User?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return _userFromFirestore(userId, data);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Stream<User?> watchUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map(
          (doc) => doc.exists ? _userFromFirestore(userId, doc.data()!) : null,
        );
  }

  @override
  Future<void> updateUserProfile(User user) async {
    try {
      debugPrint(
        '🔥 FIRESTORE UPDATE: DocID=${user.id}, Name=${user.fullName}',
      );
      // Use set with SetOptions(merge: true) to allow creating the document
      // if it doesn't exist, preventing "not-found" errors
      await _firestore.collection('users').doc(user.id).set({
        'fullName': user.fullName,
        'username': user.username,
        'email': user.email,
        'age': user.age,
        'gender': user.gender,
        'vehicleManufacturer': user.vehicleManufacturer,
        'vehicleModel': user.vehicleModel,
        'vehicleRegNo': user.vehicleRegNo,
        'bloodGroup': user.bloodGroup,
        'emergencyContactName': user.emergencyContactName,
        'emergencyContactRelationship': user.emergencyContactRelationship,
        'emergencyContactNumber': user.emergencyContactNumber,
        'ridingPreferences': user.ridingPreferences,
        'photoUrl': user.photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      // Use batch write to update both users atomically
      final batch = _firestore.batch();

      // Add targetUserId to current user's following array
      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      batch.update(currentUserRef, {
        'following': FieldValue.arrayUnion([targetUserId]),
      });

      // Add currentUserId to target user's followers array
      final targetUserRef = _firestore.collection('users').doc(targetUserId);
      batch.update(targetUserRef, {
        'followers': FieldValue.arrayUnion([currentUserId]),
      });

      // Commit the batch
      await batch.commit();

      debugPrint('✅ User $currentUserId followed $targetUserId');
    } catch (e) {
      debugPrint('❌ Failed to follow user: $e');
      throw Exception('Failed to follow user: $e');
    }
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      // Use batch write to update both users atomically
      final batch = _firestore.batch();

      // Remove targetUserId from current user's following array
      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      batch.update(currentUserRef, {
        'following': FieldValue.arrayRemove([targetUserId]),
      });

      // Remove currentUserId from target user's followers array
      final targetUserRef = _firestore.collection('users').doc(targetUserId);
      batch.update(targetUserRef, {
        'followers': FieldValue.arrayRemove([currentUserId]),
      });

      // Commit the batch
      await batch.commit();

      debugPrint('✅ User $currentUserId unfollowed $targetUserId');
    } catch (e) {
      debugPrint('❌ Failed to unfollow user: $e');
      throw Exception('Failed to unfollow user: $e');
    }
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      // Note: Firestore doesn't support full-text search natively
      // For now, fetch recent users and filter client-side
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      final users = snapshot.docs
          .map((doc) => _userFromFirestore(doc.id, doc.data()))
          .toList();

      // Client-side filtering
      final lowerQuery = query.toLowerCase();
      return users.where((u) {
        final name = u.fullName?.toLowerCase() ?? '';
        final username = u.username?.toLowerCase() ?? '';
        final vehicle = u.vehicleModel?.toLowerCase() ?? '';
        final phone = u.phoneNumber.toLowerCase();
        // Prioritize exact username match
        return username == lowerQuery ||
            name.contains(lowerQuery) ||
            username.contains(lowerQuery) ||
            vehicle.contains(lowerQuery) ||
            phone.contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  @override
  Future<void> blockUser(String currentUserId, String targetUserId) async {
    try {
      // Add to blocked users array
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayUnion([targetUserId]),
      });

      // Unfollow the user
      await unfollowUser(currentUserId, targetUserId);

      // Remove from followers
      await _firestore
          .collection('follows')
          .doc(currentUserId)
          .collection('followers')
          .doc(targetUserId)
          .delete();
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  @override
  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayRemove([targetUserId]),
      });
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  @override
  Future<void> reportUser(
    String currentUserId,
    String targetUserId,
    String reason,
  ) async {
    try {
      // Create a report document
      await _firestore.collection('reports').add({
        'reportedBy': currentUserId,
        'reportedUser': targetUserId,
        'reason': reason,
        'status': 'PENDING',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to report user: $e');
    }
  }

  User _userFromFirestore(String userId, Map<String, dynamic> data) {
    return User(
      id: userId,
      phoneNumber: data['phoneNumber'] ?? '',
      username: data['username'],
      fullName: data['fullName'],
      email: data['email'],
      age: data['age'],
      gender: data['gender'],
      vehicleManufacturer: data['vehicleManufacturer'],
      vehicleModel: data['vehicleModel'],
      vehicleRegNo: data['vehicleRegNo'],
      bloodGroup: data['bloodGroup'],
      emergencyContactName: data['emergencyContactName'],
      emergencyContactRelationship: data['emergencyContactRelationship'],
      emergencyContactNumber: data['emergencyContactNumber'],
      ridingPreferences: data['ridingPreferences'] != null
          ? List<String>.from(data['ridingPreferences'])
          : [],
      photoUrl: data['photoUrl'],
      blockedUsers: data['blockedUsers'] != null
          ? List<String>.from(data['blockedUsers'])
          : [],
      followers: data['followers'] != null
          ? List<String>.from(data['followers'])
          : [],
      following: data['following'] != null
          ? List<String>.from(data['following'])
          : [],
      isProfileComplete:
          data['fullName'] != null && (data['fullName'] as String).isNotEmpty,
    );
  }

  @override
  Future<List<User>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    // Using Future.wait to fetch users in parallel
    // This avoids the 10-item limit of 'whereIn' queries and works for any list size
    final results = await Future.wait(userIds.map((id) => getUserProfile(id)));

    // Filter out nulls (users that don't exist)
    return results.whereType<User>().toList();
  }
}
