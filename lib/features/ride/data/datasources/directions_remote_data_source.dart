import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteInfo {
  final List<LatLng> polylinePoints;
  final String encodedPolyline;
  final double distanceKm;
  final String duration;
  final LatLngBounds bounds;

  RouteInfo({
    required this.polylinePoints,
    required this.encodedPolyline,
    required this.distanceKm,
    required this.duration,
    required this.bounds,
  });
}

abstract class DirectionsRemoteDataSource {
  Future<RouteInfo?> getDirections(LatLng origin, LatLng destination);
}

class DirectionsRemoteDataSourceImpl implements DirectionsRemoteDataSource {
  final http.Client client;

  DirectionsRemoteDataSourceImpl({http.Client? client})
    : client = client ?? http.Client();

  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  @override
  Future<RouteInfo?> getDirections(LatLng origin, LatLng destination) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'avoid=highways&'
      'key=$_apiKey',
    );

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['routes'] as List).isEmpty) return null;

        final route = data['routes'][0];
        final leg = route['legs'][0];
        final overviewPolyline = route['overview_polyline']['points'];

        // Decoding polyline is complex, for now we might use a package or simple decoder.
        // Or just store the encoded string if the Map widget supports it.
        // But GoogleMap expects List<LatLng>.
        // We will implement a simple polyline decoder.

        final points = _decodePolyline(overviewPolyline);
        final distanceMeters = leg['distance']['value']; // meters
        final boundsData = route['bounds'];

        return RouteInfo(
          polylinePoints: points,
          encodedPolyline: overviewPolyline,
          distanceKm: distanceMeters / 1000.0,
          duration: leg['duration']['text'],
          bounds: LatLngBounds(
            southwest: LatLng(
              boundsData['southwest']['lat'],
              boundsData['southwest']['lng'],
            ),
            northeast: LatLng(
              boundsData['northeast']['lat'],
              boundsData['northeast']['lng'],
            ),
          ),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return poly;
  }
}
