import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repositories/directions_repository.dart';
import '../../data/datasources/directions_remote_data_source.dart';

class GetRideRouteUseCase {
  final DirectionsRepository repository;

  GetRideRouteUseCase(this.repository);

  Future<RouteInfo?> call(
    LatLng origin,
    LatLng destination, {
    List<LatLng>? waypoints,
  }) {
    return repository.getDirections(origin, destination, waypoints: waypoints);
  }
}
