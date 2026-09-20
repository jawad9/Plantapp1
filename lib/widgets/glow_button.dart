import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum GlowButtonStyle { primary, secondary, danger }

/// A pill-shaped CTA button with a soft neon glow (used for primary actions
/// like "Claim Coins", "Start Adventure", "Redeem").
class GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final GlowButtonStyle style;
  final IconData? icon;
  final bool expand;

  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = GlowButtonStyle.primary,
    this.icon,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = style == GlowButtonStyle.primary;
    final bool isDanger = style == GlowButtonStyle.danger;
    final Color base = isDanger
        ? AppColors.danger
        : isPrimary
            ? AppColors.neonMint
            : AppColors.softSage;
    final bool enabled = onPressed != null;

    final button = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: (isPrimary || isDanger) && enabled
            ? [BoxShadow(color: base.withOpacity(0.45), blurRadius: 12, spreadRadius: 1)]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: (isPrimary || isDanger) ? base : Colors.transparent,
          disabledBackgroundColor: base.withOpacity(0.25),
          foregroundColor: (isPrimary || isDanger) ? Colors.black : base,
          elevation: 0,
          side: (isPrimary || isDanger) ? null : BorderSide(color: base.withOpacity(0.6)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
