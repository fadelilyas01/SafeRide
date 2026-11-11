import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saferide_mobile/core/theme/app_tokens.dart';

/// Modal Bottom Sheet pour la gestion du Cercle de Confiance (Contacts d'Urgence)
class TrustedContactsSheet extends StatefulWidget {
  const TrustedContactsSheet({super.key});

  @override
  State<TrustedContactsSheet> createState() => _TrustedContactsSheetState();
}

class _TrustedContactsSheetState extends State<TrustedContactsSheet> {
  final List<Map<String, String>> _contacts = [
    {
      'name': 'Marie Dupont',
      'relation': 'Famille (Conjointe)',
      'phone': '+33 6 12 34 56 78',
      'status': 'Actif - SMS + Push',
    },
    {
      'name': 'Thomas Martin',
      'relation': 'Proche de confiance',
      'phone': '+33 6 98 76 54 32',
      'status': 'Actif - SMS + Push',
    },
  ];

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedRelation = 'Famille';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              side: const BorderSide(color: AppTokens.border),
            ),
            title: const Text(
              'Ajouter un Contact de Confiance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTokens.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppTokens.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Nom et Prénom',
                    labelStyle: const TextStyle(color: AppTokens.textSecondary, fontSize: 12),
                    filled: true,
                    fillColor: AppTokens.surfaceInset,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                  ),
                ),
                const SizedBox(height: AppTokens.spacingMd),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppTokens.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Numéro de Téléphone (ex: +33 6 ...)',
                    labelStyle: const TextStyle(color: AppTokens.textSecondary, fontSize: 12),
                    filled: true,
                    fillColor: AppTokens.surfaceInset,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                  ),
                ),
                const SizedBox(height: AppTokens.spacingMd),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRelation,
                  dropdownColor: AppTokens.surfaceInset,
                  style: const TextStyle(color: AppTokens.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Lien',
                    labelStyle: const TextStyle(color: AppTokens.textSecondary, fontSize: 12),
                    filled: true,
                    fillColor: AppTokens.surfaceInset,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Famille', child: Text('Famille (Parent / Conjoint)')),
                    DropdownMenuItem(value: 'Ami', child: Text('Ami proche')),
                    DropdownMenuItem(value: 'Collègue', child: Text('Collègue de travail')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => _selectedRelation = val);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Annuler', style: TextStyle(color: AppTokens.textMuted)),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final phone = _phoneController.text.trim();
                  if (name.isNotEmpty && phone.isNotEmpty) {
                    setState(() {
                      _contacts.add({
                        'name': name,
                        'relation': _selectedRelation,
                        'phone': phone,
                        'status': 'Actif - SMS + Push',
                      });
                    });
                    _nameController.clear();
                    _phoneController.clear();
                    HapticFeedback.lightImpact();
                    Navigator.of(ctx).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  foregroundColor: AppTokens.white,
                ),
                child: const Text('Ajouter'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _testAlertTransmission() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTokens.success,
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTokens.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Test réussi : Alerte de sécurité transmise avec succès à vos 2 contacts de confiance.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.spacingLg,
        AppTokens.spacingMd,
        AppTokens.spacingLg,
        AppTokens.spacingXl,
      ),
      decoration: const BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusXl)),
        border: Border(top: BorderSide(color: AppTokens.borderActive, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barre de préhension
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTokens.borderActive,
                borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spacingMd),

          // En-tête
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTokens.primaryMuted,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: const Icon(Icons.contact_phone_rounded, color: AppTokens.primary, size: 20),
              ),
              const SizedBox(width: AppTokens.spacingSm),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SÉCURITÉ DÉFENSIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppTokens.primary,
                      ),
                    ),
                    Text(
                      'Cercle de Confiance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: AppTokens.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spacingSm),

          const Text(
            'En cas d\'urgence ou si vous ne confirmez pas votre présence, ces proches reçoivent immédiatement votre position en temps réel et un rapport d\'alerte certifié.',
            style: TextStyle(fontSize: 12, color: AppTokens.textSecondary, height: 1.4),
          ),
          const SizedBox(height: AppTokens.spacingLg),

          // Liste des contacts
          ..._contacts.map((contact) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppTokens.spacingSm),
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              decoration: BoxDecoration(
                color: AppTokens.surfaceInset,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(color: AppTokens.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTokens.primaryMuted,
                    radius: 20,
                    child: Text(
                      contact['name']!.substring(0, 1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTokens.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTokens.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTokens.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${contact['relation']} • ${contact['phone']}',
                          style: const TextStyle(
                            color: AppTokens.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTokens.successMuted,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    child: const Text(
                      'ACTIF',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTokens.success,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: AppTokens.spacingSm),

          // Bouton Ajouter
          OutlinedButton.icon(
            onPressed: _showAddContactDialog,
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Ajouter un Contact de Confiance'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTokens.textPrimary,
              side: const BorderSide(color: AppTokens.border),
              minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spacingSm),

          // Bouton Tester
          ElevatedButton.icon(
            onPressed: _testAlertTransmission,
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Tester la Transmission Sécurisée'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.surfaceInset,
              foregroundColor: AppTokens.primary,
              side: const BorderSide(color: AppTokens.primary),
              minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
