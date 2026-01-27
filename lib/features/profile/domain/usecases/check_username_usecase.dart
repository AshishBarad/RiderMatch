import '../repositories/profile_repository.dart';

class CheckUsernameUseCase {
  final ProfileRepository repository;

  CheckUsernameUseCase(this.repository);

  Future<bool> call(String username) async {
    // Validate format first
    if (!_isValidUsername(username)) {
      throw Exception('Invalid username format');
    }

    return repository.checkUsernameAvailability(username);
  }

  bool _isValidUsername(String username) {
    // 1-15 characters
    if (username.isEmpty || username.length > 15) {
      return false;
    }

    // Only lowercase letters, numbers, and underscore
    final regex = RegExp(r'^[a-z0-9_]+$');
    if (!regex.hasMatch(username)) {
      return false;
    }

    // Cannot start with number or underscore
    if (username.startsWith(RegExp(r'[0-9_]'))) {
      return false;
    }

    // Reserved usernames
    const reserved = [
      'admin',
      'administrator',
      'system',
      'support',
      'help',
      'root',
      'moderator',
      'mod',
      'official',
    ];

    if (reserved.contains(username.toLowerCase())) {
      return false;
    }

    return true;
  }
}
