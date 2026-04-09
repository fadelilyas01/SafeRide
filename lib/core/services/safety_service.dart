import 'package:supabase_flutter/supabase_flutter.dart';

class SafetyService {
  final _supabase = Supabase.instance.client;

  /// Déclenche une alerte SOS en insérant un log d'audit critique
  Future<void> triggerSOS(String rideId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('audit_logs').insert({
      'action': 'SOS_ALERT',
      'target_id': rideId,
      'actor_id': userId,
      'status': 'CRITICAL',
      'details': {
        'message': 'L utilisateur a déclenché une alerte SOS pendant la course.',
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }
}
