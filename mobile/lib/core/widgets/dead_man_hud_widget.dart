import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_tokens.dart';

/// Minuteur de surveillance Dead Man's Switch avec jauge de progression
class DeadManHUDWidget extends StatelessWidget {
  final bool isActive;
  final int timeLeft;
  final int maxTime;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAcknowledge;

  const DeadManHUDWidget({
    super.key,
    required this.isActive,
    required this.timeLeft,
    this.maxTime = 60,
    required this.onToggle,
    required this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (timeLeft / maxTime).clamp(0.0, 1.0);
    final isUrgent = timeLeft <= 10;
    final isWarning = timeLeft <= 20 && !isUrgent;

    final statusColor = isUrgent
        ? AppTokens.danger
        : isWarning
            ? AppTokens.warning
            : AppTokens.success;

    return Container(
      padding: const EdgeInsets.all(AppTokens.spacingMd),
      decoration: BoxDecoration(
        color: AppTokens.surfaceInset,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: AppTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SÉCURITÉ ACTIVE",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppTokens.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Text(
                    "Contrôle de Vigilance",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: isActive,
                onChanged: onToggle,
                activeTrackColor: AppTokens.danger,
                inactiveThumbColor: AppTokens.textSecondary,
                inactiveTrackColor: AppTokens.surface,
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: AppTokens.spacingMd),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppTokens.surface,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: AppTokens.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrgent ? 'Alerte SOS imminente !' : 'Confirmation requise',
                      style: TextStyle(
                        fontSize: 11,
                        color: isUrgent ? AppTokens.danger : AppTokens.textSecondary,
                        fontWeight: isUrgent ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    Text(
                      '00:${timeLeft.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onAcknowledge();
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Je vais bien'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTokens.textPrimary,
                    side: BorderSide(color: statusColor, width: 1.5),
                    backgroundColor: AppTokens.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.spacingLg,
                      vertical: AppTokens.spacingSm,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 4),
            const Text(
              "Envoie une alerte automatique à vos proches si vous ne confirmez pas votre présence.",
              style: TextStyle(
                fontSize: 11,
                color: AppTokens.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

