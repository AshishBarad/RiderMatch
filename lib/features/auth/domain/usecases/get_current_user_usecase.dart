import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  Future<User?> call() => repository.getCurrentUser();
}
