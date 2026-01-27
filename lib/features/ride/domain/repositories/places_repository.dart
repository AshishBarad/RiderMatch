import '../../data/datasources/places_remote_data_source.dart';

abstract class PlacesRepository {
  Future<List<PlacePrediction>> getAutocomplete(
    String input,
    String sessionToken,
  );
  Future<PlaceDetail?> getPlaceDetails(String placeId, String sessionToken);
}

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource dataSource;

  PlacesRepositoryImpl(this.dataSource);

  @override
  Future<List<PlacePrediction>> getAutocomplete(
    String input,
    String sessionToken,
  ) {
    return dataSource.getAutocomplete(input, sessionToken);
  }

  @override
  Future<PlaceDetail?> getPlaceDetails(String placeId, String sessionToken) {
    return dataSource.getPlaceDetails(placeId, sessionToken);
  }
}
