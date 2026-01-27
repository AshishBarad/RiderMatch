import '../entities/ride.dart';

abstract class RideRepository {
  Future<List<Ride>> getNearbyRides(
    double lat,
    double lng,
    double radiusKm,
    bool femaleOnly,
  );
  Future<Ride?> getRideById(String id);
  Future<void> createRide(Ride ride);
  Future<void> updateRide(Ride ride);
  Future<void> requestToJoin(String rideId, String userId);
  Future<void> acceptJoinRequest(String rideId, String userId);
  Future<void> rejectJoinRequest(String rideId, String userId);
  Future<void> removeParticipant(String rideId, String userId);
  Future<void> inviteUser(String rideId, String userId);
  Future<void> deleteRide(String rideId);
  Future<List<Ride>> getCreatedRides(String userId);
  Future<List<Ride>> getJoinedRides(String userId);
}
