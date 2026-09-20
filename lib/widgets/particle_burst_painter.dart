import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ConfettiParticle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;
  final double sway;

  ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.sway,
  });
}

List<ConfettiParticle> generateConfetti({int count = 36, int seed = 42}) {
  final random = Random(seed);
  final colors = [AppColors.amberGold, AppColors.neonMint, AppColors.softSage, Colors.white];
  return List.generate(count, (i) {
    return ConfettiParticle(
      angle: -pi / 2 + (random.nextDouble() - 0.5) * pi * 1.4,
      speed: 120 + random.nextDouble() * 220,
      size: 4 + random.nextDouble() * 5,
      color: colors[random.nextInt(colors.length)],
      rotationSpeed: (random.nextDouble() - 0.5) * 10,
      sway: random.nextDouble() * 2 * pi,
    );
  });
}

/// Golden coin-shower / confetti burst used on the reward popup. Driven by
/// a 0..1 [progress] value representing elapsed animation time.
class ParticleBurstPainter extends CustomPainter {
  final double progress;
  final List<ConfettiParticle> particles;

  ParticleBurstPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset origin = Offset(size.width / 2, size.height * 0.15);
    const double gravity = 260;

    for (final p in particles) {
      final double t = progress;
      final double vx = cos(p.angle) * p.speed;
      final double vy = sin(p.angle) * p.speed;
      final double x = origin.dx + vx * t + sin(t * 6 + p.sway) * 12;
      final double y = origin.dy + vy * t + 0.5 * gravity * t * t;
      final double opacity = (1 - t).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final paint = Paint()..color = p.color.withOpacity(opacity);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * p.rotationSpeed);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ParticleBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
