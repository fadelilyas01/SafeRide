import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../../core/utils/location_service.dart';
import '../../core/services/tracking_service.dart';
import '../../core/services/ride_service.dart';

import '../../core/models/ride_model.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(48.8566, 2.3522); // Paris (Defaut)
  final LocationService _locationService = LocationService();
  final TrackingService _trackingService = TrackingService();
  final RideService _rideService = RideService();

  bool _isDriverMode = false;
  RideModel? _currentRide;
  bool _isRequesting = false;

  // SafeGate Variables
  Timer? _anomalyTimer;
  Position? _lastPosition;
  int _inactivityPoints = 0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  void dispose() {
    _trackingService.stopTracking();
    _anomalyTimer?.cancel();
    super.dispose();
  }

  void _getUserLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Erreur localisation : $e");
    }
  }

  void _onDestinationSelected(String destination) async {
    final position = await _locationService.getCurrentLocation();
    if (position == null) return;
    final pickup = LatLng(position.latitude, position.longitude);
    final dropoff = LatLng(position.latitude + 0.02, position.longitude + 0.02);
    if (!mounted) return;
    _showConfirmationSheet(destination, pickup, dropoff, 18.25);
  }

  void _showConfirmationSheet(
    String destination,
    LatLng pickup,
    LatLng dropoff,
    double price,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Confirmer votre course",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.location_on, "Départ", "Ma position actuelle"),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.flag, "Destination", destination),
            const Divider(color: Colors.white12, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Prix estimé",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  "${price.toStringAsFixed(2)} \$ CAD",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  const Text(
                    "•••• 4242",
                    style: TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Changer",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () =>
                    _requestRide(destination, pickup, dropoff, price),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Commander SafeRide",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  void _requestRide(
    String destination,
    LatLng pickup,
    LatLng dropoff,
    double price,
  ) async {
    Navigator.pop(context);
    setState(() => _isRequesting = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final ride = RideModel(
      riderId: userId,
      pickupAddress: "Ma position",
      pickupLat: pickup.latitude,
      pickupLng: pickup.longitude,
      dropoffAddress: destination,
      dropoffLat: dropoff.latitude,
      dropoffLng: dropoff.longitude,
      price: price,
    );

    try {
      final newRide = await _rideService.createRide(ride);
      setState(() {
        _currentRide = newRide;
        _isRequesting = false;
      });
      _listenToRideUpdates(newRide.id!);
      _startSafeGateMonitoring();
    } catch (e) {
      setState(() => _isRequesting = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  void _listenToRideUpdates(String rideId) {
    _rideService.streamRideStatus(rideId).listen((updatedRide) {
      if (mounted) {
        if (updatedRide.status == RideStatus.completed &&
            _currentRide?.status != RideStatus.completed) {
          _showRatingDialog();
        }
        setState(() {
          _currentRide = updatedRide;
        });
      }
    });
  }

  void _showRatingDialog() {
    _anomalyTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Course terminée !"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Comment s est déroulé votre trajet ?"),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 40),
                Icon(Icons.star, color: Colors.amber, size: 40),
                Icon(Icons.star, color: Colors.amber, size: 40),
                Icon(Icons.star, color: Colors.amber, size: 40),
                Icon(Icons.star, color: Colors.amber, size: 40),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _currentRide = null);
            },
            child: const Text("Envoyer"),
          ),
        ],
      ),
    );
  }

  void _triggerSOS() async {
    context.push('/safety');
  }

  void _startSafeGateMonitoring() {
    _anomalyTimer?.cancel();
    _inactivityPoints = 0;

    _anomalyTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_currentRide == null || _currentRide!.status != RideStatus.inProgress) {
        return;
      }

      final currentPos = await _locationService.getCurrentLocation();
      if (currentPos == null || _lastPosition == null) {
        _lastPosition = currentPos;
        return;
      }

      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        currentPos.latitude,
        currentPos.longitude,
      );

      if (distance < 20) {
        _inactivityPoints++;
      } else {
        _inactivityPoints = 0;
      }

      // Si le véhicule est immobile pendant 5 minutes (5 points)
      if (_inactivityPoints >= 5) {
        _reportAnomaly("Suspicious Stop: Vehicle immobile for 5 minutes.");
        _inactivityPoints = 0; // Reset after alert
      }

      _lastPosition = currentPos;
    });
  }

  void _reportAnomaly(String message) async {
    if (_currentRide == null) return;
    await Supabase.instance.client.from('audit_logs').insert({
      'action': 'SILENT_ANOMALY',
      'target_id': _currentRide!.id,
      'actor_id': Supabase.instance.client.auth.currentUser?.id,
      'status': 'WARNING',
      'details': {
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Détection SafeGate : Immobilisation prolongée détectée.',
          ),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  void _shareLiveTrip() {
    if (_currentRide == null) return;
    final url = "http://localhost:3000/track/${_currentRide!.id}";
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lien Family Shield copié dans le presse-papiers !'),
      ),
    );
  }

  void _toggleDriverMode(bool value) {
    setState(() {
      _isDriverMode = value;
    });
    if (_isDriverMode) {
      _trackingService.startTracking();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mode Chauffeur activé')));
    } else {
      _trackingService.stopTracking();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mode Chauffeur désactivé')));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 14.0),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Custom Top Bar with Profile logic
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.person, color: Colors.black),
                    onPressed: () => context.push('/profile'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.car_rental,
                        size: 20,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _isDriverMode,
                        onChanged: _toggleDriverMode,
                        activeThumbColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _currentRide != null ? _triggerSOS : null,
                  icon: const Icon(Icons.sos, color: Colors.white),
                  label: const Text("SOS"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomPanel()),

          if (_isRequesting)
            const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    if (_currentRide != null) return _buildActiveRidePanel();
    if (_isDriverMode) return _buildDriverPanel();
    return _buildRiderPanel();
  }

  Widget _buildRiderPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Où allez-vous ?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final dest = await context.push<String>('/search');
              if (dest != null) _onDestinationSelected(dest);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 12),
                  Text(
                    "Rechercher une destination...",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDriverPanel() {
    return FutureBuilder<List<RideModel>>(
      future: _rideService.getAvailableRides(),
      builder: (context, snapshot) {
        final rides = snapshot.data ?? [];
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Demandes à proximité",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                    onPressed: () => setState(() {}),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (rides.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "Aucune course disponible",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...rides.map((ride) => _buildRideRequestTile(ride)),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRideRequestTile(RideModel ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.dropoffAddress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
                Text(
                  "${ride.price.toStringAsFixed(2)} \$ CAD",
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _acceptRide(ride),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            child: const Text("Accepter"),
          ),
        ],
      ),
    );
  }

  void _acceptRide(RideModel ride) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client
          .from('rides')
          .update({'driver_id': userId, 'status': RideStatus.accepted.name})
          .eq('id', ride.id!);
      setState(() {
        _currentRide = ride;
      });
      _listenToRideUpdates(ride.id!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Widget _buildActiveRidePanel() {
    String statusText = "Recherche d'un chauffeur...";
    if (_currentRide!.status == RideStatus.accepted) {
      statusText = "Chauffeur en route !";
    }
    if (_currentRide!.status == RideStatus.arrived) {
      statusText = "Le chauffeur est là !";
    }
    if (_currentRide!.status == RideStatus.inProgress) {
      statusText = "Course en cours...";
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      "Suivez votre trajet en direct",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.blueAccent),
                onPressed: _shareLiveTrip,
              ),
              IconButton(
                icon: const Icon(Icons.chat, color: Colors.blueAccent),
                onPressed: () => context.push('/chat/${_currentRide!.id}'),
              ),
              if (_currentRide!.status == RideStatus.pending)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: () => _rideService
                      .cancelRide(_currentRide!.id!)
                      .then((_) => setState(() => _currentRide = null)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (_currentRide!.status == RideStatus.pending)
            const LinearProgressIndicator(
              color: Colors.blueAccent,
              backgroundColor: Colors.white12,
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
