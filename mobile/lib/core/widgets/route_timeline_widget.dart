import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Timeline d'itinéraire verticale Origine -> Destination
class RouteTimelineWidget extends StatelessWidget {
  final String originLabel;
  final String destinationLabel;
  final String? originCoords;
  final String? destCoords;

  const RouteTimelineWidget({
    super.key,
    required this.originLabel,
    required this.destinationLabel,
    this.originCoords,
    this.destCoords,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rail visuel (Point vert -> Ligne -> Carré bleu)
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4, right: AppTokens.spacingSm),
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppTokens.success,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 28,
                color: AppTokens.border,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppTokens.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),

        // Libellés d'arrêts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'POINT DE DÉPART',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppTokens.success,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                originLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.textPrimary,
                ),
              ),
              if (originCoords != null)
                Text(
                  originCoords!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTokens.textMuted,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              const SizedBox(height: AppTokens.spacingSm),
              Text(
                'DESTINATION',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppTokens.primary,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                destinationLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.textPrimary,
                ),
              ),
              if (destCoords != null)
                Text(
                  destCoords!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTokens.textMuted,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

