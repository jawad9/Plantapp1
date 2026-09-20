import 'quest_type.dart';

/// A single rollable quest/task shown in the result modal.
class Quest {
  final String id;
  final QuestType type;
  final String title;
  final String description;
  final int coinReward;

  const Quest({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.coinReward,
  });
}
