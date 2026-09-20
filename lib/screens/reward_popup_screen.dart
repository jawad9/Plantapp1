import 'package:flutter/material.dart';

import '../data/quest_bank.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';
import '../widgets/particle_burst_painter.dart';

/// Screen 5: "Botanical Win" reward popup. Shown after claiming a quest -
/// golden coin shower, a counting-up coin total, and an educational fact.
class RewardPopupScreen extends StatefulWidget {
  final int coinsEarned;

  const RewardPopupScreen({super.key, required this.coinsEarned});

  @override
  State<RewardPopupScreen> createState() => _RewardPopupScreenState();
}

class _RewardPopupScreenState extends State<RewardPopupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _coinCount;
  late final List<ConfettiParticle> _particles;
  late final String _fact;

  @override
  void initState() {
    super.initState();
    _particles = generateConfetti();
    _fact = QuestBank.randomBotanicalFact();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _coinCount = IntTween(begin: 0, end: widget.coinsEarned).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: ParticleBurstPainter(progress: _controller.value, particles: _particles),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 320,
                child: GlassCard(
                  glow: true,
                  glowColor: AppColors.amberGold,
                  borderRadius: 24,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 44)),
                      const SizedBox(height: 8),
                      const Text(
                        'Botanical Win!',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 14),
                      AnimatedBuilder(
                        animation: _coinCount,
                        builder: (context, _) => Text(
                          '+${_coinCount.value} 🪙',
                          style: const TextStyle(
                            color: AppColors.amberGold,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.neonMint.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.neonMint.withOpacity(0.2)),
                        ),
                        child: Text(
                          _fact,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.softSage, fontSize: 13, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 22),
                      GlowButton(
                        label: 'Back to Jungle',
                        icon: Icons.park_rounded,
                        expand: true,
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
