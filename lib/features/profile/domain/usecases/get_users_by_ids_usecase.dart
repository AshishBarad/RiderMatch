import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class GetUsersByIdsUseCase {
  final ProfileRepository repository;

  GetUsersByIdsUseCase(this.repository);

  Future<List<User>> call(List<String> userIds) {
    return repository.getUsersByIds(userIds);
  }
}
