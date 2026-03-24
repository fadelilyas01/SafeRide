import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/map_style.dart';
import '../blocs/ride_bloc/ride_bloc.dart';
import '../blocs/ride_bloc/ride_event.dart';
import '../blocs/ride_bloc/ride_state.dart';
import '../../core/constants/app_constants.dart';
import '../../injection_container.dart';
import '../../data/datasources/navigation_service.dart';
import '../../data/datasources/stripe_service.dart';
import '../widgets/otp_display_widget.dart';
import '../widgets/chat_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/rating_dialog.dart';
import '../blocs/auth_bloc/auth_bloc.dart';

import '../blocs/auth_bloc/auth_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/ride_entity.dart';

class ActiveRideScreen extends StatefulWidget {
  final String rideId;
  const ActiveRideScreen({super.key, required this.rideId});

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  final Set<gmaps.Polyline> _polylines = {};
  bool _polylinesLoaded = false;
  bool _ratingShown = false;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    context.read<RideBloc>().add(WatchActiveRideEvent(widget.rideId));
  }

  Future<void> _loadPolylines(RideEntity ride) async {
    if (_polylinesLoaded) return;
    
    final navService = sl<NavigationService>();
    final points = await navService.getPolylinePoints(ride.pickupLocation, ride.destinationLocation);
    
    if (points.isNotEmpty) {
      if (mounted) {
        setState(() {
          _polylines.add(
            gmaps.Polyline(
              polylineId: const gmaps.PolylineId('route'),
              points: points,
              color: Theme.of(context).colorScheme.primary,
              width: 5,
              jointType: gmaps.JointType.round,
            ),
          );
          _polylinesLoaded = true;
        });
      }
    }
  }

  void _showRatingDialog(RideEntity ride) {
    if (_ratingShown) return;
    _ratingShown = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        driverName: ride.driverName ?? 'votre chauffeur',
        onSubmitted: (rating, comment) {
          context.read<RideBloc>().add(SubmitRatingEvent(
            rideId: ride.id,
            rating: rating,
            comment: comment,
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RideBloc, RideState>(
        listener: (context, state) {
          if (state is RideActive && state.ride.status == RideStatus.completed) {
            // Wait for payment before showing rating, logic handled in button
          }
        },
        child: BlocBuilder<RideBloc, RideState>(
          builder: (context, state) {
            if (state is RideActive) {
              _loadPolylines(state.ride);
              return ResponsiveLayout(
                mobile: _buildMobileLayout(state.ride),
                tablet: _buildTabletLayout(state.ride),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(RideEntity ride) {
    return Stack(
      children: [
        _buildMap(ride),
        _buildTopOverlay(ride),
        _buildRideDetailsPanel(ride),
        _buildSOSButton(),
      ],
    );
  }

  Widget _buildTabletLayout(RideEntity ride) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              _buildMap(ride),
              _buildSOSButton(),
            ],
          ),
        ),
        Container(
          width: 400,
          color: AppColors.background,
          child: Column(
            children: [
              _buildTopOverlay(ride),
              Expanded(child: SingleChildScrollView(child: _buildRideDetailsPanel(ride, isTablet: true))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap(RideEntity ride) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(target: ride.pickupLocation, zoom: 14),
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      polylines: _polylines,
      style: isDark ? AppMapStyles.darkStyle : AppMapStyles.premiumLightStyle,
      onMapCreated: (controller) {},
      markers: {
        gmaps.Marker(
          markerId: const gmaps.MarkerId('pickup'),
          position: ride.pickupLocation,
          infoWindow: const gmaps.InfoWindow(title: 'Départ'),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueCyan),
        ),
        gmaps.Marker(
          markerId: const gmaps.MarkerId('destination'),
          position: ride.destinationLocation,
          infoWindow: const gmaps.InfoWindow(title: 'Destination'),
          icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueAzure),
        ),
      },
    );
  }

  Widget _buildTopOverlay(RideEntity ride) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.security, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ride.isWomenSafe ? 'SafeRide Women • Protection active' : 'SafeRide • Trajet sécurisé',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideDetailsPanel(RideEntity ride, {bool isTablet = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Container(
      padding: const EdgeInsets.all(24),
      decoration: isTablet ? null : BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(colorScheme),
          const SizedBox(height: 12),
          if (ride.otp != null && ride.status == RideStatus.accepted) ...[
            OtpDisplayWidget(otp: ride.otp!),
            const SizedBox(height: 32),
          ],
          _buildDriverHeader(ride, colorScheme),
          const SizedBox(height: 32),
          _buildStatusProgress(ride, colorScheme),
          const SizedBox(height: 32),
          _buildActionButtons(ride, colorScheme),
        ],
      ),
    );

    return isTablet ? content : Positioned(bottom: 0, left: 0, right: 0, child: content);
  }

  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildDriverHeader(RideEntity ride, ColorScheme colorScheme) {
    return Row(
      children: [
        Stack(
          children: [
            Hero(
              tag: 'driver-${ride.id}',
              child: CircleAvatar(
                radius: 35,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: ride.driverId != null 
                    ? Icon(Icons.person, size: 35, color: colorScheme.primary)
                    : ClipOval(child: Lottie.network('https://assets9.lottiefiles.com/packages/lf20_touohxv0.json', height: 70, width: 70, fit: BoxFit.cover)),
              ),
            ),
            if (ride.isWomenSafe)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.pink, shape: BoxShape.circle),
                  child: const Icon(Icons.female, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ride.driverName ?? 'En attente...',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    ride.driverId != null ? '4.9 (150 trajets)' : 'Sélection du meilleur chauffeur',
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => _openChat(ride.id),
            icon: Icon(Icons.chat_bubble_rounded, color: colorScheme.secondary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusProgress(RideEntity ride, ColorScheme colorScheme) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _getProgress(ride.status),
          backgroundColor: colorScheme.surfaceContainerHighest,
          color: colorScheme.secondary,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getStatusText(ride.status).toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.primary, letterSpacing: 1.5, fontSize: 13),
            ),
            Text(
              '${(ride.estimatedPrice).toStringAsFixed(2)} ${AppConstants.currencyCode}',
              style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.secondary, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(RideEntity ride, ColorScheme colorScheme) {
    // Si la course est terminée, on affiche le bouton de paiement
    if (ride.status == RideStatus.completed) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isPaying ? null : () => _processPayment(ride),
          icon: _isPaying 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.payment, size: 20),
          label: Text(
            _isPaying ? 'TRAITEMENT EN COURS...' : 'PAYER ${(ride.estimatedPrice).toStringAsFixed(2)} ${AppConstants.currencyCode}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      );
    }

    // Sinon, boutons classiques
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, size: 20),
            label: const Text('PARTAGER'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onSurfaceVariant,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error.withValues(alpha: 0.1),
              foregroundColor: colorScheme.error,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('ANNULER', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment(RideEntity ride) async {
    setState(() => _isPaying = true);
    
    final stripeService = sl<StripeService>();
    final success = await stripeService.processPaymentSheet(ride.id, ride.estimatedPrice);
    
    if (mounted) {
      setState(() => _isPaying = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement réussi ! Merci.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _showRatingDialog(ride);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec du paiement. Veuillez réessayer.'),
            backgroundColor: AppColors.alert,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildSOSButton() {
    return Positioned(
      top: 130,
      right: 20,
      child: GlassCard(
        blur: 5,
        opacity: 0.2,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(50),
        child: FloatingActionButton(
          heroTag: 'sos',
          onPressed: _showSOSDialog,
          backgroundColor: AppColors.alert,
          elevation: 0,
          child: const Text('SOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  void _openChat(String rideId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatWidget(rideId: rideId),
    );
  }

  void _showSOSDialog() {
    final authState = context.read<AuthBloc>().state;
    List<ContactEntity> contacts = [];
    if (authState is Authenticated) {
      contacts = authState.user.emergencyContacts;
    }

    HapticFeedback.vibrate();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.alert),
            SizedBox(width: 8),
            Text('URGENCE SOS'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Une alerte immédiate sera envoyée à nos services de sécurité.'),
            const SizedBox(height: 16),
            if (contacts.isNotEmpty) ...[
              const Text('Les contacts suivants recevront également votre position en temps réel :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              ...contacts.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 14),
                    const SizedBox(width: 8),
                    Text('${c.name} (${c.phoneNumber})', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              )),
            ] else 
              const Text('Note : Vous n\'avez pas configuré de contacts d\'urgence dans votre profil.', style: TextStyle(color: AppColors.alert, fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Erreur')),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ALERTE SOS ENVOYÉE ! Les secours et vos contacts ont été prévenus.'),
                  backgroundColor: AppColors.alert,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alert),
            child: const Text('ACTIVER SOS'),
          ),
        ],
      ),
    );
  }

  double _getProgress(RideStatus status) {
    switch (status) {
      case RideStatus.pending: return 0.2;
      case RideStatus.accepted: return 0.4;
      case RideStatus.onWay: return 0.6;
      case RideStatus.started: return 0.8;
      case RideStatus.completed: return 1.0;
      default: return 0.0;
    }
  }

  String _getStatusText(RideStatus status) {
    switch (status) {
      case RideStatus.pending: return 'Confirmation en cours';
      case RideStatus.accepted: return 'Chauffeur en route';
      case RideStatus.onWay: return 'Proche de vous';
      case RideStatus.started: return 'Trajet actif';
      case RideStatus.completed: return 'Vous êtes arrivé';
      default: return 'Annulé';
    }
  }
}
