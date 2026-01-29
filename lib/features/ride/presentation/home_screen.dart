import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'ride_providers.dart';
import '../../../core/presentation/widgets/ride_card.dart';
import '../../../core/presentation/widgets/loading_skeleton.dart';
import '../../../core/presentation/widgets/empty_state_widget.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_typography.dart';
import '../../../../core/utils/error_handler.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rideControllerProvider.notifier).getNearbyRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ridesState = ref.watch(rideControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient (Subtle teal/aqua)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryAqua.withValues(alpha: 0.05),
                  AppColors.primaryBlue.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(rideControllerProvider.notifier)
                  .getNearbyRides(forceRefresh: true),
              child: CustomScrollView(
                slivers: [
                  // App Bar / Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Discover',
                                style: AppTypography.header.copyWith(
                                  fontSize: 32,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: AppColors.primaryAqua,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    ref.watch(currentLocationNameProvider),
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.primaryAqua,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () =>
                                context.push('/notification-center'),
                            icon: const Icon(
                              Icons.notifications_none,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: -0.2),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        readOnly: true,
                        onTap: () => context.push('/user-search'),
                        decoration: InputDecoration(
                          hintText: 'Search rides or riders...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textTertiary,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Ride List
                  ridesState.when(
                    data: (rides) => rides.isEmpty
                        ? const SliverFillRemaining(
                            child: EmptyStateWidget(
                              title: 'No Rides Found',
                              message:
                                  'Be the first to create a ride in your area!',
                              icon: Icons.motorcycle_outlined,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final ride = rides[index];
                              return RideCard(
                                    rideName: ride.title,
                                    isPrivate: ride.isPrivate,
                                    distance:
                                        '${ride.validDistanceKm.toStringAsFixed(1)} km',
                                    date: 'Today',
                                    onJoin: () {},
                                    onTap: () => context.push(
                                      '/ride-detail',
                                      extra: ride,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: (index * 100).ms)
                                  .slideY(begin: 0.1);
                            }, childCount: rides.length),
                          ),
                    loading: () => SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const Padding(
                          padding: EdgeInsets.all(20),
                          child: LoadingSkeleton(height: 180, borderRadius: 24),
                        ),
                        childCount: 3,
                      ),
                    ),
                    error: (error, _) => SliverFillRemaining(
                      child: Center(
                        child: Text(ErrorHandler.getErrorMessage(error)),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
