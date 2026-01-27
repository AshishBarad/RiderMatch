import '../entities/ride.dart';
import '../repositories/ride_repository.dart';

class GetCreatedRidesUseCase {
  final RideRepository repository;

  GetCreatedRidesUseCase(this.repository);

  Future<List<Ride>> call(String userId) async {
    return repository.getCreatedRides(userId);
  }
}

class GetJoinedRidesUseCase {
  final RideRepository repository;

  GetJoinedRidesUseCase(this.repository);

  Future<List<Ride>> call(String userId) async {
    return repository.getJoinedRides(userId);
  }
}
