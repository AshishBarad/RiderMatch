import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/ride_remote_data_source.dart';
import '../data/repositories/ride_repository_impl.dart';
import '../domain/repositories/ride_repository.dart';
import '../domain/usecases/get_nearby_rides_usecase.dart';
import '../domain/usecases/create_ride_usecase.dart';
import '../domain/usecases/delete_ride_usecase.dart';
import '../domain/usecases/get_ride_by_id_usecase.dart';
import '../domain/repositories/places_repository.dart';
import '../data/datasources/places_remote_data_source.dart';
import '../domain/repositories/directions_repository.dart';
import '../data/datasources/directions_remote_data_source.dart';
import '../domain/usecases/get_ride_route_usecase.dart';
import '../domain/usecases/reverse_geocode_usecase.dart';
import '../domain/usecases/update_ride_usecase.dart';
import '../domain/usecases/participant_management_usecases.dart';
import '../domain/usecases/get_user_rides_usecases.dart';
import 'controller/ride_controller.dart';
import '../domain/entities/ride.dart';
import '../../notifications/data/datasources/notification_remote_data_source.dart';
import '../../auth/presentation/auth_providers.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      return NotificationRemoteDataSourceImpl();
    });

final rideDataSourceProvider = Provider<RideRemoteDataSource>((ref) {
  return RideRemoteDataSourceImpl();
});

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepositoryImpl(ref.watch(rideDataSourceProvider));
});

final getNearbyRidesUseCaseProvider = Provider<GetNearbyRidesUseCase>((ref) {
  return GetNearbyRidesUseCase(ref.watch(rideRepositoryProvider));
});

final createRideUseCaseProvider = Provider<CreateRideUseCase>((ref) {
  return CreateRideUseCase(ref.watch(rideRepositoryProvider));
});

final updateRideUseCaseProvider = Provider<UpdateRideUseCase>((ref) {
  return UpdateRideUseCase(ref.watch(rideRepositoryProvider));
});

final deleteRideUseCaseProvider = Provider<DeleteRideUseCase>((ref) {
  return DeleteRideUseCase(ref.watch(rideRepositoryProvider));
});

final requestToJoinUseCaseProvider = Provider<RequestToJoinUseCase>((ref) {
  return RequestToJoinUseCase(ref.watch(rideRepositoryProvider));
});

final acceptJoinRequestUseCaseProvider = Provider<AcceptJoinRequestUseCase>((
  ref,
) {
  return AcceptJoinRequestUseCase(ref.watch(rideRepositoryProvider));
});

final rejectJoinRequestUseCaseProvider = Provider<RejectJoinRequestUseCase>((
  ref,
) {
  return RejectJoinRequestUseCase(ref.watch(rideRepositoryProvider));
});

final removeParticipantUseCaseProvider = Provider<RemoveParticipantUseCase>((
  ref,
) {
  return RemoveParticipantUseCase(ref.watch(rideRepositoryProvider));
});

final inviteUserUseCaseProvider = Provider<InviteUserUseCase>((ref) {
  return InviteUserUseCase(ref.watch(rideRepositoryProvider));
});

final getRideByIdUseCaseProvider = Provider<GetRideByIdUseCase>((ref) {
  return GetRideByIdUseCase(ref.watch(rideRepositoryProvider));
});

final getCreatedRidesUseCaseProvider = Provider<GetCreatedRidesUseCase>((ref) {
  return GetCreatedRidesUseCase(ref.watch(rideRepositoryProvider));
});

final getJoinedRidesUseCaseProvider = Provider<GetJoinedRidesUseCase>((ref) {
  return GetJoinedRidesUseCase(ref.watch(rideRepositoryProvider));
});

final placesDataSourceProvider = Provider<PlacesRemoteDataSource>((ref) {
  return PlacesRemoteDataSourceImpl();
});

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  return PlacesRepositoryImpl(ref.watch(placesDataSourceProvider));
});

final directionsDataSourceProvider = Provider<DirectionsRemoteDataSource>((
  ref,
) {
  return DirectionsRemoteDataSourceImpl();
});

final directionsRepositoryProvider = Provider<DirectionsRepository>((ref) {
  return DirectionsRepositoryImpl(ref.watch(directionsDataSourceProvider));
});

final getRideRouteUseCaseProvider = Provider<GetRideRouteUseCase>((ref) {
  return GetRideRouteUseCase(ref.watch(directionsRepositoryProvider));
});

final reverseGeocodeUseCaseProvider = Provider<ReverseGeocodeUseCase>((ref) {
  return ReverseGeocodeUseCase(ref.watch(directionsRepositoryProvider));
});

final rideControllerProvider =
    StateNotifierProvider<RideController, AsyncValue<List<Ride>>>((ref) {
      return RideController(
        ref,
        ref.watch(getNearbyRidesUseCaseProvider),
        ref.watch(createRideUseCaseProvider),
        ref.watch(updateRideUseCaseProvider),
        ref.watch(deleteRideUseCaseProvider),
        ref.watch(requestToJoinUseCaseProvider),
        ref.watch(acceptJoinRequestUseCaseProvider),
        ref.watch(rejectJoinRequestUseCaseProvider),
        ref.watch(removeParticipantUseCaseProvider),
        ref.watch(inviteUserUseCaseProvider),
        ref.watch(notificationRemoteDataSourceProvider),
      );
    });

final currentLocationNameProvider = StateProvider<String>((ref) => 'Near You');

final rideDetailProvider = FutureProvider.family.autoDispose<Ride?, String>((
  ref,
  id,
) {
  return ref.watch(getRideByIdUseCaseProvider)(id);
});

final createdRidesProvider = FutureProvider.autoDispose<List<Ride>>((
  ref,
) async {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.value?.id;
  if (userId == null) return [];
  return ref.watch(getCreatedRidesUseCaseProvider)(userId);
});

final joinedRidesProvider = FutureProvider.autoDispose<List<Ride>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.value?.id;
  if (userId == null) return [];
  return ref.watch(getJoinedRidesUseCaseProvider)(userId);
});

final savedRidesProvider = FutureProvider.autoDispose<List<Ride>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final user = authState.value;
  if (user == null || user.savedRides.isEmpty) return [];

  // Fetch all saved rides by their IDs
  final rides = await Future.wait(
    user.savedRides.map(
      (rideId) => ref.watch(getRideByIdUseCaseProvider)(rideId),
    ),
  );

  // Filter out nulls and return
  return rides.whereType<Ride>().toList();
});
