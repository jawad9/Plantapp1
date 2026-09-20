import 'package:flutter/material.dart';

/// Central palette for the "Jungle Glow" theme.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF121614);
  static const Color surface = Color(0xFF1E2D24);
  static const Color neonMint = Color(0xFF25E289);
  static const Color amberGold = Color(0xFFE9C46A);
  static const Color softSage = Color(0xFF74C69D);

  static const Color danger = Color(0xFFE26D5A);

  static Color borderMint = neonMint.withOpacity(0.2);
  static Color glowMint = neonMint.withOpacity(0.45);
  static Color glowAmber = amberGold.withOpacity(0.45);
}
