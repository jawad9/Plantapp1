import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Draws the splash screen's ambient seed -> glowing seedling animation
/// plus a burst of drifting particles, all driven by a single 0..1 [progress]
/// value from the splash screen's AnimationController.
class SeedSproutPainter extends CustomPainter {
  final double progress;
  final List<SproutParticle> particles;

  SeedSproutPainter({required this.progress, required this.particles});

  double _clampInterval(double t, double start, double end) {
    if (end <= start) return 0;
    return ((t - start) / (end - start)).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset base = Offset(size.width / 2, size.height * 0.82);

    final double seedPhase = _clampInterval(progress, 0.0, 1.0);
    final double stemPhase = _clampInterval(progress, 0.22, 0.65);
    final double leafPhase = _clampInterval(progress, 0.45, 0.85);
    final double particlePhase = _clampInterval(progress, 0.55, 1.0);

    // Soft ground glow.
    final groundPaint = Paint()
      ..color = AppColors.neonMint.withOpacity(0.08 * seedPhase)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawOval(
      Rect.fromCenter(center: base, width: 140, height: 24),
      groundPaint,
    );

    // Stem.
    if (stemPhase > 0) {
      final double stemLength = 70 * stemPhase;
      final Offset tip = Offset(
        base.dx + sin(stemPhase * pi) * 6,
        base.dy - stemLength,
      );
      final stemPaint = Paint()
        ..color = AppColors.neonMint.withOpacity(0.9)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final stemGlowPaint = Paint()
        ..color = AppColors.neonMint.withOpacity(0.5)
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final path = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
          base.dx + 10,
          base.dy - stemLength * 0.5,
          tip.dx,
          tip.dy,
        );
      canvas.drawPath(path, stemGlowPaint);
      canvas.drawPath(path, stemPaint);

      // Leaves unfurling near the tip.
      if (leafPhase > 0) {
        _drawLeaf(canvas, tip, leafPhase, tilt: -1);
        _drawLeaf(canvas, tip, leafPhase, tilt: 1);
      }
    }

    // Seed glow (fades slightly once fully sprouted but stays as the root glow).
    final double pulse = 1 + sin(progress * 4 * pi) * 0.12 * (1 - stemPhase * 0.6);
    final double seedRadius = 10 * pulse * (0.6 + 0.4 * seedPhase);
    final seedGlow = Paint()
      ..color = AppColors.neonMint.withOpacity(0.55 * seedPhase)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(base, seedRadius * 2.2, seedGlow);
    final seedPaint = Paint()..color = AppColors.neonMint.withOpacity(0.95 * seedPhase);
    canvas.drawCircle(base, seedRadius, seedPaint);

    // Particles drifting outward from the tip once sprouted.
    if (particlePhase > 0) {
      final Offset tip = Offset(base.dx + 10, base.dy - 70);
      for (final particle in particles) {
        final double dist = particle.maxDistance * particlePhase;
        final Offset pos = Offset(
          tip.dx + cos(particle.angle) * dist,
          tip.dy + sin(particle.angle) * dist - (particlePhase * 20),
        );
        final double opacity = (1 - particlePhase) * particle.baseOpacity;
        if (opacity <= 0) continue;
        final particlePaint = Paint()
          ..color = (particle.amber ? AppColors.amberGold : AppColors.neonMint)
              .withOpacity(opacity.clamp(0, 1))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(pos, particle.size, particlePaint);
      }
    }
  }

  void _drawLeaf(Canvas canvas, Offset tip, double phase, {required double tilt}) {
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(tilt * 0.6);
    final double scale = phase.clamp(0.0, 1.0);
    canvas.scale(scale, scale);

    final leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(tilt * 22, -8, tilt * 30, -2)
      ..quadraticBezierTo(tilt * 16, 6, 0, 0)
      ..close();

    final glowPaint = Paint()
      ..color = AppColors.neonMint.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final fillPaint = Paint()..color = AppColors.neonMint.withOpacity(0.85);

    canvas.drawPath(leafPath, glowPaint);
    canvas.drawPath(leafPath, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SeedSproutPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class SproutParticle {
  final double angle;
  final double maxDistance;
  final double size;
  final double baseOpacity;
  final bool amber;

  SproutParticle({
    required this.angle,
    required this.maxDistance,
    required this.size,
    required this.baseOpacity,
    required this.amber,
  });
}

List<SproutParticle> generateSproutParticles({int count = 16, int seed = 7}) {
  final random = Random(seed);
  return List.generate(count, (i) {
    return SproutParticle(
      angle: random.nextDouble() * 2 * pi,
      maxDistance: 30 + random.nextDouble() * 60,
      size: 1.5 + random.nextDouble() * 2.5,
      baseOpacity: 0.5 + random.nextDouble() * 0.5,
      amber: i % 4 == 0,
    );
  });
}
