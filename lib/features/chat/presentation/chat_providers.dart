import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/chat_message.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../../ride/presentation/ride_providers.dart';
import '../../auth/domain/entities/user.dart';
import '../../profile/presentation/profile_providers.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl();
});

class RideChatNotifier extends FamilyAsyncNotifier<List<ChatMessage>, String> {
  @override
  FutureOr<List<ChatMessage>> build(String arg) async {
    final repository = ref.watch(chatRepositoryProvider);
    final stream = repository.getMessages(arg);

    final completer = Completer<List<ChatMessage>>();

    final subscription = stream.listen((messages) {
      if (!completer.isCompleted) {
        completer.complete(messages);
      } else {
        state = AsyncData(messages);
      }
    });

    ref.onDispose(() => subscription.cancel());

    return completer.future;
  }

  Future<void> sendMessage(
    String text, {
    required String senderId,
    String? repliedToId,
    String? repliedToText,
    String? repliedToSenderName,
  }) async {
    final message = ChatMessage(
      id: '', // Will be set by repository
      rideId: arg,
      senderId: senderId,
      senderName: senderId == 'mock_user_123'
          ? 'Ashish'
          : 'Rider', // Simulation for now
      text: text,
      timestamp: DateTime.now(),
      repliedToId: repliedToId,
      repliedToText: repliedToText,
      repliedToSenderName: repliedToSenderName,
    );

    try {
      await ref.read(chatRepositoryProvider).sendMessage(message);
    } catch (e) {
      rethrow;
    }
  }
}

final rideChatNotifierProvider =
    AsyncNotifierProvider.family<RideChatNotifier, List<ChatMessage>, String>(
      () => RideChatNotifier(),
    );

final currentChatRideIdProvider = StateProvider<String?>((ref) => null);

final rideParticipantsProvider = FutureProvider.family<List<User>, String>((
  ref,
  rideId,
) async {
  final getRideById = ref.watch(getRideByIdUseCaseProvider);
  final getUserProfile = ref.watch(getUserProfileUseCaseProvider);

  final ride = await getRideById(rideId);
  if (ride == null) return [];

  final userFutures = ride.participantIds.map((id) => getUserProfile(id));
  final creatorsProfile = await getUserProfile(ride.creatorId);

  final participants = await Future.wait(userFutures);
  final result = participants.whereType<User>().toList();

  if (creatorsProfile != null &&
      !ride.participantIds.contains(ride.creatorId)) {
    result.insert(0, creatorsProfile);
  }

  return result;
});
