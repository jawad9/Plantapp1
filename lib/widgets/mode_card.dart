import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'glass_card.dart';

/// One of the 4 glowing grid cards on the Mode Selector Hub.
class ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String microCopy;
  final VoidCallback onTap;
  final Color accent;

  const ModeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.microCopy,
    required this.onTap,
    this.accent = AppColors.neonMint,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      glow: true,
      glowColor: accent,
      borderColor: accent.withOpacity(0.35),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.14),
              boxShadow: [BoxShadow(color: accent.withOpacity(0.4), blurRadius: 10)],
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            microCopy,
            style: const TextStyle(color: AppColors.softSage, fontSize: 12, height: 1.3),
          ),
        ],
      ),
    );
  }
}
