import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../datasources/username_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final UsernameDataSource usernameDataSource;

  ProfileRepositoryImpl(this.remoteDataSource, this.usernameDataSource);

  @override
  Future<User?> getUserProfile(String userId) async {
    return remoteDataSource.getUserProfile(userId);
  }

  @override
  Future<void> updateProfile(User user) async {
    return remoteDataSource.updateUserProfile(user);
  }

  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    return remoteDataSource.followUser(currentUserId, targetUserId);
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    return remoteDataSource.unfollowUser(currentUserId, targetUserId);
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    return remoteDataSource.searchUsers(query);
  }

  @override
  Future<void> blockUser(String currentUserId, String targetUserId) async {
    return remoteDataSource.blockUser(currentUserId, targetUserId);
  }

  @override
  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    return remoteDataSource.unblockUser(currentUserId, targetUserId);
  }

  @override
  Future<void> reportUser(
    String currentUserId,
    String targetUserId,
    String reason,
  ) async {
    return remoteDataSource.reportUser(currentUserId, targetUserId, reason);
  }

  @override
  Future<bool> checkUsernameAvailability(String username) async {
    return usernameDataSource.checkUsernameAvailability(username);
  }

  @override
  Future<void> reserveUsername(String userId, String username) async {
    return usernameDataSource.reserveUsername(userId, username);
  }

  @override
  Future<List<User>> getUsersByIds(List<String> userIds) async {
    return remoteDataSource.getUsersByIds(userIds);
  }
}
