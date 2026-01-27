import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/entities/user.dart' as domain;
import '../data/datasources/profile_remote_data_source.dart';
import '../data/datasources/username_data_source.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/social_usecases.dart';
import '../domain/usecases/check_username_usecase.dart';
import '../domain/usecases/reserve_username_usecase.dart';
import '../domain/usecases/get_users_by_ids_usecase.dart';
import 'controller/profile_controller.dart';

// ... (existing imports)

// Reactive User Profile Provider
final userProfileProvider = FutureProvider.family<domain.User?, String>((
  ref,
  userId,
) {
  final getUserProfile = ref.watch(getUserProfileUseCaseProvider);
  return getUserProfile(userId);
});

// Data Sources
final profileDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl();
});

final usernameDataSourceProvider = Provider<UsernameDataSource>((ref) {
  return UsernameDataSourceImpl();
});

// Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ref.watch(profileDataSourceProvider),
    ref.watch(usernameDataSourceProvider),
  );
});

// Use Cases
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.watch(profileRepositoryProvider));
});

final followUserUseCaseProvider = Provider<FollowUserUseCase>((ref) {
  return FollowUserUseCase(ref.watch(profileRepositoryProvider));
});

final unfollowUserUseCaseProvider = Provider<UnfollowUserUseCase>((ref) {
  return UnfollowUserUseCase(ref.watch(profileRepositoryProvider));
});

final searchUsersUseCaseProvider = Provider<SearchUsersUseCase>((ref) {
  return SearchUsersUseCase(ref.watch(profileRepositoryProvider));
});

final blockUserUseCaseProvider = Provider<BlockUserUseCase>((ref) {
  return BlockUserUseCase(ref.watch(profileRepositoryProvider));
});

final getUsersByIdsUseCaseProvider = Provider<GetUsersByIdsUseCase>((ref) {
  return GetUsersByIdsUseCase(ref.watch(profileRepositoryProvider));
});

final unblockUserUseCaseProvider = Provider<UnblockUserUseCase>((ref) {
  return UnblockUserUseCase(ref.watch(profileRepositoryProvider));
});

final reportUserUseCaseProvider = Provider<ReportUserUseCase>((ref) {
  return ReportUserUseCase(ref.watch(profileRepositoryProvider));
});

final checkUsernameUseCaseProvider = Provider<CheckUsernameUseCase>((ref) {
  return CheckUsernameUseCase(ref.watch(profileRepositoryProvider));
});

final reserveUsernameUseCaseProvider = Provider<ReserveUsernameUseCase>((ref) {
  return ReserveUsernameUseCase(ref.watch(profileRepositoryProvider));
});

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
      return ProfileController(ref.watch(profileRepositoryProvider), ref);
    });
