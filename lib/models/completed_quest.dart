import 'quest.dart';

/// A journal entry recorded in "My Garden Log" once a quest is claimed or forfeited.
class CompletedQuest {
  final Quest quest;
  final DateTime completedAt;
  final bool forfeited;
  final int coinsEarned;

  const CompletedQuest({
    required this.quest,
    required this.completedAt,
    required this.coinsEarned,
    this.forfeited = false,
  });
}
