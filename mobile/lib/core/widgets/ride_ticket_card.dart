import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saferide_mobile/core/theme/app_tokens.dart';
import 'package:saferide_mobile/core/widgets/route_timeline_widget.dart';

/// Carte de trajet style "Billet d'Embarquement / Boarding Pass" haut de gamme.
class RideTicketCard extends StatelessWidget {
  final String origin;
  final String destination;
  final String driverName;
  final String departureTime;
  final VoidCallback onBook;
  final bool isBooking;

  const RideTicketCard({
    super.key,
    required this.origin,
    required this.destination,
    required this.driverName,
    required this.departureTime,
    required this.onBook,
    this.isBooking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTokens.spacingMd),
      decoration: BoxDecoration(
        color: AppTokens.surfaceInset,
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        border: Border.all(
          color: AppTokens.white.withValues(alpha: 0.08),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête : Conducteur & Badge Départ
          Padding(
            padding: const EdgeInsets.all(AppTokens.spacingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTokens.surface,
                        border: Border.all(color: AppTokens.border),
                      ),
                      child: Center(
                        child: Text(
                          driverName.isNotEmpty ? driverName[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTokens.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTokens.spacingSm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTokens.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, size: 12, color: AppTokens.success),
                            const SizedBox(width: 4),
                            Text(
                              'Profil Vérifié • 4.9 ★',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTokens.success.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTokens.surface,
                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                    border: Border.all(color: AppTokens.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 12, color: AppTokens.primary),
                      const SizedBox(width: 4),
                      Text(
                        departureTime,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTokens.textPrimary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ligne de découpe pointillée type Ticket de Transport
          Row(
            children: [
              Container(
                width: 10,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppTokens.surface,
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final count = (constraints.maxWidth / 8).floor();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(count, (_) {
                          return Container(
                            width: 4,
                            height: 1,
                            color: AppTokens.border,
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: 10,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppTokens.surface,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                ),
              ),
            ],
          ),

          // Timeline d'Itinéraire
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacingLg, vertical: AppTokens.spacingSm),
            child: RouteTimelineWidget(
              originLabel: origin,
              destinationLabel: destination,
            ),
          ),

          // Pied de carte : CTA Réserver
          Padding(
            padding: const EdgeInsets.all(AppTokens.spacingMd),
            child: Container(
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
                    color: AppTokens.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isBooking
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        onBook();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppTokens.white,
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                ),
                child: isBooking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: AppTokens.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Réserver ce Trajet Sécurisé ➔',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
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

