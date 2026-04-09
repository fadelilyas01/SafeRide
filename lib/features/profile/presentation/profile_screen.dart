import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.getProfile();
    if (mounted) {
      setState(() {
        _user = profile;
        _isLoading = false;
      });
    }
  }

  void _toggleWomenSafe(bool value) async {
    await _profileService.updateProfile({'is_women_safe': value});
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar & Basic Info
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, size: 50, color: Colors.blueAccent),
                ),
                const SizedBox(height: 16),
                Text(
                  _user?.firstName ?? "Utilisateur",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  _user?.role.name ?? "",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                
                const SizedBox(height: 32),
                
                // Trust Score Card
                _buildCard(
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Score de confiance", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          Text("${_user?.trustScore.toStringAsFixed(1)} / 5.0", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // KYC Status Card
                _buildCard(
                  child: Row(
                    children: [
                      Icon(
                        _user?.isKycVerified == true ? Icons.verified : Icons.error_outline,
                        color: _user?.isKycVerified == true ? Colors.greenAccent : Colors.orangeAccent,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Vérification d identité", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            Text(
                              _user?.isKycVerified == true ? "Compte Vérifié" : "Non vérifié",
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      if (_user?.isKycVerified == false)
                        TextButton(
                          onPressed: () => _profileService.uploadKycDocument().then((_) => _loadProfile()),
                          child: const Text("Vérifier"),
                        )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Women Safe Toggle (Dédié à la sécurité)
                _buildCard(
                  child: SwitchListTile(
                    title: const Text("Option Women Safe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text("N accepte que des trajets entre femmes", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    value: _user?.isWomenSafe ?? false,
                    onChanged: _toggleWomenSafe,
                    activeThumbColor: Colors.pinkAccent,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {}, // Handled by logout in main
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Déconnexion"),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}
