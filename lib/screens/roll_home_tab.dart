import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/quest_type.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/mode_card.dart';
import 'chat_screen.dart';
import 'rolling_arena_screen.dart';
import 'settings_screen.dart';

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
            child: ListView(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                const SizedBox(height: 14),
                _AiChatBanner(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  ),
                ),
                const SizedBox(height: 8),
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
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.82),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.neonMint.withOpacity(0.2)),
            ),
            child: const Icon(Icons.settings_rounded, color: AppColors.softSage, size: 18),
          ),
        ),
      ],
    );
  }
}

class _AiChatBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _AiChatBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      glow: true,
      glowColor: const Color(0xFF4CC9F0),
      borderColor: const Color(0xFF4CC9F0).withOpacity(0.35),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CC9F0).withOpacity(0.14),
            ),
            child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF4CC9F0), size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Chat',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 2),
                Text(
                  'Ask your plant-care assistant anything.',
                  style: TextStyle(color: AppColors.softSage, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.softSage),
        ],
      ),
    );
  }
}
