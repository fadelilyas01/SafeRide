import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  /// Récupère le profil de l'utilisateur actuel
  Future<UserModel?> getProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  /// Met à jour le profil (ex: toggle Women Safe, nom, etc.)
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('profiles').update(updates).eq('id', userId);
  }

  /// (Simulé) Upload de document KYC
  Future<void> uploadKycDocument() async {
    // Dans une vraie app, on utiliserait supabase.storage
    // Ici on simule l'envoi et on marque le profil comme "en attente de vérification"
    await updateProfile({'is_kyc_verified': false}); // En attente
  }
}
