import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../blocs/location_bloc/location_bloc.dart';
import '../blocs/location_bloc/location_event.dart';
import '../blocs/location_bloc/location_state.dart';
import 'dart:async';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_event.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../widgets/radiant_button.dart';
import '../widgets/route_glow_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  bool _isMapCreated = false;
  late AnimationController _routeAnimationController;
  bool _showRouteSimulation = false;

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(LoadLocationRequested());
    _routeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _routeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBar(),
          _buildBottomPanel(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 160),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: FloatingActionButton(
                onPressed: _centerOnUser,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.my_location, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return BlocConsumer<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is LocationLoaded && _isMapCreated) {
          _updateCameraPosition(state.position.latitude, state.position.longitude);
        }
      },
      builder: (context, state) {
        LatLng initialPosition = const LatLng(45.5017, -73.5673); // Mtl Default
        if (state is LocationLoaded) {
          initialPosition = LatLng(state.position.latitude, state.position.longitude);
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 15,
              ),
              style: _mapStyle,
              onMapCreated: (controller) {
                _mapController.complete(controller);
                setState(() {
                  _isMapCreated = true;
                });
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
            ),
            if (_showRouteSimulation)
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _routeAnimationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: RouteGlowPainter(
                        points: [
                          const Offset(100, 200),
                          const Offset(200, 400),
                          const Offset(300, 300),
                        ],
                        color: AppColors.primary,
                        animationValue: _routeAnimationController.value,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 24,
      right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(builder: (context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            );
          }),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.darkBackground.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/ai-assistant'),
                  child: const Icon(Icons.bolt_rounded, color: Colors.green, size: 20),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.push('/safescore'),
                  child: const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.shield, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'SÉCURISÉ',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(44),
          topRight: Radius.circular(44),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
            decoration: BoxDecoration(
              color: AppColors.darkBackground.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(44),
                topRight: Radius.circular(44),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Où allons-nous ?',
                  style: GoogleFonts.outfit(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'ENTREZ VOTRE DESTINATION',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Search Destination Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _showRouteSimulation = val.isNotEmpty;
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un lieu...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                      icon: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 28),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                RadiantButton(
                  onPressed: () {
                    final state = context.read<LocationBloc>().state;
                    if (state is LocationLoaded) {
                      context.push('/planning', extra: {
                        'pickup': LatLng(state.position.latitude, state.position.longitude)
                      });
                    }
                  },
                  child: const Text('PLANIFIER LE TRAJET'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildDrawer() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = 'Utilisateur SafeRide';
        String email = '';
        if (state is Authenticated) {
          name = state.user.fullName ?? name;
          email = state.user.email;
        }

        return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40)],
          ),
          child: Column(
            children: [
              // Premium Header
              Container(
                height: 280,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.radiantGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                            ),
                            child: const CircleAvatar(
                              radius: 38,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, size: 40, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            name,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            email.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withValues(alpha: 0.6),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildDrawerItem(Icons.person_outline_rounded, 'Profil Utilisateur', () => context.push('/profile')),
                    _buildDrawerItem(Icons.history_rounded, 'Historique de Trajets', () {}),
                    _buildDrawerItem(Icons.account_balance_wallet_outlined, 'Paiements & Cartes', () => context.push('/wallet')),
                    _buildDrawerItem(Icons.security_outlined, 'Sécurité & SOS', () {}),
                    _buildDrawerItem(Icons.help_center_outlined, 'Centre d\'Assistance', () => context.push('/help-support')),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: Colors.white10),
                    ),
                    _buildDrawerItem(Icons.logout_rounded, 'Déconnexion', () {
                      context.read<AuthBloc>().add(SignOutRequested());
                    }, color: AppColors.alert),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'SafeRide v2.4.0 • Premium',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.1),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: color ?? Colors.white.withValues(alpha: 0.6), size: 22),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.white.withValues(alpha: 0.8),
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.1), size: 18),
      ),
    );
  }

  Future<void> _centerOnUser() async {
    final state = context.read<LocationBloc>().state;
    if (state is LocationLoaded) {
      _updateCameraPosition(state.position.latitude, state.position.longitude);
    }
  }

  Future<void> _updateCameraPosition(double lat, double lng) async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15),
      ),
    );
  }

  final String _mapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#0b1120"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#4b5563"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#0b1120"}]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#94a3b8"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#1e293b"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#334155"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#1e1b4b"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#1e1b4b"}]
    }
  ]
  ''';
}
