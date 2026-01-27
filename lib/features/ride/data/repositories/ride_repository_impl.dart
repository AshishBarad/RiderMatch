import '../../domain/entities/ride.dart';
import '../../domain/repositories/ride_repository.dart';
import '../datasources/ride_remote_data_source.dart';

class RideRepositoryImpl implements RideRepository {
  final RideRemoteDataSource remoteDataSource;

  RideRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Ride>> getNearbyRides(
    double lat,
    double lng,
    double radiusKm,
    bool femaleOnly,
  ) async {
    return remoteDataSource.getNearbyRides(lat, lng, radiusKm, femaleOnly);
  }

  @override
  Future<Ride?> getRideById(String id) async {
    return remoteDataSource.getRideById(id);
  }

  @override
  Future<void> createRide(Ride ride) async {
    return remoteDataSource.createRide(ride);
  }

  @override
  Future<void> updateRide(Ride ride) async {
    return remoteDataSource.updateRide(ride);
  }

  @override
  Future<void> requestToJoin(String rideId, String userId) async {
    return remoteDataSource.requestToJoin(rideId, userId);
  }

  @override
  Future<void> acceptJoinRequest(String rideId, String userId) async {
    return remoteDataSource.acceptJoinRequest(rideId, userId);
  }

  @override
  Future<void> rejectJoinRequest(String rideId, String userId) async {
    return remoteDataSource.rejectJoinRequest(rideId, userId);
  }

  @override
  Future<void> removeParticipant(String rideId, String userId) async {
    return remoteDataSource.removeParticipant(rideId, userId);
  }

  @override
  Future<void> inviteUser(String rideId, String userId) async {
    return remoteDataSource.inviteUser(rideId, userId);
  }

  @override
  Future<void> deleteRide(String rideId) async {
    return remoteDataSource.deleteRide(rideId);
  }

  @override
  Future<List<Ride>> getCreatedRides(String userId) async {
    return remoteDataSource.getCreatedRides(userId);
  }

  @override
  Future<List<Ride>> getJoinedRides(String userId) async {
    return remoteDataSource.getJoinedRides(userId);
  }
}
