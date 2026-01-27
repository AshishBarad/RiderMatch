import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PlacePrediction {
  final String description;
  final String placeId;

  PlacePrediction({required this.description, required this.placeId});

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      description: json['description'] as String,
      placeId: json['place_id'] as String,
    );
  }
}

class PlaceDetail {
  final double lat;
  final double lng;
  final String address;

  PlaceDetail({required this.lat, required this.lng, required this.address});
}

abstract class PlacesRemoteDataSource {
  Future<List<PlacePrediction>> getAutocomplete(
    String input,
    String sessionToken,
  );
  Future<PlaceDetail?> getPlaceDetails(String placeId, String sessionToken);
}

class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  final http.Client client;

  PlacesRemoteDataSourceImpl({http.Client? client})
    : client = client ?? http.Client();

  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  @override
  Future<List<PlacePrediction>> getAutocomplete(
    String input,
    String sessionToken,
  ) async {
    if (input.isEmpty) return [];

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey&sessiontoken=$sessionToken',
    );

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return (data['predictions'] as List)
              .map((p) => PlacePrediction.fromJson(p))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<PlaceDetail?> getPlaceDetails(
    String placeId,
    String sessionToken,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry,formatted_address&key=$_apiKey&sessiontoken=$sessionToken',
    );

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];
          return PlaceDetail(
            lat: location['lat'],
            lng: location['lng'],
            address: result['formatted_address'],
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
