import 'package:flutter/material.dart';
import 'dart:math' as math;

class ParticlePainter extends CustomPainter {
  final double animation;

  static final Paint _paint = Paint()..style = PaintingStyle.fill;

  ParticlePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final animationRad = animation * 2 * math.pi;

    for (int i = 0; i < 25; i++) {
      final angle = (i * 14.4 + animation * 360) * math.pi / 180;
      final radius = 120.0 + (i * 18.0);
      final opacity = (math.sin(animationRad + i) + 1) * 0.5;

      _paint.color = Colors.deepPurpleAccent.withValues(alpha: opacity * 0.12);

      canvas.drawCircle(
        Offset(
          centerX + radius * math.cos(angle),
          centerY + radius * math.sin(angle),
        ),
        2.5 + (opacity * 1.5),
        _paint,
      );

      if (i.isEven) {
        final innerRadius = 80.0 + (i * 10.0);
        final innerAngle = (angle + math.pi);

        _paint.color = Colors.purpleAccent.withValues(alpha: opacity * 0.08);

        canvas.drawCircle(
          Offset(
            centerX + innerRadius * math.cos(innerAngle),
            centerY + innerRadius * math.sin(innerAngle),
          ),
          2.0 + opacity,
          _paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      oldDelegate.animation != animation;
}