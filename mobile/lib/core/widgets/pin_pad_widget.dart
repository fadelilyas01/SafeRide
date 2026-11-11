import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_tokens.dart';

/// Pavé numérique tactile dédié à la saisie du code PIN à 4 chiffres (Thumb Zone).
class PinPadWidget extends StatelessWidget {
  final String pin;
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;
  final bool disabled;

  const PinPadWidget({
    super.key,
    required this.pin,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 4 Cellules Cryptographiques
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isFilled = index < pin.length;
            final char = isFilled ? pin[index] : '·';

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTokens.spacingSm),
              width: 56,
              height: 64,
              decoration: BoxDecoration(
                color: isFilled ? AppTokens.primaryMuted : AppTokens.surfaceInset,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(
                  color: isFilled ? AppTokens.primary : AppTokens.border,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                char,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isFilled ? AppTokens.textPrimary : AppTokens.textMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppTokens.spacingXl),

        // Pavé tactile (Loi de Fitts)
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            children: [
              _buildRow(['1', '2', '3']),
              const SizedBox(height: AppTokens.spacingMd),
              _buildRow(['4', '5', '6']),
              const SizedBox(height: AppTokens.spacingMd),
              _buildRow(['7', '8', '9']),
              const SizedBox(height: AppTokens.spacingMd),
              _buildRow(['', '0', 'DEL']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 80, height: 52);
        }

        if (key == 'DEL') {
          return SizedBox(
            width: 80,
            height: 52,
            child: TextButton(
              onPressed: disabled || pin.isEmpty
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onDeletePressed();
                    },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
              ),
              child: const Icon(
                Icons.backspace_outlined,
                color: AppTokens.danger,
                size: 22,
              ),
            ),
          );
        }

        return SizedBox(
          width: 80,
          height: 52,
          child: ElevatedButton(
            onPressed: disabled || pin.length >= 4
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onDigitPressed(key);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.surface,
              foregroundColor: AppTokens.textPrimary,
              elevation: 0,
              side: const BorderSide(color: AppTokens.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

