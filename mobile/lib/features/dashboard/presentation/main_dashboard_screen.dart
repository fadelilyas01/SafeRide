import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:saferide_mobile/core/network/api_service.dart';
import 'package:saferide_mobile/core/theme/app_tokens.dart';
import 'package:saferide_mobile/core/widgets/safe_ride_map_view.dart';
import 'package:saferide_mobile/core/widgets/safe_ride_logo.dart';
import 'package:saferide_mobile/core/widgets/ride_ticket_card.dart';
import 'package:saferide_mobile/core/widgets/dead_man_hud_widget.dart';
import 'package:saferide_mobile/core/widgets/hold_to_sos_button.dart';
import 'package:saferide_mobile/core/widgets/incident_report_dialog.dart';
import 'package:saferide_mobile/features/driver/presentation/driver_verify_screen.dart';
import 'package:saferide_mobile/features/driver/presentation/publish_ride_sheet.dart';
import 'package:saferide_mobile/features/safety/presentation/trusted_contacts_sheet.dart';

class MainDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const MainDashboardScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  // Capteur GPS & Télémétrie
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(48.8566, 2.3522);
  double _speedKmh = 0.0;
  final bool _isDeviated = false;
  StreamSubscription<Position>? _positionSubscription;

  // Données de covoiturage
  List<dynamic> _availableRides = [];
  List<dynamic> _userReservations = [];
  List<dynamic> _driverReservations = [];
  String? _activeTripId;

  // Dead Man's Switch State
  bool _isDeadManActive = false;
  int _deadManTimeLeft = 60;
  Timer? _deadManTimer;
  Timer? _pollingTimer;

  bool get isDriver => widget.user['role'] == 'DRIVER';

  @override
  void initState() {
    super.initState();
    _initGpsTracker();
    _loadDashboardData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) => _loadDashboardData());
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _pollingTimer?.cancel();
    _deadManTimer?.cancel();
    super.dispose();
  }

  /// Initialisation du capteur GPS matériel du Galaxy S8
  Future<void> _initGpsTracker() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final initialPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );

        if (mounted) {
          setState(() {
            _currentLocation = LatLng(initialPos.latitude, initialPos.longitude);
            _speedKmh = (initialPos.speed * 3.6).clamp(0.0, 160.0);
          });
        }

        _positionSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen((pos) {
          if (mounted) {
            setState(() {
              _currentLocation = LatLng(pos.latitude, pos.longitude);
              _speedKmh = (pos.speed * 3.6).clamp(0.0, 160.0);
            });

            // Envoi des pings télémétriques au backend si trajet actif
            if (_activeTripId != null) {
              ApiService.instance.post(
                '/api/gps',
                body: {
                  'tripId': _activeTripId,
                  'latitude': pos.latitude,
                  'longitude': pos.longitude,
                  'speed': pos.speed,
                  'heading': pos.heading,
                },
                idempotent: false,
              );
            }
          }
        });
      }
    } catch (_) {
      // Coordonnées par défaut nominales conservées en cas d'absence de signal intérieur
    }
  }

  Future<void> _loadDashboardData() async {
    final userId = widget.user['id'] as String;

    try {
      if (!isDriver) {
        final ridesData = await ApiService.instance.get('/api/rides');
        final reservationsData = await ApiService.instance.get('/api/reservations?passengerId=$userId');

        if (mounted) {
          setState(() {
            _availableRides = ridesData['rides'] as List<dynamic>? ?? [];
            _userReservations = reservationsData['reservations'] as List<dynamic>? ?? [];

            final active = _userReservations.firstWhere(
              (r) => r['status'] == 'ACTIVE',
              orElse: () => null,
            );
            _activeTripId = active?['trip']?['id'] as String?;
          });
        }
      } else {
        final reservationsData = await ApiService.instance.get('/api/reservations?driverId=$userId');
        if (mounted) {
          setState(() {
            _driverReservations = reservationsData['reservations'] as List<dynamic>? ?? [];
            final active = _driverReservations.firstWhere(
              (r) => r['status'] == 'ACTIVE',
              orElse: () => null,
            );
            _activeTripId = active?['trip']?['id'] as String?;
          });
        }
      }
    } catch (_) {}
  }

  void _toggleDeadManSwitch(bool active) {
    setState(() {
      _isDeadManActive = active;
      if (active) {
        _deadManTimeLeft = 60;
        _deadManTimer?.cancel();
        _deadManTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_deadManTimeLeft <= 1) {
            timer.cancel();
            _triggerSosAlert();
          } else {
            setState(() => _deadManTimeLeft--);
          }
        });
      } else {
        _deadManTimer?.cancel();
      }
    });
  }

  void _resetDeadManTimer() {
    setState(() => _deadManTimeLeft = 60);
  }

  Future<void> _triggerSosAlert() async {
    final userId = widget.user['id'] as String;

    try {
      final res = await ApiService.instance.post(
        '/api/alerts',
        body: {
          'tripId': _activeTripId,
          'userId': userId,
          'reason': 'DECLENCHEMENT_MANUEL_SOS',
          'latitude': _currentLocation.latitude,
          'longitude': _currentLocation.longitude,
        },
      );

      final seal = res['integritySealSha256'] as String? ?? 'SHA256_SEAL_RECORD';
      final report = res['reportMarkdown'] as String?;

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => IncidentReportDialog(
            integritySeal: seal,
            reportMarkdown: report,
            reason: 'DECLENCHEMENT_MANUEL_SOS',
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _bookRide(String rideId) async {
    final userId = widget.user['id'] as String;

    try {
      await ApiService.instance.post(
        '/api/reservations',
        body: {
          'rideId': rideId,
          'passengerId': userId,
          'startLat': _currentLocation.latitude,
          'startLng': _currentLocation.longitude,
          'endLat': 48.8049,
          'endLng': 2.1204,
        },
      );

      HapticFeedback.mediumImpact();
      await _loadDashboardData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTokens.danger,
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  Future<void> _acceptReservation(String reservationId) async {
    final userId = widget.user['id'] as String;

    try {
      await ApiService.instance.patch(
        '/api/reservations',
        body: {
          'reservationId': reservationId,
          'driverId': userId,
          'action': 'accept',
        },
      );

      HapticFeedback.mediumImpact();
      await _loadDashboardData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTokens.danger,
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  void _recenterMap() {
    HapticFeedback.lightImpact();
    _mapController.move(_currentLocation, 14.8);
  }

  void _openPublishRideSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PublishRideSheet(
        driverId: widget.user['id'] as String,
        onRidePublished: _loadDashboardData,
      ),
    );
  }

  void _openTrustedContactsSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TrustedContactsSheet(),
    );
  }

  Future<void> _stopTrip() async {
    if (_activeTripId == null) return;

    try {
      await ApiService.instance.patch(
        '/api/trips/$_activeTripId',
        body: {'status': 'COMPLETED'},
      );

      setState(() {
        _activeTripId = null;
        _isDeadManActive = false;
      });
      await _loadDashboardData();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.user['name'] ?? widget.user['email'] ?? 'Utilisateur';

    return Scaffold(
      backgroundColor: AppTokens.background,
      body: Stack(
        children: [
          // 1. Carte Flutter Map-First occupant 100% du fond
          Positioned.fill(
            child: SafeRideMapView(
              mapController: _mapController,
              currentPosition: _currentLocation,
              speedKmh: _speedKmh,
              isDeviated: _isDeviated,
              routePoints: const [
                LatLng(48.8443, 2.3744),
                LatLng(48.8530, 2.3364),
                LatLng(48.8584, 2.2945),
                LatLng(48.8350, 2.2250),
                LatLng(48.8049, 2.1204),
              ],
            ),
          ),

          // 2. HUD Profil Flottant Supérieur
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: AppTokens.spacingMd,
            right: AppTokens.spacingMd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTokens.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(color: AppTokens.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SafeRideCarLogo(size: 26, showGlow: false),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDriver ? AppTokens.successMuted : AppTokens.primaryMuted,
                          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                        ),
                        child: Text(
                          isDriver ? 'CONDUCTEUR' : 'PASSAGER',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isDriver ? AppTokens.success : AppTokens.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _openTrustedContactsSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: AppTokens.primaryMuted,
                            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                            border: Border.all(
                              color: AppTokens.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.contact_phone_rounded, color: AppTokens.primary, size: 13),
                              SizedBox(width: 4),
                              Text(
                                'Confiance',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTokens.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onLogout,
                        child: const Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTokens.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bouton Recentrer Position GPS
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.20,
            right: AppTokens.spacingLg,
            child: FloatingActionButton.small(
              heroTag: 'recenter_gps_fab',
              onPressed: _recenterMap,
              backgroundColor: AppTokens.surface,
              foregroundColor: AppTokens.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                side: const BorderSide(color: AppTokens.borderActive),
              ),
              child: const Icon(Icons.my_location_rounded, size: 20),
            ),
          ),

          // 3. Bottom Sheet Gestuelle Élastique avec 3 Crans Naturels (Thumb Zone)
          DraggableScrollableSheet(
            initialChildSize: 0.48,
            minChildSize: 0.18,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.18, 0.48, 0.88],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppTokens.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusXl)),
                  border: Border(top: BorderSide(color: AppTokens.border)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppTokens.spacingLg),
                  children: [
                    // Poignée gestuelle centrale
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppTokens.spacingMd),
                        decoration: BoxDecoration(
                          color: AppTokens.border,
                          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                        ),
                      ),
                    ),
                    if (isDriver) _buildDriverView() else _buildPassengerView(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerView() {
    final activeReservation = _userReservations.firstWhere(
      (r) => r['status'] == 'PENDING' || r['status'] == 'CONFIRMED' || r['status'] == 'ACTIVE',
      orElse: () => null,
    );

    if (_activeTripId != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'SURVEILLANCE DE TRAJET ACTIVE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTokens.primary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Trajet en cours de sécurisation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTokens.textPrimary),
          ),
          const SizedBox(height: AppTokens.spacingMd),

          DeadManHUDWidget(
            isActive: _isDeadManActive,
            timeLeft: _deadManTimeLeft,
            onToggle: _toggleDeadManSwitch,
            onAcknowledge: _resetDeadManTimer,
          ),
          const SizedBox(height: AppTokens.spacingLg),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: HoldToSosButton(onTrigger: _triggerSosAlert),
              ),
              const SizedBox(width: AppTokens.spacingMd),
              Expanded(
                child: OutlinedButton(
                  onPressed: _stopTrip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTokens.textPrimary,
                    side: const BorderSide(color: AppTokens.border),
                    minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                  ),
                  child: const Text('Arriver'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (activeReservation != null) {
      final pin = activeReservation['verificationCode'] as String? ?? '----';
      final status = activeReservation['status'] as String;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            status == 'PENDING' ? 'EN ATTENTE DU CONDUCTEUR' : 'RÉSERVATION CONFIRMÉE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: status == 'PENDING' ? AppTokens.warning : AppTokens.success,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status == 'PENDING' ? 'Demande envoyée' : 'Votre Code de Sécurité Passager',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTokens.textPrimary),
          ),
          const SizedBox(height: AppTokens.spacingMd),

          if (status == 'CONFIRMED') ...[
            Container(
              padding: const EdgeInsets.all(AppTokens.spacingLg),
              decoration: BoxDecoration(
                color: AppTokens.surfaceInset,
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                border: Border.all(color: AppTokens.border),
              ),
              child: Column(
                children: [
                  const Text(
                    'Communiquez ce code au conducteur au moment de monter à bord :',
                    style: TextStyle(fontSize: 12, color: AppTokens.textSecondary),
                  ),
                  const SizedBox(height: AppTokens.spacingMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pin.split('').map((char) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 52,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTokens.surface,
                          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                          border: Border.all(color: AppTokens.primary, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          char,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTokens.textPrimary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'OFFRES DISPONIBLES',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTokens.primary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sélectionnez votre trajet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTokens.textPrimary),
        ),
        const SizedBox(height: AppTokens.spacingLg),

        if (_availableRides.isEmpty)
          const Text(
            'Aucun trajet disponible actuellement. Les nouveaux départs apparaîtront en temps réel.',
            style: TextStyle(color: AppTokens.textSecondary, fontSize: 13),
          )
        else
          ..._availableRides.map((ride) {
            final origin = ride['originLabel'] ?? 'Paris - Gare de Lyon';
            final destination = ride['destinationLabel'] ?? 'Campus de Versailles';
            final driverName = ride['driver']?['name'] ?? 'Sophie Martin';
            final depRaw = ride['departureTime'] as String?;
            final depTime = depRaw != null ? depRaw.substring(11, 16) : '18:30';

            return RideTicketCard(
              origin: origin,
              destination: destination,
              driverName: driverName,
              departureTime: depTime,
              onBook: () => _bookRide(ride['id'] as String),
            );
          }),
      ],
    );
  }

  Widget _buildDriverView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'VOS TRAJETS CONDUCTEUR',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTokens.primary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Espace Conducteur',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTokens.textPrimary),
        ),
        const SizedBox(height: AppTokens.spacingLg),

        ElevatedButton.icon(
          onPressed: _openPublishRideSheet,
          icon: const Icon(Icons.add_road_rounded),
          label: const Text('Publier un Nouveau Trajet Sécurisé ➔'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTokens.primary,
            foregroundColor: AppTokens.white,
            minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
          ),
        ),
        const SizedBox(height: AppTokens.spacingXl),

        const Text(
          'Demandes Passagers Reçues',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTokens.textPrimary),
        ),
        const SizedBox(height: AppTokens.spacingSm),

        if (_driverReservations.isEmpty)
          const Text(
            'Aucune réservation en attente pour le moment.',
            style: TextStyle(color: AppTokens.textSecondary, fontSize: 13),
          )
        else
          ..._driverReservations.map((res) {
            final passengerName = res['passenger']?['name'] ?? 'Passager';
            final status = res['status'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: AppTokens.spacingMd),
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              decoration: BoxDecoration(
                color: AppTokens.surfaceInset,
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                border: Border.all(color: AppTokens.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        passengerName,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppTokens.textPrimary),
                      ),
                      Text(
                        status == 'CONFIRMED' ? 'Accepté' : 'En attente',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: status == 'CONFIRMED' ? AppTokens.success : AppTokens.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.spacingMd),
                  if (status == 'PENDING')
                    ElevatedButton(
                      onPressed: () => _acceptReservation(res['id'] as String),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.primary,
                        foregroundColor: AppTokens.white,
                      ),
                      child: const Text('Accepter la Demande'),
                    )
                  else if (status == 'CONFIRMED')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DriverVerifyScreen(
                              reservation: res as Map<String, dynamic>,
                              driverId: widget.user['id'] as String,
                              onVerificationSuccess: _loadDashboardData,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.success,
                        foregroundColor: AppTokens.white,
                      ),
                      child: const Text('Valider le Code PIN Passager ➔'),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
