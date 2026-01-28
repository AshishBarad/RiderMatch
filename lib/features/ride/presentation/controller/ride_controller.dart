import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ride.dart';
import '../../domain/usecases/get_nearby_rides_usecase.dart';
import '../../domain/usecases/create_ride_usecase.dart';
import '../../domain/usecases/update_ride_usecase.dart';
import '../../domain/usecases/participant_management_usecases.dart';
import '../../domain/usecases/delete_ride_usecase.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../../../notifications/data/datasources/notification_remote_data_source.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/seed_data.dart';
import '../ride_providers.dart';

class RideController extends StateNotifier<AsyncValue<List<Ride>>> {
  final GetNearbyRidesUseCase _getNearbyRidesUseCase;
  final CreateRideUseCase _createRideUseCase;
  final UpdateRideUseCase _updateRideUseCase;
  final DeleteRideUseCase _deleteRideUseCase;
  final RequestToJoinUseCase _requestToJoinUseCase;
  final AcceptJoinRequestUseCase _acceptJoinRequestUseCase;
  final RejectJoinRequestUseCase _rejectJoinRequestUseCase;
  final RemoveParticipantUseCase _removeParticipantUseCase;
  final InviteUserUseCase _inviteUserUseCase;
  final NotificationRemoteDataSource _notificationDataSource;

  final Ref ref;

  RideController(
    this.ref,
    this._getNearbyRidesUseCase,
    this._createRideUseCase,
    this._updateRideUseCase,
    this._deleteRideUseCase,
    this._requestToJoinUseCase,
    this._acceptJoinRequestUseCase,
    this._rejectJoinRequestUseCase,
    this._removeParticipantUseCase,
    this._inviteUserUseCase,
    this._notificationDataSource,
  ) : super(const AsyncValue.loading());

  bool _isFemaleFilterActive = false;
  bool get isFemaleFilterActive => _isFemaleFilterActive;

  Future<void> toggleFemaleFilter(bool value) async {
    _isFemaleFilterActive = value;
    await getNearbyRides();
  }

  Future<void> seedTestData() async {
    state = const AsyncValue.loading();
    try {
      await SeedData.seedRides();
      await getNearbyRides();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> getNearbyRides() async {
    state = const AsyncValue.loading();

    double radiusKm = 50.0;
    double myLat = 37.7749; // Fallback
    double myLng = -122.4194; // Fallback

    try {
      // 1. Get User Profile for Distance Preference
      final authState = ref.read(authControllerProvider);
      final user = authState.value;
      if (user != null) {
        radiusKm = user.rideDistancePreference;
      }

      // 2. Get Real Location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          // Try last known first (fast)
          Position? position = await Geolocator.getLastKnownPosition();

          if (position == null) {
            // Then current with timeout
            position = await Geolocator.getCurrentPosition(
              timeLimit: const Duration(seconds: 10),
            );
          }

          myLat = position.latitude;
          myLng = position.longitude;

          // 3. Reverse Geocode via API (Build-safe approach)
          try {
            final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
            if (apiKey != null) {
              final url =
                  'https://maps.googleapis.com/maps/api/geocode/json?latlng=$myLat,$myLng&key=$apiKey';
              final response = await http.get(Uri.parse(url));

              if (response.statusCode == 200) {
                final data = json.decode(response.body);
                if (data['status'] == 'OK' && data['results'].isNotEmpty) {
                  final components =
                      data['results'][0]['address_components'] as List;
                  String? city;
                  String? subLocality;

                  for (var component in components) {
                    final types = component['types'] as List;
                    if (types.contains('locality')) {
                      city = component['long_name'];
                    } else if (types.contains('sublocality')) {
                      if (subLocality == null) {
                        subLocality = component['long_name'];
                      }
                    }
                  }

                  final locName = subLocality != null && city != null
                      ? '$subLocality, $city'
                      : city ?? subLocality ?? 'Near You';
                  ref.read(currentLocationNameProvider.notifier).state =
                      locName;
                }
              }
            }
          } catch (e) {
            debugPrint('⚠️ Geocoding API failed: $e');
          }

          if (kDebugMode) {
            print('📍 Using Real Location: $myLat, $myLng');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          '⚠️ Location fetch failed or timed out: $e. Using fallback ($myLat, $myLng).',
        );
      }
    }

    state = await AsyncValue.guard(
      () =>
          _getNearbyRidesUseCase(myLat, myLng, radiusKm, _isFemaleFilterActive),
    );
  }

  Future<void> createRide(Ride ride) async {
    state = const AsyncValue.loading();
    try {
      await _createRideUseCase(ride);
      _invalidateLists();
      await getNearbyRides();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateRide(Ride ride) async {
    state = const AsyncValue.loading();
    try {
      await _updateRideUseCase(ride);
      _invalidateLists();
      ref.invalidate(rideDetailProvider(ride.id));
      await getNearbyRides();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteRide(String rideId, Ride ride) async {
    state = const AsyncValue.loading();
    try {
      await _deleteRideUseCase(rideId);
      _invalidateLists();
      await getNearbyRides();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> requestToJoin(String rideId, String userId) async {
    if (state.isLoading) return;

    try {
      await _requestToJoinUseCase(rideId, userId);

      // Notify Creator
      final currentRides = state.value ?? [];
      final ride = currentRides.where((r) => r.id == rideId).firstOrNull;
      if (ride != null) {
        final authState = ref.read(authControllerProvider);
        final currentUserName = authState.value?.fullName ?? 'Someone';

        await _notificationDataSource.createNotification(
          ride.creatorId,
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID
            title: 'New Join Request',
            body: '$currentUserName wants to join "${ride.title}"',
            rideId: rideId,
            type: 'join_request', // ACTIONABLE TYPE
            senderId: userId, // The requester ID
            timestamp: DateTime.now(),
          ),
        );
      }

      _invalidateLists();
      ref.invalidate(rideDetailProvider(rideId));
      await getNearbyRides();
    } catch (e) {
      debugPrint('Error requesting to join: $e');
    }
  }

  Future<void> acceptJoinRequest(String rideId, String userId) async {
    try {
      await _acceptJoinRequestUseCase(rideId, userId);

      // Notify User
      final currentRides = state.value ?? [];
      final ride = currentRides.where((r) => r.id == rideId).firstOrNull;
      if (ride != null) {
        await _notificationDataSource.createNotification(
          userId,
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Request Approved',
            body: 'You have been added to "${ride.title}"',
            rideId: rideId,
            timestamp: DateTime.now(),
          ),
        );
      }

      _invalidateLists();
      ref.invalidate(rideDetailProvider(rideId));
      await getNearbyRides();
    } catch (e) {
      debugPrint('Error accepting join request: $e');
    }
  }

  Future<void> rejectJoinRequest(String rideId, String userId) async {
    try {
      await _rejectJoinRequestUseCase(rideId, userId);
      _invalidateLists();
      ref.invalidate(rideDetailProvider(rideId));
      await getNearbyRides();
    } catch (e) {
      debugPrint('Error rejecting join request: $e');
    }
  }

  Future<void> removeParticipant(String rideId, String userId) async {
    try {
      // Find ride to get creator info before removal if we want to notify
      final currentRides = state.value ?? [];
      final ride = currentRides.firstWhere((r) => r.id == rideId);

      await _removeParticipantUseCase(rideId, userId);

      // Simulate Notification to Creator
      if (ride.creatorId != userId) {
        debugPrint(
          '🔔 NOTIFICATION SENT to Creator (${ride.creatorId}): User $userId has left your ride "${ride.title}".',
        );
      }

      _invalidateLists();
      ref.invalidate(rideDetailProvider(rideId));
      await getNearbyRides();
    } catch (e) {
      debugPrint('Error removing participant: $e');
    }
  }

  Future<void> inviteUser(String rideId, String userId) async {
    try {
      await _inviteUserUseCase(rideId, userId);

      // Notify User
      final currentRides = state.value ?? [];
      final ride = currentRides.where((r) => r.id == rideId).firstOrNull;
      if (ride != null) {
        // Fetch creator name for better notification
        final authState = ref.read(authControllerProvider);
        final creatorName = authState.value?.fullName ?? 'Someone';

        await _notificationDataSource.createNotification(
          userId,
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Ride Invitation',
            body: '$creatorName invited you to "${ride.title}"',
            rideId: rideId,
            type: 'ride_invite',
            senderId: ride.creatorId,
            timestamp: DateTime.now(),
          ),
        );
      }

      await getNearbyRides();
      ref.invalidate(rideDetailProvider(rideId)); // Force refresh details
    } catch (e) {
      // Handle error
    }
  }

  Future<void> acceptRideInvite(String rideId) async {
    try {
      final authState = ref.read(authControllerProvider);
      final userId = authState.value?.id;
      if (userId == null) return;

      await _acceptJoinRequestUseCase(rideId, userId);

      _invalidateLists();
      ref.invalidate(rideDetailProvider(rideId));
      await getNearbyRides();
    } catch (e) {
      debugPrint('Error accepting ride invite: $e');
    }
  }

  void _invalidateLists() {
    ref.invalidate(createdRidesProvider);
    ref.invalidate(joinedRidesProvider);
  }
}
