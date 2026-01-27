import '../entities/ride.dart';
import '../repositories/ride_repository.dart';

class GetRideByIdUseCase {
  final RideRepository repository;

  GetRideByIdUseCase(this.repository);

  Future<Ride?> call(String id) {
    return repository.getRideById(id);
  }
}
