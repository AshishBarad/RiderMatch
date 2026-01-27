import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain/entities/ride.dart';
import 'ride_providers.dart';
import 'location_picker_screen.dart';
import 'widgets/places_autocomplete_field.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../../core/utils/error_handler.dart';

class CreateRideScreen extends ConsumerStatefulWidget {
  final Ride? rideToEdit;
  const CreateRideScreen({super.key, this.rideToEdit});

  @override
  ConsumerState<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends ConsumerState<CreateRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _distanceController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  String _difficulty = 'Easy';

  double _fromLat = 0.0;
  double _fromLng = 0.0;
  double _toLat = 0.0;
  double _toLng = 0.0;
  String _encodedPolyline = '';

  bool _isPrivate = false;

  @override
  void initState() {
    super.initState();
    if (widget.rideToEdit != null) {
      final ride = widget.rideToEdit!;
      _titleController.text = ride.title;
      _descController.text = ride.description;
      _fromController.text = ride.fromLocation;
      _toController.text = ride.toLocation;
      _distanceController.text = ride.validDistanceKm.toString();

      _selectedDate = ride.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(ride.dateTime);
      _difficulty = ride.difficulty;

      _fromLat = ride.fromLat;
      _fromLng = ride.fromLng;
      _toLat = ride.toLat;
      _toLng = ride.toLng;
      _encodedPolyline = ride.encodedPolyline;
      _isPrivate = ride.isPrivate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _calculateRoute() async {
    if (_fromLat == 0.0 || _fromLng == 0.0 || _toLat == 0.0 || _toLng == 0.0) {
      return;
    }

    // Show loading?
    final start = LatLng(_fromLat, _fromLng);
    final end = LatLng(_toLat, _toLng);

    final routeInfo = await ref
        .read(getRideRouteUseCaseProvider)
        .call(start, end);

    if (routeInfo != null && mounted) {
      setState(() {
        _distanceController.text = routeInfo.distanceKm.toStringAsFixed(1);
        _encodedPolyline = routeInfo.encodedPolyline;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Distance updated: ${routeInfo.distanceKm.toStringAsFixed(1)} km',
          ),
        ),
      );
    }
  }

  // ... Date/Time pickers ...
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final currentUser = ref.read(authControllerProvider).value;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: You must be logged in to create a ride'),
          ),
        );
        return;
      }
      final currentUserId = currentUser.id;

      final newRide = Ride(
        id:
            widget.rideToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        creatorId: widget.rideToEdit?.creatorId ?? currentUserId,
        title: _titleController.text,
        description: _descController.text,
        fromLocation: _fromController.text,
        fromLat: _fromLat,
        fromLng: _fromLng,
        toLocation: _toController.text,
        toLat: _toLat,
        toLng: _toLng,
        encodedPolyline: _encodedPolyline,
        dateTime: dateTime,
        validDistanceKm: double.tryParse(_distanceController.text) ?? 0.0,
        difficulty: _difficulty,
        isPrivate: _isPrivate,
        participantIds: widget.rideToEdit?.participantIds ?? [currentUserId],
        joinRequestIds: widget.rideToEdit?.joinRequestIds ?? [],
      );

      final notifier = ref.read(rideControllerProvider.notifier);
      Future<void> action;

      if (widget.rideToEdit != null) {
        action = notifier.updateRide(newRide);
      } else {
        action = notifier.createRide(newRide);
      }

      action.then((_) {
        // Check if controller has error
        final state = ref.read(rideControllerProvider);
        if (state.hasError && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${ErrorHandler.getErrorMessage(state.error!)}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else if (mounted) {
          // Pop back
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.rideToEdit != null ? 'Ride Updated!' : 'Ride Created!',
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.rideToEdit != null ? 'Edit Ride' : 'Create New Ride',
        ),
        actions: [
          if (widget.rideToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Ride?'),
                    content: const Text(
                      'This will cancel the ride and notify all participants. This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => ctx.pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ctx.pop(); // Close dialog
                          ref
                              .read(rideControllerProvider.notifier)
                              .deleteRide(
                                widget.rideToEdit!.id,
                                widget.rideToEdit!,
                              )
                              .then((_) {
                                final state = ref.read(rideControllerProvider);
                                if (state.hasError && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error: ${ErrorHandler.getErrorMessage(state.error!)}',
                                      ),
                                    ),
                                  );
                                } else if (context.mounted) {
                                  context.go('/home'); // Go to Home
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ride Deleted'),
                                    ),
                                  );
                                }
                              });
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Ride Title',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Sunday Hills Run',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Describe route, pace, stops...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PlacesAutocompleteField(
                      label: 'Start Location',
                      prefixIcon: Icons.circle,
                      controller: _fromController,
                      onSelected: (address, lat, lng) {
                        setState(() {
                          _fromController.text = address;
                          _fromLat = lat;
                          _fromLng = lng;
                        });
                        _calculateRoute();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: () async {
                      final result = await context.push('/location-picker');
                      if (result != null && result is LocationPickerResult) {
                        setState(() {
                          _fromController.text = result.address;
                          _fromLat = result.latLng.latitude;
                          _fromLng = result.latLng.longitude;
                        });
                        _calculateRoute();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PlacesAutocompleteField(
                      label: 'End Location',
                      prefixIcon: Icons.circle_outlined,
                      controller: _toController,
                      onSelected: (address, lat, lng) {
                        setState(() {
                          _toController.text = address;
                          _toLat = lat;
                          _toLng = lng;
                        });
                        _calculateRoute();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: () async {
                      final result = await context.push('/location-picker');
                      if (result != null && result is LocationPickerResult) {
                        setState(() {
                          _toController.text = result.address;
                          _toLat = result.latLng.latitude;
                          _toLng = result.latLng.longitude;
                        });
                        _calculateRoute();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Distance (km)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: _difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Easy', 'Medium', 'Hard']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _difficulty = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Private Ride'),
                subtitle: const Text('Only approved users can join'),
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
              ),
              const SizedBox(height: 32),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    child: Text(
                      widget.rideToEdit != null
                          ? 'Save Changes'
                          : 'Create Ride',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
