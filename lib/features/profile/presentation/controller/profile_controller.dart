import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;

  ProfileController(this._repository, Ref ref)
    : super(const AsyncValue.data(null));

  Future<void> updateProfile(User user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateProfile(user));
  }
}
