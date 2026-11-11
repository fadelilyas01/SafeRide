import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:saferide_mobile/core/theme/app_tokens.dart';

/// Véritable Logo Vectoriel Automobile SafeRide
/// Rendu GPU 60/120 FPS natif via CustomPainter — Zéro icône générique
class SafeRideCarLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool animate;

  const SafeRideCarLogo({
    super.key,
    this.size = 80.0,
    this.showGlow = true,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTokens.surface,
        border: Border.all(
          color: AppTokens.primary.withValues(alpha: 0.5),
          width: 2.0,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppTokens.primary.withValues(alpha: 0.35),
                  blurRadius: size * 0.3,
                  spreadRadius: 2.0,
                ),
                BoxShadow(
                  color: AppTokens.surfaceInset,
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(size * 0.16),
      child: CustomPaint(
        painter: _CarVectorPainter(),
        size: Size.square(size * 0.68),
      ),
    );
  }
}

/// En-tête de Marque Complète : Logo Automobile + Typographie Stylisée
class SafeRideBrandHeader extends StatelessWidget {
  final double logoSize;

  const SafeRideBrandHeader({
    super.key,
    this.logoSize = 88.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SafeRideCarLogo(size: logoSize),
        const SizedBox(height: AppTokens.spacingMd),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Safe',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppTokens.textPrimary,
                  letterSpacing: -0.8,
                ),
              ),
              TextSpan(
                text: 'Ride',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppTokens.primary,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTokens.surfaceInset,
            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            border: Border.all(color: AppTokens.border),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_car_filled_rounded, size: 12, color: AppTokens.primary),
              SizedBox(width: 6),
              Text(
                'MOBILITÉ CONNECTÉE & SÉCURISÉE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Painter vectoriel précis traçant la silhouette aérodynamique d'un véhicule connecté
class _CarVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Échelle basée sur un canevas canonique 100x100
    final scaleX = w / 100.0;
    final scaleY = h / 100.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // 1. Onde de télémétrie au sol (route connectée)
    final roadPaint = Paint()
      ..color = AppTokens.primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final roadPath = Path();
    roadPath.moveTo(4, 78);
    roadPath.lineTo(96, 78);
    canvas.drawPath(roadPath, roadPaint);

    final roadPulsePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, AppTokens.primary, Colors.transparent],
      ).createShader(const Rect.fromLTWH(20, 76, 60, 4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final roadPulsePath = Path();
    roadPulsePath.moveTo(25, 78);
    roadPulsePath.lineTo(75, 78);
    canvas.drawPath(roadPulsePath, roadPulsePaint);

    // 2. Carrosserie Principale (Silhouette de Berline Sportive Électrique)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF818CF8), // Cyan / Indigo clair
          AppTokens.primary, // Indigo pur
          Color(0xFF3730A3), // Indigo profond
        ],
      ).createShader(const Rect.fromLTWH(0, 20, 100, 60))
      ..style = PaintingStyle.fill;

    final bodyPath = Path();

    // Point de départ : Pare-choc arrière bas
    bodyPath.moveTo(10, 66);

    // Arrière et coffre fastback
    bodyPath.cubicTo(8, 62, 10, 50, 18, 46); // Aile arrière
    bodyPath.cubicTo(24, 43, 30, 40, 36, 32); // Montant C / Lunette arrière

    // Pavillon / Toit aérodynamique
    bodyPath.cubicTo(45, 24, 58, 24, 66, 27); // Toit galbé
    bodyPath.cubicTo(74, 30, 80, 40, 86, 47); // Pare-brise avant incliné

    // Capot plongeant et calandre avant
    bodyPath.cubicTo(90, 50, 94, 54, 95, 60); // Nez profilé
    bodyPath.cubicTo(96, 64, 94, 67, 90, 67); // Pare-choc avant bas

    // Passage de roue avant (découpe pour la roue avant)
    bodyPath.lineTo(82, 67);
    bodyPath.arcToPoint(
      const Offset(62, 67),
      radius: const Radius.circular(10),
      clockwise: false,
    );

    // Bas de caisse latéral
    bodyPath.lineTo(38, 67);

    // Passage de roue arrière (découpe pour la roue arrière)
    bodyPath.arcToPoint(
      const Offset(18, 67),
      radius: const Radius.circular(10),
      clockwise: false,
    );

    bodyPath.lineTo(10, 67);
    bodyPath.close();

    canvas.drawPath(bodyPath, bodyPaint);

    // 3. Vitrage Aérodynamique (Cockpit teinté avec reflets)
    final windowPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0F172A),
          Color(0xFF1E293B),
        ],
      ).createShader(const Rect.fromLTWH(30, 28, 50, 22))
      ..style = PaintingStyle.fill;

    final windowPath = Path();
    windowPath.moveTo(38, 44);
    windowPath.cubicTo(40, 35, 45, 30, 52, 28); // Vitre arrière
    windowPath.lineTo(65, 29); // Pavillon
    windowPath.cubicTo(71, 32, 76, 38, 80, 44); // Pare-brise
    windowPath.lineTo(62, 44); // Montant B central
    windowPath.lineTo(38, 44);
    windowPath.close();

    canvas.drawPath(windowPath, windowPaint);

    // Montant B central fin
    final pillarPaint = Paint()
      ..color = AppTokens.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(60, 29), const Offset(59, 44), pillarPaint);

    // 4. Signature Lumineuse LED Avant (Phare Cyberpunk Cyan)
    final headlightPaint = Paint()
      ..color = const Color(0xFF38BDF8) // Bleu ciel lumineux
      ..style = PaintingStyle.fill;

    final headlightPath = Path();
    headlightPath.moveTo(90, 57);
    headlightPath.lineTo(95, 59);
    headlightPath.lineTo(88, 61);
    headlightPath.close();
    canvas.drawPath(headlightPath, headlightPaint);

    // Feu arrière rouge sécurisé
    final taillightPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    final taillightPath = Path();
    taillightPath.moveTo(10, 52);
    taillightPath.lineTo(15, 53);
    taillightPath.lineTo(11, 57);
    taillightPath.close();
    canvas.drawPath(taillightPath, taillightPaint);

    // 5. Roues Stylisées avec Jantes Alliage et Écrous Centraux
    _drawWheel(canvas, const Offset(28, 67), 8.5);
    _drawWheel(canvas, const Offset(72, 67), 8.5);

    canvas.restore();
  }

  void _drawWheel(Canvas canvas, Offset center, double radius) {
    // Pneu en caoutchouc sombre
    final tirePaint = Paint()
      ..color = const Color(0xFF0B0F19)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, tirePaint);

    // Jante extérieure brillante
    final rimPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(center, radius - 1.0, rimPaint);

    // Disque / Moyeu central avec lueur primaire
    final hubPaint = Paint()
      ..color = AppTokens.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.42, hubPaint);

    // Rayons de jante (4 bâtons sportifs)
    final spokePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + (math.pi / 4);
      final dx = math.cos(angle) * (radius - 2);
      final dy = math.sin(angle) * (radius - 2);
      canvas.drawLine(center, Offset(center.dx + dx, center.dy + dy), spokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

