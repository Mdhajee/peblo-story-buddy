import 'package:flutter/material.dart';
import 'dart:math';

class Star {
  final double x, y, size, opacity;
  Star({required this.x, required this.y, required this.size, required this.opacity});
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;

  StarsPainter() : stars = _generateStars();

  static List<Star> _generateStars() {
    final rng = Random(42);
    return List.generate(30, (i) {
      return Star(
        x: rng.nextDouble(),
        y: rng.nextDouble() * 0.5,
        size: 2.0 + rng.nextDouble() * 4,
        opacity: 0.2 + rng.nextDouble() * 0.4,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: star.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
