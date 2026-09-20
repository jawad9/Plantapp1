import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A neon laser line that sweeps top-to-bottom over a photo while the AI
/// Plant Doctor "analyzes" it. [progress] runs 0..1 across the scan duration.
class ScanLineOverlay extends StatelessWidget {
  final double progress;

  const ScanLineOverlay({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _ScanLinePainter(progress: progress),
        );
      },
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double progress;

  _ScanLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Darken overlay tint.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.black.withOpacity(0.25),
    );

    final double y = size.height * progress;

    final gradient = LinearGradient(
      colors: [
        AppColors.neonMint.withOpacity(0.0),
        AppColors.neonMint.withOpacity(0.9),
        AppColors.neonMint.withOpacity(0.0),
      ],
    );
    final bandRect = Rect.fromLTWH(0, y - 18, size.width, 36);
    canvas.drawRect(bandRect, Paint()..shader = gradient.createShader(bandRect));

    final linePaint = Paint()
      ..color = AppColors.neonMint
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);

    // Faint horizontal scan grid lines for a HUD feel.
    final gridPaint = Paint()
      ..color = AppColors.neonMint.withOpacity(0.08)
      ..strokeWidth = 1;
    for (double gy = 0; gy < size.height; gy += 24) {
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
