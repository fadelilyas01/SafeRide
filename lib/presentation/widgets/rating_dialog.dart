import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/glass_card.dart';
import '../../core/theme/app_colors.dart';

class RatingDialog extends StatefulWidget {
  final String driverName;
  final Function(double rating, String comment) onSubmitted;

  const RatingDialog({
    super.key, 
    required this.driverName, 
    required this.onSubmitted,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.accent, size: 64),
            const SizedBox(height: 16),
            Text(
              'Comment était votre trajet ?',
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: 22, 
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Notez votre chauffeur ${widget.driverName}',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildRatingStars(),
            const SizedBox(height: 32),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Laissez un commentaire (optionnel)...',
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating == 0 ? null : () {
                  HapticFeedback.mediumImpact();
                  widget.onSubmitted(_rating, _commentController.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                child: const Text('ENVOYER L\'AVIS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _rating = index + 1.0);
          },
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: index < _rating ? Colors.amber : Colors.grey.withValues(alpha: 0.5),
            size: 40,
          ),
        );
      }),
    );
  }
}
