import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Paints a stylized isometric polyhedral die: three visible faces (top,
/// left, right) with glowing etched leaf-vein patterns, tinted by the
/// player's active skin gradient.
class DicePainter extends CustomPainter {
  final List<Color> skinColors;
  final double glowStrength; // 0..1, pulses while idle, spikes on settle
  final IconData? faceIcon;

  DicePainter({
    required this.skinColors,
    this.glowStrength = 0.5,
    this.faceIcon,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double s = min(size.width, size.height);
    final Offset center = Offset(size.width / 2, size.height / 2);

    final double topW = s * 0.42;
    final double sideH = s * 0.36;

    final Offset top = center + Offset(0, -sideH * 0.55);
    final Offset left = center + Offset(-topW, sideH * 0.15);
    final Offset right = center + Offset(topW, sideH * 0.15);
    final Offset bottom = center + Offset(0, sideH * 0.85);

    final Color base = skinColors.first;
    final Color accent = skinColors.last;

    // Outer glow.
    final glowPaint = Paint()
      ..color = accent.withOpacity(0.35 * glowStrength)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 + 10 * glowStrength);
    canvas.drawCircle(center, s * 0.5, glowPaint);

    // Top face (lightest).
    final topFace = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(center.dx, center.dy + sideH * 0.15)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(
      topFace,
      Paint()..shader = LinearGradient(
        colors: [accent.withOpacity(0.85), base],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(topFace.getBounds()),
    );

    // Left face.
    final leftFace = Path()
      ..moveTo(left.dx, left.dy)
      ..lineTo(center.dx, center.dy + sideH * 0.15)
      ..lineTo(center.dx, bottom.dy)
      ..lineTo(left.dx, left.dy + sideH * 0.7)
      ..close();
    canvas.drawPath(
      leftFace,
      Paint()..color = Color.lerp(base, Colors.black, 0.35)!,
    );

    // Right face.
    final rightFace = Path()
      ..moveTo(right.dx, right.dy)
      ..lineTo(center.dx, center.dy + sideH * 0.15)
      ..lineTo(center.dx, bottom.dy)
      ..lineTo(right.dx, right.dy + sideH * 0.7)
      ..close();
    canvas.drawPath(
      rightFace,
      Paint()..color = Color.lerp(base, Colors.black, 0.15)!,
    );

    // Etched glowing edges.
    final edgePaint = Paint()
      ..color = AppColors.neonMint.withOpacity(0.5 + 0.3 * glowStrength)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(topFace, edgePaint);
    canvas.drawPath(leftFace, edgePaint);
    canvas.drawPath(rightFace, edgePaint);

    // Leaf-vein etching on the top face.
    _drawLeafEtch(canvas, top, right, left, center + Offset(0, sideH * 0.15));

    // Face icon (quest category glyph), shown once the die settles.
    if (faceIcon != null) {
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(faceIcon!.codePoint),
          style: TextStyle(
            fontSize: s * 0.16,
            fontFamily: faceIcon!.fontFamily,
            package: faceIcon!.fontPackage,
            color: Colors.white,
            shadows: const [Shadow(color: AppColors.neonMint, blurRadius: 12)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      iconPainter.paint(
        canvas,
        center - Offset(iconPainter.width / 2, iconPainter.height / 2 + sideH * 0.05),
      );
    }
  }

  void _drawLeafEtch(Canvas canvas, Offset top, Offset right, Offset left, Offset innerBottom) {
    final Offset midTop = Offset.lerp(top, innerBottom, 0.5)!;
    final veinPaint = Paint()
      ..color = AppColors.neonMint.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final spine = Path()
      ..moveTo(top.dx, top.dy + 4)
      ..lineTo(innerBottom.dx, innerBottom.dy - 4);
    canvas.drawPath(spine, veinPaint);

    for (double t = 0.2; t <= 0.8; t += 0.3) {
      final Offset spinePoint = Offset.lerp(top, innerBottom, t)!;
      final Offset toLeft = Offset.lerp(spinePoint, left, 0.5)!;
      final Offset toRight = Offset.lerp(spinePoint, right, 0.5)!;
      canvas.drawLine(spinePoint, toLeft, veinPaint);
      canvas.drawLine(spinePoint, toRight, veinPaint);
    }
    canvas.drawCircle(midTop, 1.5, veinPaint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant DicePainter oldDelegate) {
    return oldDelegate.skinColors != skinColors ||
        oldDelegate.glowStrength != glowStrength ||
        oldDelegate.faceIcon != faceIcon;
  }
}
