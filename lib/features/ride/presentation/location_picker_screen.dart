import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'ride_providers.dart';
import 'widgets/places_autocomplete_field.dart';

class LocationPickerResult {
  final LatLng latLng;
  final String address;

  LocationPickerResult(this.latLng, this.address);
}

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  // Default to a central location (e.g., San Francisco) if no location
  final LatLng _center = const LatLng(37.7749, -122.4194);
  LatLng? _pickedLocation;
  bool _isGeocoding = false;
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCameraMove(CameraPosition position) {
    _pickedLocation = position.target;
  }

  Future<void> _onConfirm() async {
    setState(() => _isGeocoding = true);
    final selectedLocation = _pickedLocation ?? _center;

    try {
      final address = await ref
          .read(reverseGeocodeUseCaseProvider)
          .call(selectedLocation);

      final result = LocationPickerResult(
        selectedLocation,
        address ??
            'Dropped Pin (${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)})',
      );
      if (mounted) {
        context.pop(result);
      }
    } finally {
      if (mounted) {
        setState(() => _isGeocoding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          if (_isGeocoding)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(onPressed: _onConfirm, icon: const Icon(Icons.check)),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 13),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          const Icon(Icons.location_pin, size: 40, color: Colors.blue),

          // Search Bar Overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PlacesAutocompleteField(
                  label: 'Search location...',
                  prefixIcon: Icons.search,
                  controller: _searchController,
                  onSelected: (address, lat, lng) {
                    final latLng = LatLng(lat, lng);
                    _pickedLocation = latLng;
                    _mapController.animateCamera(
                      CameraUpdate.newLatLngZoom(latLng, 15),
                    );
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            child: ElevatedButton(
              onPressed: _isGeocoding ? null : _onConfirm,
              child: _isGeocoding
                  ? const Text('Geocoding...')
                  : const Text('Confirm Location'),
            ),
          ),
        ],
      ),
    );
  }
}
