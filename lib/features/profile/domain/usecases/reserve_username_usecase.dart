import '../repositories/profile_repository.dart';

class ReserveUsernameUseCase {
  final ProfileRepository repository;

  ReserveUsernameUseCase(this.repository);

  Future<void> call(String userId, String username) async {
    return repository.reserveUsername(userId, username);
  }
}
