import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_tokens.dart';

/// Carte Vectorielle Flutter Native Dark Mode (CartoDB Dark Matter)
class SafeRideMapView extends StatefulWidget {
  final LatLng currentPosition;
  final List<LatLng> routePoints;
  final double speedKmh;
  final bool isDeviated;
  final MapController? mapController;

  const SafeRideMapView({
    super.key,
    required this.currentPosition,
    this.routePoints = const [],
    this.speedKmh = 0.0,
    this.isDeviated = false,
    this.mapController,
  });

  @override
  State<SafeRideMapView> createState() => _SafeRideMapViewState();
}

class _SafeRideMapViewState extends State<SafeRideMapView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Carte Native avec Tuiles CartoDB Dark Matter (Optimisée OLED True Dark)
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: widget.currentPosition,
            initialZoom: 13.8,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // Tuiles sombres haute résolution CartoDB Dark
            TileLayer(
              urlTemplate: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.saferide.mobile',
            ),

            // Tracé d'Itinéraire OSRM avec Effet Néon Subtil
            if (widget.routePoints.length >= 2) ...[
              // Halo d'ombre du tracé
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    color: (widget.isDeviated ? AppTokens.danger : AppTokens.primary)
                        .withValues(alpha: 0.25),
                    strokeWidth: 9.0,
                  ),
                ],
              ),
              // Tracé principal
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    color: widget.isDeviated ? AppTokens.danger : AppTokens.primary,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
            ],

            // Marqueur Véhicule avec Halo Pulsant Radar
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.currentPosition,
                  width: 54,
                  height: 54,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + _pulseController.value * 0.45;
                      final opacity = (1.0 - _pulseController.value).clamp(0.0, 1.0);
                      final markerColor = widget.isDeviated ? AppTokens.danger : AppTokens.primary;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Onde radar pulsante
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: markerColor.withValues(alpha: opacity * 0.35),
                                border: Border.all(
                                  color: markerColor.withValues(alpha: opacity * 0.7),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          // Point central solide
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: markerColor,
                              border: Border.all(color: AppTokens.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: markerColor.withValues(alpha: 0.8),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.near_me_rounded,
                                color: AppTokens.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),

        // HUD Télémétrique Flottant Aéronautique (Haut Gauche)
        Positioned(
          top: AppTokens.spacingMd,
          left: AppTokens.spacingMd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppTokens.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              border: Border.all(color: AppTokens.white.withValues(alpha: 0.08)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.speedKmh.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTokens.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'KM/H',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTokens.textMuted,
                  ),
                ),
                Container(
                  width: 1,
                  height: 12,
                  color: AppTokens.border,
                  margin: const EdgeInsets.symmetric(horizontal: AppTokens.spacingSm),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isDeviated ? AppTokens.danger : AppTokens.success,
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isDeviated ? AppTokens.danger : AppTokens.success).withValues(alpha: 0.7),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.isDeviated ? 'ÉCART D\'ITINÉRAIRE' : 'TRAJET CONFORME',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: widget.isDeviated ? AppTokens.danger : AppTokens.success,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
