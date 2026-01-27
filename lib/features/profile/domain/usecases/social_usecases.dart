import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;
  GetUserProfileUseCase(this.repository);
  Future<User?> call(String userId) => repository.getUserProfile(userId);
}

class FollowUserUseCase {
  final ProfileRepository repository;
  FollowUserUseCase(this.repository);
  Future<void> call(String currentUserId, String targetUserId) =>
      repository.followUser(currentUserId, targetUserId);
}

class UnfollowUserUseCase {
  final ProfileRepository repository;
  UnfollowUserUseCase(this.repository);
  Future<void> call(String currentUserId, String targetUserId) =>
      repository.unfollowUser(currentUserId, targetUserId);
}

class SearchUsersUseCase {
  final ProfileRepository repository;
  SearchUsersUseCase(this.repository);
  Future<List<User>> call(String query) => repository.searchUsers(query);
}

class BlockUserUseCase {
  final ProfileRepository repository;
  BlockUserUseCase(this.repository);
  Future<void> call(String currentUserId, String targetUserId) =>
      repository.blockUser(currentUserId, targetUserId);
}

class UnblockUserUseCase {
  final ProfileRepository repository;
  UnblockUserUseCase(this.repository);
  Future<void> call(String currentUserId, String targetUserId) =>
      repository.unblockUser(currentUserId, targetUserId);
}

class ReportUserUseCase {
  final ProfileRepository repository;
  ReportUserUseCase(this.repository);
  Future<void> call(String currentUserId, String targetUserId, String reason) =>
      repository.reportUser(currentUserId, targetUserId, reason);
}
