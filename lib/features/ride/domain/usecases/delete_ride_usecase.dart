import '../repositories/ride_repository.dart';

class DeleteRideUseCase {
  final RideRepository repository;

  DeleteRideUseCase(this.repository);

  Future<void> call(String rideId) {
    return repository.deleteRide(rideId);
  }
}
