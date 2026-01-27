import '../entities/ride.dart';
import '../repositories/ride_repository.dart';

class GetNearbyRidesUseCase {
  final RideRepository repository;

  GetNearbyRidesUseCase(this.repository);

  Future<List<Ride>> call(
    double lat,
    double lng,
    double radiusKm,
    bool femaleOnly,
  ) {
    return repository.getNearbyRides(lat, lng, radiusKm, femaleOnly);
  }
}
