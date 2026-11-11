import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saferide_mobile/core/network/api_service.dart';
import 'package:saferide_mobile/core/theme/app_tokens.dart';

/// Bottom Sheet moderne pour la publication d'un trajet par le conducteur
class PublishRideSheet extends StatefulWidget {
  final String driverId;
  final VoidCallback onRidePublished;

  const PublishRideSheet({
    super.key,
    required this.driverId,
    required this.onRidePublished,
  });

  @override
  State<PublishRideSheet> createState() => _PublishRideSheetState();
}

class _PublishRideSheetState extends State<PublishRideSheet> {
  final _originController = TextEditingController(text: 'Paris - Gare de Lyon');
  final _destinationController = TextEditingController(text: 'Campus de Versailles');
  
  double _startLat = 48.8443;
  double _startLng = 2.3744;
  double _endLat = 48.8049;
  double _endLng = 2.1204;

  int _departureMinutesAhead = 30;
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _popularPresets = [
    {
      'name': 'Gare de Lyon ➔ Versailles',
      'origin': 'Paris - Gare de Lyon',
      'dest': 'Campus de Versailles',
      'startLat': 48.8443,
      'startLng': 2.3744,
      'endLat': 48.8049,
      'endLng': 2.1204,
    },
    {
      'name': 'La Défense ➔ Roissy CDG',
      'origin': 'Paris - La Défense',
      'dest': 'Aéroport Roissy CDG',
      'startLat': 48.8924,
      'startLng': 2.2361,
      'endLat': 49.0097,
      'endLng': 2.5479,
    },
    {
      'name': 'Châtelet ➔ Aéroport d\'Orly',
      'origin': 'Paris - Châtelet',
      'dest': 'Aéroport Paris-Orly',
      'startLat': 48.8584,
      'startLng': 2.3470,
      'endLat': 48.7262,
      'endLng': 2.3652,
    },
    {
      'name': 'Porte Maillot ➔ Campus Saclay',
      'origin': 'Paris - Porte Maillot',
      'dest': 'Campus Paris-Saclay',
      'startLat': 48.8785,
      'startLng': 2.2828,
      'endLat': 48.7088,
      'endLng': 2.1645,
    },
  ];

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, dynamic> preset) {
    HapticFeedback.selectionClick();
    setState(() {
      _originController.text = preset['origin'] as String;
      _destinationController.text = preset['dest'] as String;
      _startLat = preset['startLat'] as double;
      _startLng = preset['startLng'] as double;
      _endLat = preset['endLat'] as double;
      _endLng = preset['endLng'] as double;
    });
  }

  Future<void> _handlePublish() async {
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();

    if (origin.isEmpty || destination.isEmpty) {
      setState(() => _errorMessage = 'Veuillez préciser le départ et la destination.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final departureTime = DateTime.now().add(Duration(minutes: _departureMinutesAhead));

    try {
      await ApiService.instance.post(
        '/api/rides',
        body: {
          'driverId': widget.driverId,
          'originLabel': origin,
          'destinationLabel': destination,
          'startLat': _startLat,
          'startLng': _startLng,
          'endLat': _endLat,
          'endLng': _endLng,
          'departureTime': departureTime.toIso8601String(),
        },
      );

      HapticFeedback.heavyImpact();
      widget.onRidePublished();
      if (mounted) Navigator.of(context).pop();
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTokens.spacingLg,
        AppTokens.spacingMd,
        AppTokens.spacingLg,
        AppTokens.spacingXl + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusXl)),
        border: Border(
          top: BorderSide(color: AppTokens.borderActive, width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
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
                  child: const Icon(Icons.add_road_rounded, color: AppTokens.primary, size: 20),
                ),
                const SizedBox(width: AppTokens.spacingSm),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PUBLIER UN NOUVEAU TRAJET',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppTokens.primary,
                        ),
                      ),
                      Text(
                        'Espace Conducteur',
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
            const SizedBox(height: AppTokens.spacingLg),

            // Suggestions de Trajets Rapides
            const Text(
              'ITINÉRAIRES FRÉQUENTS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTokens.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _popularPresets.map((preset) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      onPressed: () => _applyPreset(preset),
                      backgroundColor: AppTokens.surfaceInset,
                      side: const BorderSide(color: AppTokens.border),
                      label: Text(
                        preset['name'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppTokens.spacingLg),

            // Champ Départ
            TextField(
              controller: _originController,
              style: const TextStyle(color: AppTokens.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Point de Départ',
                labelStyle: const TextStyle(color: AppTokens.textSecondary, fontSize: 12),
                prefixIcon: const Icon(Icons.trip_origin_rounded, color: AppTokens.success, size: 18),
                filled: true,
                fillColor: AppTokens.surfaceInset,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  borderSide: const BorderSide(color: AppTokens.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  borderSide: const BorderSide(color: AppTokens.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  borderSide: const BorderSide(color: AppTokens.primary),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.spacingMd),

            // Champ Destination
            TextField(
              controller: _destinationController,
              style: const TextStyle(color: AppTokens.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Destination Finale',
                labelStyle: const TextStyle(color: AppTokens.textSecondary, fontSize: 12),
                prefixIcon: const Icon(Icons.location_on_rounded, color: AppTokens.danger, size: 18),
                filled: true,
                fillColor: AppTokens.surfaceInset,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  borderSide: const BorderSide(color: AppTokens.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  borderSide: const BorderSide(color: AppTokens.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  borderSide: const BorderSide(color: AppTokens.primary),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.spacingLg),

            // Sélecteur d'Heure de Départ
            const Text(
              'DÉPART PRÉVU',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTokens.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppTokens.spacingSm),
            Row(
              children: [
                _buildTimeChoiceChip(15, '+15 min'),
                const SizedBox(width: 8),
                _buildTimeChoiceChip(30, '+30 min'),
                const SizedBox(width: 8),
                _buildTimeChoiceChip(60, '+1 heure'),
                const SizedBox(width: 8),
                _buildTimeChoiceChip(120, '+2 heures'),
              ],
            ),
            const SizedBox(height: AppTokens.spacingLg),

            // Badge de Garantie Zéro-Vulnérabilité
            Container(
              padding: const EdgeInsets.all(AppTokens.spacingSm),
              decoration: BoxDecoration(
                color: AppTokens.primaryMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(color: AppTokens.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded, color: AppTokens.primary, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chaque réservation est protégée par un code secret unique pour vous assurer de prendre le bon passager.',
                      style: TextStyle(fontSize: 11, color: AppTokens.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: AppTokens.spacingMd),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppTokens.danger, fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: AppTokens.spacingLg),

            // Bouton de Soumission
            ElevatedButton(
              onPressed: _isLoading ? null : _handlePublish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.primary,
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
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTokens.white),
                    )
                  : const Text(
                      'Publier ce Trajet Sécurisé ➔',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChoiceChip(int minutes, String label) {
    final isSelected = _departureMinutesAhead == minutes;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _departureMinutesAhead = minutes);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTokens.primary : AppTokens.surfaceInset,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(
              color: isSelected ? AppTokens.primary : AppTokens.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppTokens.white : AppTokens.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

