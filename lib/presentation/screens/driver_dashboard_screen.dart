import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../blocs/ride_bloc/ride_bloc.dart';
import '../blocs/ride_bloc/ride_event.dart';
import '../blocs/ride_bloc/ride_state.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/ride_entity.dart';
import '../widgets/skeleton_loader.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _previousPendingCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshRides();
  }

  void _refreshRides() {
    HapticFeedback.lightImpact();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<RideBloc>().add(WatchAvailableRidesEvent());
      context.read<RideBloc>().add(WatchDriverRidesEvent(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tableau de bord Conducteur'),
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: colorScheme.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Disponibles'),
              Tab(text: 'Mes Trajets'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: colorScheme.primary),
              onPressed: _refreshRides,
            ),
          ],
        ),
        body: BlocListener<RideBloc, RideState>(
          listenWhen: (previous, current) {
            if (current is AvailableRidesLoaded) {
               final pendingCount = current.rides.where((r) => r.status == RideStatus.pending).length;
               final isNew = pendingCount > _previousPendingCount;
               _previousPendingCount = pendingCount;
               return isNew;
            }
            return false;
          },
          listener: (context, state) {
            if (state is AvailableRidesLoaded) {
              final newRide = state.rides.where((r) => r.status == RideStatus.pending).last;
              _showIncomingRidePopup(context, newRide, colorScheme);
            }
          },
          child: TabBarView(
            children: [
              _buildAvailableRides(colorScheme),
              _buildMyRides(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  void _showIncomingRidePopup(BuildContext context, RideEntity ride, ColorScheme colorScheme) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 24),
            Text('NOUVEAU TRAJET 🔔', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colorScheme.primary)),
            const SizedBox(height: 16),
            _buildRideCard(ride, colorScheme, isAvailable: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableRides(ColorScheme colorScheme) {
    return BlocBuilder<RideBloc, RideState>(
      builder: (context, state) {
        if (state is AvailableRidesLoaded) {
          final pendingRides = state.rides.where((r) => r.status == RideStatus.pending).toList();
          if (pendingRides.isEmpty) {
            return Center(child: Text('Aucun trajet disponible.', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingRides.length,
            itemBuilder: (context, index) => _buildRideCard(pendingRides[index], colorScheme, isAvailable: true),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          itemBuilder: (context, index) => SkeletonLoader.rideCardSkeleton(),
        );
      },
    );
  }

  Widget _buildMyRides(ColorScheme colorScheme) {
    return BlocBuilder<RideBloc, RideState>(
      builder: (context, state) {
        if (state is AvailableRidesLoaded) {
          final authState = context.read<AuthBloc>().state;
          if (authState is Authenticated) {
            final driverId = authState.user.id;
            final myRides = state.rides.where((r) => r.driverId == driverId).toList();
            if (myRides.isEmpty) {
              return Center(child: Text('Vous n\'avez pas de trajets en cours.', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myRides.length,
              itemBuilder: (context, index) => _buildRideCard(myRides[index], colorScheme, isAvailable: false),
            );
          }
          return const SizedBox();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 2,
          itemBuilder: (context, index) => SkeletonLoader.rideCardSkeleton(),
        );
      },
    );
  }

  Widget _buildRideCard(RideEntity ride, ColorScheme colorScheme, {required bool isAvailable}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Hero(
                  tag: 'driver-${ride.id}',
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person, color: colorScheme.primary, size: 20),
                  ),
                ),
                Text(
                  '${ride.scheduledTime.hour}:${ride.scheduledTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: colorScheme.onSurface),
                ),
                if (ride.isWomenSafe)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(Icons.female, color: Colors.pink, size: 14),
                        SizedBox(width: 4),
                        Text('Women Safe', style: TextStyle(fontSize: 10, color: Colors.pink, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                Text(
                  '${ride.estimatedPrice.toStringAsFixed(2)} ${AppConstants.currencyCode}',
                  style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildLocationRow(Icons.my_location, ride.pickupAddress, colorScheme.primary),
            const SizedBox(height: 12),
            _buildLocationRow(Icons.location_on, ride.destinationAddress, colorScheme.error),
            const SizedBox(height: 24),
            if (isAvailable)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _acceptRide(ride.id),
                  child: const Text('ACCEPTER LE TRAJET'),
                ),
              )
            else if (ride.status == RideStatus.accepted)
              _buildOtpInput(ride.id, colorScheme)
            else
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    ride.status == RideStatus.started ? 'TRAJET EN COURS' : 'TERMINÉ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String address, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(address, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildOtpInput(String rideId, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Code OTP requis pour démarrer',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _otpController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 8),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '----',
                  hintStyle: TextStyle(letterSpacing: 8),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(color: colorScheme.secondary, borderRadius: BorderRadius.circular(16)),
              child: IconButton(
                onPressed: () => _verifyOtp(rideId),
                icon: Icon(Icons.play_arrow_rounded, color: colorScheme.onSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _acceptRide(String rideId) {
    HapticFeedback.mediumImpact();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<RideBloc>().add(AcceptRideEvent(rideId, authState.user.id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trajet accepté ! Allez aux "Mes Trajets"')));
    }
  }

  void _verifyOtp(String rideId) {
    if (_otpController.text.length != 4) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir un code à 4 chiffres.')));
      return;
    }
    HapticFeedback.heavyImpact();
    context.read<RideBloc>().add(VerifyOtpEvent(rideId, _otpController.text));
    _otpController.clear();
  }
}
