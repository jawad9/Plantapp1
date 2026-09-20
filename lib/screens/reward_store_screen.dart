import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store_bank.dart';
import '../models/store_item.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_button.dart';

/// Screen 7: Reward Store. Spend coins on dice skins and consumables.
class RewardStoreScreen extends StatelessWidget {
  const RewardStoreScreen({super.key});

  void _redeem(BuildContext context, StoreItem item) {
    final appState = context.read<AppState>();
    final success = appState.redeem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        content: Text(
          success
              ? '${item.name} redeemed!'
              : appState.canAfford(item.cost)
                  ? 'You already own this skin.'
                  : 'Not enough coins for ${item.name}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reward Store',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            glow: true,
            glowColor: AppColors.amberGold,
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(
                  '${appState.coins} Coins',
                  style: const TextStyle(color: AppColors.amberGold, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: StoreBank.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = StoreBank.items[index];
                final bool isSkin = item.type == StoreItemType.diceSkin;
                final bool owned = isSkin && appState.ownsSkin(item.id);
                final bool equipped = isSkin && appState.activeSkinId == item.id;

                return GlassCard(
                  borderRadius: 18,
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: item.previewColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(item.icon, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.cost} Coins',
                              style: const TextStyle(color: AppColors.softSage, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (owned)
                        equipped
                            ? const _EquippedPill()
                            : GlowButton(
                                label: 'Equip',
                                style: GlowButtonStyle.secondary,
                                onPressed: () => appState.equipSkin(item.id),
                              )
                      else
                        GlowButton(
                          label: 'Redeem',
                          onPressed: () => _redeem(context, item),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EquippedPill extends StatelessWidget {
  const _EquippedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neonMint.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonMint.withOpacity(0.4)),
      ),
      child: const Text('Equipped', style: TextStyle(color: AppColors.neonMint, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
