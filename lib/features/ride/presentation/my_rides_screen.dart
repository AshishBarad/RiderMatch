import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/entities/ride.dart';
import 'ride_providers.dart';
import '../../../../core/utils/error_handler.dart';

class MyRidesScreen extends ConsumerStatefulWidget {
  const MyRidesScreen({super.key});

  @override
  ConsumerState<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends ConsumerState<MyRidesScreen> {
  Future<void> _refresh() async {
    ref.invalidate(createdRidesProvider);
    ref.invalidate(joinedRidesProvider);
    ref.invalidate(savedRidesProvider);
    // Wait for the providers to refresh
    await ref.read(createdRidesProvider.future);
    await ref.read(joinedRidesProvider.future);
    await ref.read(savedRidesProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final createdRidesAsync = ref.watch(createdRidesProvider);
    final joinedRidesAsync = ref.watch(joinedRidesProvider);
    final savedRidesAsync = ref.watch(savedRidesProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('My Rides')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: createdRidesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: Center(child: Text(ErrorHandler.getErrorMessage(err))),
            ),
          ),
          data: (createdRides) => joinedRidesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: Center(child: Text(ErrorHandler.getErrorMessage(err))),
              ),
            ),
            data: (joinedRides) => savedRidesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(child: Text(ErrorHandler.getErrorMessage(err))),
                ),
              ),
              data: (savedRides) {
                final sortedCreated = [...createdRides]
                  ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

                // Filter to show only past joined rides
                final sortedJoined =
                    joinedRides.where((r) => r.dateTime.isBefore(now)).toList()
                      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

                // Sort saved rides by date
                final sortedSaved = [...savedRides]
                  ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

                if (sortedCreated.isEmpty &&
                    sortedJoined.isEmpty &&
                    sortedSaved.isEmpty) {
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

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sortedSaved.isNotEmpty) ...[
                        _buildRideSection(
                          context,
                          'Saved Rides',
                          sortedSaved,
                          false,
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (sortedCreated.isNotEmpty)
                        _buildRideSection(
                          context,
                          'Created Rides',
                          sortedCreated,
                          true,
                        ),
                      if (sortedCreated.isNotEmpty && sortedJoined.isNotEmpty)
                        const SizedBox(height: 32),
                      if (sortedJoined.isNotEmpty)
                        _buildRideSection(
                          context,
                          'Ride History (Joined)',
                          sortedJoined,
                          false,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
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
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPast ? Colors.grey[100] : Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPast ? Icons.history_outlined : Icons.event_outlined,
                color: isPast ? Colors.grey[600] : Colors.blue[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ride.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      if (ride.isPrivate)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: isPast ? Colors.grey[600] : Colors.blue[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'To: ${ride.toLocation}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
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
