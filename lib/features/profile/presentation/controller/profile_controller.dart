import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileController(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> updateProfile(User user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateProfile(user));
    if (!state.hasError) {
      // Invalidate the cache for this user so listeners re-fetch
      // We need to import the provider to invalidate it.
      // But circular dependency might occur if we import profile_providers.dart here.
      // Best practice: Pass the invalidation logic or use a different structure.
      // However, for now, we can rely on the fact that profile_providers.dart imports this file,
      // so this file CANNOT import profile_providers.dart.
      // We will skip invalidating here and do it in the UI/Provider callback or make this file part not import providers.

      // actually, Ref is powerful. We can read/refresh.
      // But we can't reference the provider variable unless we import it.
      // To avoid cycle, let's keep ProfileController simple and do invalidation in screen or use a "ProfileService" structure.
      // OR: Move ProfileController into profile_providers.dart (single file).
    }
  }
}
