import 'package:flutter/material.dart';

/// The four "dice" a player can roll from the Mode Selector Hub.
enum QuestType { adopt, care, doctor, mission }

extension QuestTypeX on QuestType {
  String get label {
    switch (this) {
      case QuestType.adopt:
        return 'Adopt Die';
      case QuestType.care:
        return 'Quick Care Die';
      case QuestType.doctor:
        return 'AI Plant Doctor Die';
      case QuestType.mission:
        return 'Mission Die';
    }
  }

  String get microCopy {
    switch (this) {
      case QuestType.adopt:
        return 'What plant should I adopt next?';
      case QuestType.care:
        return '5-minute zero-tool plant tasks.';
      case QuestType.doctor:
        return 'Snap a photo for a custom quest.';
      case QuestType.mission:
        return 'Pruning, propagation & soil experiments.';
    }
  }

  IconData get icon {
    switch (this) {
      case QuestType.adopt:
        return Icons.eco_rounded;
      case QuestType.care:
        return Icons.spa_rounded;
      case QuestType.doctor:
        return Icons.camera_alt_rounded;
      case QuestType.mission:
        return Icons.park_rounded;
    }
  }
}
