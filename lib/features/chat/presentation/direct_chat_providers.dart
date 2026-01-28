import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/direct_chat_remote_data_source.dart';
import '../data/repositories/direct_chat_repository_impl.dart';
import '../domain/repositories/direct_chat_repository.dart';
import '../domain/usecases/direct_chat_usecases.dart';

// Data Source
final directChatDataSourceProvider = Provider<DirectChatRemoteDataSource>((
  ref,
) {
  return DirectChatRemoteDataSourceImpl();
});

// Repository
final directChatRepositoryProvider = Provider<DirectChatRepository>((ref) {
  return DirectChatRepositoryImpl(ref.watch(directChatDataSourceProvider));
});

// Use Cases
final getMyChatsUseCaseProvider = Provider<GetMyChatsUseCase>((ref) {
  return GetMyChatsUseCase(ref.watch(directChatRepositoryProvider));
});

final getChatRequestsUseCaseProvider = Provider<GetChatRequestsUseCase>((ref) {
  return GetChatRequestsUseCase(ref.watch(directChatRepositoryProvider));
});

final sendChatRequestUseCaseProvider = Provider<SendChatRequestUseCase>((ref) {
  return SendChatRequestUseCase(ref.watch(directChatRepositoryProvider));
});

final approveChatRequestUseCaseProvider = Provider<ApproveChatRequestUseCase>((
  ref,
) {
  return ApproveChatRequestUseCase(ref.watch(directChatRepositoryProvider));
});

final rejectChatRequestUseCaseProvider = Provider<RejectChatRequestUseCase>((
  ref,
) {
  return RejectChatRequestUseCase(ref.watch(directChatRepositoryProvider));
});

final getOrCreateChatUseCaseProvider = Provider<GetOrCreateChatUseCase>((ref) {
  return GetOrCreateChatUseCase(ref.watch(directChatRepositoryProvider));
});

final getChatByIdUseCaseProvider = Provider<GetChatByIdUseCase>((ref) {
  return GetChatByIdUseCase(ref.watch(directChatRepositoryProvider));
});

final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>((ref) {
  return GetMessagesUseCase(ref.watch(directChatRepositoryProvider));
});

final sendDirectMessageUseCaseProvider = Provider<SendDirectMessageUseCase>((
  ref,
) {
  return SendDirectMessageUseCase(ref.watch(directChatRepositoryProvider));
});

final markMessagesAsReadUseCaseProvider = Provider<MarkMessagesAsReadUseCase>((
  ref,
) {
  return MarkMessagesAsReadUseCase(ref.watch(directChatRepositoryProvider));
});

final getExistingRequestUseCaseProvider = Provider<GetExistingRequestUseCase>((
  ref,
) {
  return GetExistingRequestUseCase(ref.watch(directChatRepositoryProvider));
});

// Data Providers
final myChatsProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  userId,
) {
  return ref.watch(getMyChatsUseCaseProvider)(userId);
});

final chatRequestsProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  userId,
) {
  return ref.watch(getChatRequestsUseCaseProvider)(userId);
});
