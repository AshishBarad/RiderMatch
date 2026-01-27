import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/datasources/directions_remote_data_source.dart';

abstract class DirectionsRepository {
  Future<RouteInfo?> getDirections(LatLng origin, LatLng destination);
}

class DirectionsRepositoryImpl implements DirectionsRepository {
  final DirectionsRemoteDataSource dataSource;

  DirectionsRepositoryImpl(this.dataSource);

  @override
  Future<RouteInfo?> getDirections(LatLng origin, LatLng destination) {
    return dataSource.getDirections(origin, destination);
  }
}
