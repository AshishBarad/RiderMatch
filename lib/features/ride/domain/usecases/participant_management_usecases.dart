import '../repositories/ride_repository.dart';

class RequestToJoinUseCase {
  final RideRepository repository;
  RequestToJoinUseCase(this.repository);
  Future<void> call(String rideId, String userId) =>
      repository.requestToJoin(rideId, userId);
}

class AcceptJoinRequestUseCase {
  final RideRepository repository;
  AcceptJoinRequestUseCase(this.repository);
  Future<void> call(String rideId, String userId) =>
      repository.acceptJoinRequest(rideId, userId);
}

class RejectJoinRequestUseCase {
  final RideRepository repository;
  RejectJoinRequestUseCase(this.repository);
  Future<void> call(String rideId, String userId) =>
      repository.rejectJoinRequest(rideId, userId);
}

class RemoveParticipantUseCase {
  final RideRepository repository;
  RemoveParticipantUseCase(this.repository);
  Future<void> call(String rideId, String userId) =>
      repository.removeParticipant(rideId, userId);
}

class InviteUserUseCase {
  final RideRepository repository;
  InviteUserUseCase(this.repository);
  Future<void> call(String rideId, String userId) =>
      repository.inviteUser(rideId, userId);
}
