import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';

/// Screen 6: Pro upgrade paywall, shown when a player runs out of daily
/// AI Doctor scans. Purchases are mocked - tapping a price just unlocks Pro.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  void _mockPurchase(BuildContext context, String plan) {
    context.read<AppState>().unlockPro();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pro unlocked ($plan) - mocked purchase for demo.'),
        backgroundColor: AppColors.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
            glow: true,
            glowColor: AppColors.neonMint,
            borderRadius: 26,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neonMint.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.neonMint.withOpacity(0.4), blurRadius: 12)],
                  ),
                  child: const Text(
                    '🌿 PRO',
                    style: TextStyle(color: AppColors.neonMint, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unlock Unlimited AI Diagnoses',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                const _Bullet(text: 'Unlimited daily AI Doctor scans'),
                const _Bullet(text: 'Exclusive Neon Dice skins'),
                const _Bullet(text: '2x coin multiplier on every quest'),
                const SizedBox(height: 22),
                GlowButton(
                  label: '\$2.99 / Week',
                  expand: true,
                  onPressed: () => _mockPurchase(context, 'Weekly'),
                ),
                const SizedBox(height: 10),
                GlowButton(
                  label: '\$24.99 / Year - Best Value',
                  style: GlowButtonStyle.secondary,
                  expand: true,
                  onPressed: () => _mockPurchase(context, 'Yearly'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Continue with Free Rolls',
                    style: TextStyle(color: AppColors.softSage),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.neonMint, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.softSage, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}
