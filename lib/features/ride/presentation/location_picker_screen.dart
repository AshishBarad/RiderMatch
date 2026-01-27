import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

class LocationPickerResult {
  final LatLng latLng;
  final String address;

  LocationPickerResult(this.latLng, this.address);
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Default to a central location (e.g., San Francisco) if no location
  final LatLng _center = const LatLng(37.7749, -122.4194);
  LatLng? _pickedLocation;

  void _onCameraMove(CameraPosition position) {
    _pickedLocation = position.target;
  }

  void _onConfirm() {
    // In a real app, we would use Geocoding API to get address from LatLng
    final result = LocationPickerResult(
      _pickedLocation ?? _center,
      'Dropped Pin (${(_pickedLocation ?? _center).latitude.toStringAsFixed(4)}, ${(_pickedLocation ?? _center).longitude.toStringAsFixed(4)})',
    );
    context.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(onPressed: _onConfirm, icon: const Icon(Icons.check)),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 13),
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          const Icon(Icons.location_pin, size: 40, color: Colors.blue),
          Positioned(
            bottom: 30,
            child: ElevatedButton(
              onPressed: _onConfirm,
              child: const Text('Confirm Location'),
            ),
          ),
        ],
      ),
    );
  }
}
