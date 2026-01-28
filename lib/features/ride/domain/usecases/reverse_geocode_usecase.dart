import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repositories/directions_repository.dart';

class ReverseGeocodeUseCase {
  final DirectionsRepository repository;

  ReverseGeocodeUseCase(this.repository);

  Future<String?> call(LatLng location) {
    return repository.reverseGeocode(location);
  }
}
