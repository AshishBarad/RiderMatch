import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> call(User user) {
    return repository.updateProfile(user);
  }
}
