import 'package:flutter/material.dart';

class RouteGlowPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final double animationValue;

  RouteGlowPainter({
    required this.points,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Glow effect
    for (int i = 1; i <= 3; i++) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.1 / i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0 * i
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0 * i);
      canvas.drawPath(path, glowPaint);
    }

    // Main line with moving pulse
    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, mainPaint);

    // Pulse dot
    final pulsePaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    // Calculate position along path
    final pathMetrics = path.computeMetrics();
    if (pathMetrics.isNotEmpty) {
      final metric = pathMetrics.first;
      final distance = metric.length * animationValue;
      final pos = metric.getTangentForOffset(distance);
      if (pos != null) {
        canvas.drawCircle(pos.position, 6, pulsePaint);
        canvas.drawCircle(pos.position, 12, Paint()..color = Colors.white.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      }
    }
  }

  @override
  bool shouldRepaint(covariant RouteGlowPainter oldDelegate) => true;
}
