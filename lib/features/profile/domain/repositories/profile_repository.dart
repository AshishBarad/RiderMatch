import '../../../auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Future<User?> getUserProfile(String userId);
  Stream<User?> watchUserProfile(String userId);
  Future<void> updateProfile(User user);
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
  Future<bool> checkUsernameAvailability(String username);
  Future<void> reserveUsername(String userId, String username);
  Future<List<User>> getUsersByIds(List<String> userIds);
}
