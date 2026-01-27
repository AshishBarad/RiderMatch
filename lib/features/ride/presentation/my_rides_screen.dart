import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/entities/ride.dart';
import 'ride_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../../../core/utils/error_handler.dart';
import 'package:flutter/foundation.dart';

class MyRidesScreen extends ConsumerStatefulWidget {
  const MyRidesScreen({super.key});

  @override
  ConsumerState<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends ConsumerState<MyRidesScreen> {
  Future<void> _refresh() async {
    setState(() {}); // Triggers FutureBuilder to rerun
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.value?.id;

    if (kDebugMode) {
      print('DEBUG: MyRidesScreen build. UserId: $userId');
    }

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Rides')),
        body: const Center(child: Text('Please log in to view your rides')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Rides')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<List<Ride>>>(
          future: Future.wait([
            ref.read(getCreatedRidesUseCaseProvider)(userId),
            ref.read(getJoinedRidesUseCaseProvider)(userId),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              if (kDebugMode) {
                print('DEBUG: MyRidesScreen error: ${snapshot.error}');
              }
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Text(ErrorHandler.getErrorMessage(snapshot.error!)),
                  ),
                ),
              );
            }

            final createdRides = snapshot.data?[0] ?? [];
            final joinedRides = snapshot.data?[1] ?? [];

            // Sort client-side (since we removed Firestore orderBy to fix index error)
            createdRides.sort((a, b) => b.dateTime.compareTo(a.dateTime));
            joinedRides.sort((a, b) => b.dateTime.compareTo(a.dateTime));

            if (createdRides.isEmpty && joinedRides.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: const Center(
                    child: Text(
                      'No ride data found. Create a ride to get started!',
                    ),
                  ),
                ),
              );
            }

            if (kDebugMode) {
              print(
                'DEBUG: Found ${createdRides.length} created rides and ${joinedRides.length} joined rides',
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (createdRides.isNotEmpty)
                    _buildRideSection(
                      context,
                      'Created Rides',
                      createdRides,
                      true,
                    ),
                  if (createdRides.isNotEmpty && joinedRides.isNotEmpty)
                    const SizedBox(height: 32),
                  if (joinedRides.isNotEmpty)
                    _buildRideSection(
                      context,
                      'Ride History (Joined)',
                      joinedRides,
                      false,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRideSection(
    BuildContext context,
    String title,
    List<Ride> rides,
    bool isCreated,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${rides.length} rides',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rides.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ride = rides[index];
            return _buildRideListItem(context, ride);
          },
        ),
      ],
    );
  }

  Widget _buildRideListItem(BuildContext context, Ride ride) {
    final dateStr = DateFormat('EEE, MMM d • h:mm a').format(ride.dateTime);
    final isPast = ride.dateTime.isBefore(DateTime.now());

    return InkWell(
      onTap: () => context.push('/ride-detail', extra: ride),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPast ? Colors.grey[200] : Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPast ? Icons.history : Icons.event,
                color: isPast ? Colors.grey[600] : Colors.blue[700],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: isPast ? Colors.grey : Colors.blue[700],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'To: ${ride.toLocation}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
