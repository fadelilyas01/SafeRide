import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride_model.dart';

class RideService {
  final _supabase = Supabase.instance.client;

  /// Crée une nouvelle demande de course dans Supabase
  Future<RideModel> createRide(RideModel ride) async {
    final response = await _supabase
        .from('rides')
        .insert(ride.toMap())
        .select()
        .single();

    return RideModel.fromJson(response);
  }

  /// Récupère les détails d'une course par ID
  Future<RideModel?> getRideById(String id) async {
    final response = await _supabase
        .from('rides')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return RideModel.fromJson(response);
  }

  /// Stream les mises à jour d'une course spécifique (pour le passager)
  Stream<RideModel> streamRideStatus(String rideId) {
    return _supabase
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('id', rideId)
        .map((data) => RideModel.fromJson(data.first));
  }

  /// Annule une course
  Future<void> cancelRide(String rideId) async {
    await _supabase
        .from('rides')
        .update({'status': RideStatus.cancelled.name})
        .eq('id', rideId);
  }

  /// (Pour les chauffeurs) Récupère les courses en attente
  Future<List<RideModel>> getAvailableRides() async {
    final response = await _supabase
        .from('rides')
        .select()
        .eq('status', RideStatus.pending.name);

    return (response as List).map((json) => RideModel.fromJson(json)).toList();
  }
}
