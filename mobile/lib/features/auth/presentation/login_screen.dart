import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saferide_mobile/core/network/api_service.dart';
import 'package:saferide_mobile/core/theme/app_tokens.dart';
import 'package:saferide_mobile/core/widgets/safe_ride_logo.dart';

class LoginScreen extends StatefulWidget {
  final void Function(Map<String, dynamic> user) onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController(text: 'passager@saferide.fr');
  final _nameController = TextEditingController(text: 'Passager SafeRide');
  String _selectedRole = 'USER';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Veuillez saisir une adresse email valide.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.instance.post(
        '/api/auth/login',
        body: {
          'email': email,
          'name': _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
          'role': _selectedRole,
        },
      );

      final user = response['user'] as Map<String, dynamic>;
      widget.onLoginSuccess(user);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.background,
      body: Stack(
        children: [
          // Halo de lumière d'ambiance en arrière-plan
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTokens.primary.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacingXl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo Vectoriel Automobile SafeRide & Typographie Stylisée
                      const SafeRideBrandHeader(logoSize: 84.0),
                      const SizedBox(height: AppTokens.spacingXl),

                      // Sélecteur de Rôle Segmenté iOS Pill
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTokens.surfaceInset,
                          borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                          border: Border.all(color: AppTokens.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _selectedRole = 'USER';
                                    _emailController.text = 'passager@saferide.fr';
                                    _nameController.text = 'Passager SafeRide';
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedRole == 'USER'
                                        ? AppTokens.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                                    boxShadow: _selectedRole == 'USER'
                                        ? [
                                            BoxShadow(
                                              color: AppTokens.primary.withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person_outline_rounded,
                                        size: 16,
                                        color: _selectedRole == 'USER' ? AppTokens.white : AppTokens.textMuted,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Passager',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _selectedRole == 'USER' ? AppTokens.white : AppTokens.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _selectedRole = 'DRIVER';
                                    _emailController.text = 'sophie.conductrice@saferide.fr';
                                    _nameController.text = 'Sophie Conductrice';
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedRole == 'DRIVER'
                                        ? AppTokens.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                                    boxShadow: _selectedRole == 'DRIVER'
                                        ? [
                                            BoxShadow(
                                              color: AppTokens.primary.withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions_car_outlined,
                                        size: 16,
                                        color: _selectedRole == 'DRIVER' ? AppTokens.white : AppTokens.textMuted,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Conducteur',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _selectedRole == 'DRIVER' ? AppTokens.white : AppTokens.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTokens.spacingXl),

                      // Carte de Saisie Glassmorphic
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(AppTokens.spacingLg),
                            decoration: BoxDecoration(
                              color: AppTokens.surface.withValues(alpha: 0.78),
                              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                              border: Border.all(
                                color: AppTokens.white.withValues(alpha: 0.08),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Champ Email
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTokens.surfaceInset,
                                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                                    border: Border.all(color: AppTokens.border),
                                  ),
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: AppTokens.textPrimary, fontSize: 14),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.alternate_email_rounded, color: AppTokens.textMuted, size: 20),
                                      hintText: 'adresse@saferide.fr',
                                      hintStyle: TextStyle(color: AppTokens.textMuted, fontSize: 13),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppTokens.spacingMd),

                                // Champ Nom
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTokens.surfaceInset,
                                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                                    border: Border.all(color: AppTokens.border),
                                  ),
                                  child: TextField(
                                    controller: _nameController,
                                    style: const TextStyle(color: AppTokens.textPrimary, fontSize: 14),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.badge_outlined, color: AppTokens.textMuted, size: 20),
                                      hintText: 'Prénom Nom',
                                      hintStyle: TextStyle(color: AppTokens.textMuted, fontSize: 13),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    ),
                                  ),
                                ),

                                if (_errorMessage != null) ...[
                                  const SizedBox(height: AppTokens.spacingMd),
                                  Container(
                                    padding: const EdgeInsets.all(AppTokens.spacingMd),
                                    decoration: BoxDecoration(
                                      color: AppTokens.dangerMuted,
                                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                                      border: Border.all(color: AppTokens.danger),
                                    ),
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: AppTokens.danger, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: AppTokens.spacingLg),

                                // Bouton Primaire avec Dégradé Élégant
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF4F46E5),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTokens.primary.withValues(alpha: 0.4),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: AppTokens.white,
                                      minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: AppTokens.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            _selectedRole == 'DRIVER'
                                                ? 'Accéder à l''Espace Conducteur ➔'
                                                : "Rejoindre l'Espace Passager ➔",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTokens.spacingXl),

                      // Raccourcis Profils de Démonstration Rapides
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _selectedRole = 'USER';
                                _emailController.text = 'passager@saferide.fr';
                                _nameController.text = 'Passager SafeRide';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTokens.surfaceInset,
                                borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                                border: Border.all(color: AppTokens.border),
                              ),
                              child: const Text(
                                '• Démo Passager',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTokens.textSecondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTokens.spacingSm),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _selectedRole = 'DRIVER';
                                _emailController.text = 'sophie.conductrice@saferide.fr';
                                _nameController.text = 'Sophie Conductrice';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTokens.surfaceInset,
                                borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                                border: Border.all(color: AppTokens.border),
                              ),
                              child: const Text(
                                '• Démo Conducteur',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTokens.textSecondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

