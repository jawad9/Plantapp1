import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/completed_quest.dart';
import '../models/quest_type.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';

/// "My Garden Log" tab: a running journal of claimed and forfeited quests.
class GardenLogScreen extends StatelessWidget {
  const GardenLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<AppState>().history;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Garden Log',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Every quest you\'ve rolled, claimed, or skipped.',
            style: TextStyle(color: AppColors.softSage, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: history.isEmpty
                ? const _EmptyLog()
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _LogTile(entry: history[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLog extends StatelessWidget {
  const _EmptyLog();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_florist_rounded, color: AppColors.softSage, size: 48),
          SizedBox(height: 12),
          Text('No quests yet.', style: TextStyle(color: AppColors.softSage)),
          Text('Roll a die to start your log!', style: TextStyle(color: AppColors.softSage, fontSize: 12)),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final CompletedQuest entry;
  const _LogTile({required this.entry});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final isToday = now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return isToday ? 'Today $h:$m' : '${dt.month}/${dt.day} $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final quest = entry.quest;
    return GlassCard(
      borderRadius: 16,
      borderColor: entry.forfeited
          ? AppColors.danger.withOpacity(0.25)
          : AppColors.neonMint.withOpacity(0.2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (entry.forfeited ? AppColors.danger : AppColors.neonMint).withOpacity(0.12),
            ),
            child: Icon(
              quest.type.icon,
              color: entry.forfeited ? AppColors.danger : AppColors.neonMint,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quest.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(_formatDate(entry.completedAt), style: const TextStyle(color: AppColors.softSage, fontSize: 11)),
              ],
            ),
          ),
          Text(
            entry.forfeited ? 'Forfeited' : '+${entry.coinsEarned} 🪙',
            style: TextStyle(
              color: entry.forfeited ? AppColors.danger : AppColors.amberGold,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
