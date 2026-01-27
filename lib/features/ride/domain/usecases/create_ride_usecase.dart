import '../entities/ride.dart';
import '../repositories/ride_repository.dart';

class CreateRideUseCase {
  final RideRepository repository;

  CreateRideUseCase(this.repository);

  Future<void> call(Ride ride) {
    return repository.createRide(ride);
  }
}
