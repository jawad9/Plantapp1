import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/quest_type.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/mode_card.dart';
import 'rolling_arena_screen.dart';

/// Screen 2 content: top bar (coins + scan credits) and the 4-card mode grid.
class RollHomeTab extends StatelessWidget {
  const RollHomeTab({super.key});

  void _openArena(BuildContext context, QuestType type) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RollingArenaScreen(questType: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TopBar(),
          const SizedBox(height: 24),
          const Text(
            'Roll the Jungle',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pick a die to start today\'s quest.',
            style: TextStyle(color: AppColors.softSage, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.92,
              children: [
                ModeCard(
                  icon: QuestType.adopt.icon,
                  title: QuestType.adopt.label,
                  microCopy: QuestType.adopt.microCopy,
                  accent: AppColors.softSage,
                  onTap: () => _openArena(context, QuestType.adopt),
                ),
                ModeCard(
                  icon: QuestType.care.icon,
                  title: QuestType.care.label,
                  microCopy: QuestType.care.microCopy,
                  accent: AppColors.neonMint,
                  onTap: () => _openArena(context, QuestType.care),
                ),
                ModeCard(
                  icon: QuestType.doctor.icon,
                  title: QuestType.doctor.label,
                  microCopy: QuestType.doctor.microCopy,
                  accent: AppColors.amberGold,
                  onTap: () => _openArena(context, QuestType.doctor),
                ),
                ModeCard(
                  icon: QuestType.mission.icon,
                  title: QuestType.mission.label,
                  microCopy: QuestType.mission.microCopy,
                  accent: const Color(0xFF4CC9F0),
                  onTap: () => _openArena(context, QuestType.mission),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          borderRadius: 24,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  '${appState.coins}',
                  key: ValueKey<int>(appState.coins),
                  style: const TextStyle(
                    color: AppColors.amberGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          borderRadius: 24,
          borderColor: AppColors.amberGold.withOpacity(0.3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📷', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                appState.isPro
                    ? 'Unlimited Scans'
                    : '${appState.scanCredits}/${AppState.maxScanCredits} Scans Left',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
