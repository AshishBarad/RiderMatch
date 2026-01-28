import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/ride.dart';

class RideMapWidget extends StatefulWidget {
  final Ride ride;
  final bool isInteractive;

  const RideMapWidget({
    super.key,
    required this.ride,
    this.isInteractive = true,
  });

  @override
  State<RideMapWidget> createState() => _RideMapWidgetState();
}

class _RideMapWidgetState extends State<RideMapWidget> {
  late GoogleMapController _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  void didUpdateWidget(RideMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ride != oldWidget.ride) {
      _createMarkers();
    }
  }

  void _createMarkers() {
    // If coordinates are 0,0, don't show markers (mock data fallback)
    if (widget.ride.fromLat == 0.0 && widget.ride.fromLng == 0.0) return;

    final start = LatLng(widget.ride.fromLat, widget.ride.fromLng);
    final end = LatLng(widget.ride.toLat, widget.ride.toLng);

    List<LatLng> routePoints = [start, end];
    if (widget.ride.encodedPolyline.isNotEmpty) {
      routePoints = _decodePolyline(widget.ride.encodedPolyline);
    }

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('start'),
          position: start,
          infoWindow: InfoWindow(title: 'Start: ${widget.ride.fromLocation}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: const MarkerId('end'),
          position: end,
          infoWindow: InfoWindow(title: 'End: ${widget.ride.toLocation}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
        // Add intermediate stop markers
        ...widget.ride.stops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;
          return Marker(
            markerId: MarkerId('stop_$index'),
            position: LatLng(stop.lat, stop.lng),
            infoWindow: InfoWindow(title: 'Stop ${index + 1}: ${stop.address}'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
          );
        }),
      };

      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints,
          color: const Color(0xFF2DD4BF), // primaryAqua
          width: 5,
        ),
      };
    });
  }

  // Simple copy of decodePolyline to avoid extra dependency injection here for now
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

  @override
  Widget build(BuildContext context) {
    if (widget.ride.fromLat == 0.0 && widget.ride.fromLng == 0.0) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(child: Text('Map not available for this ride')),
      );
    }

    final initialPos = CameraPosition(
      target: LatLng(widget.ride.fromLat, widget.ride.fromLng),
      zoom: 10,
    );

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: GoogleMap(
        initialCameraPosition: initialPos,
        markers: _markers,
        polylines: _polylines,
        zoomControlsEnabled: widget.isInteractive,
        scrollGesturesEnabled: widget.isInteractive,
        zoomGesturesEnabled: widget.isInteractive,
        onMapCreated: (controller) {
          _controller = controller;
          // Fit bounds
          if (_markers.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _controller.animateCamera(
                CameraUpdate.newLatLngBounds(
                  _boundsFromLatLngList(
                    _markers.map((m) => m.position).toList(),
                  ),
                  50,
                ),
              );
            });
          }
        },
        gestureRecognizers: widget.isInteractive
            ? {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              }
            : const <Factory<OneSequenceGestureRecognizer>>{},
      ),
    );
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }
}
