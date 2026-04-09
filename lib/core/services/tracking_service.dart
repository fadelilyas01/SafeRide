import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/location_service.dart';

class TrackingService {
  final _supabase = Supabase.instance.client;
  final _locationService = LocationService();
  RealtimeChannel? _channel;
  StreamSubscription<Position>? _positionSubscription;

  /// Initialise le canal temps réel pour la diffusion
  void _initChannel() {
    _channel = _supabase.channel('driverLocation');
    _channel!.subscribe();
  }

  /// Démarre la diffusion de la position (Mode Chauffeur)
  Future<void> startTracking() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    if (_channel == null) {
      _initChannel();
    }

    _positionSubscription = _locationService.locationStream.listen((position) {
      _broadcastLocation(userId, position);
    });
  }

  /// Arrête la diffusion
  void stopTracking() {
    _positionSubscription?.cancel();
    _channel?.unsubscribe();
    _channel = null;
  }

  /// Diffuse la position via le canal Realtime
  void _broadcastLocation(String userId, Position position) {
    if (_channel == null) return;

    // ignore: invalid_use_of_internal_member
    (_channel as dynamic).send(
      type: 'broadcast',
      event: 'location_update',
      payload: {
        'driver_id': userId,
        'lat': position.latitude,
        'lng': position.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }
}
