import '../repositories/ride_repository.dart';
import '../entities/ride.dart';

class UpdateRideUseCase {
  final RideRepository repository;

  UpdateRideUseCase(this.repository);

  Future<void> call(Ride ride) async {
    return repository.updateRide(ride);
  }
}
