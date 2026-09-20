import 'package:flutter/material.dart';

import '../models/store_item.dart';
import '../theme/app_colors.dart';

/// Static catalog for the Reward Store.
class StoreBank {
  StoreBank._();

  static const String defaultSkinId = 'default';

  static const List<Color> defaultSkinColors = [AppColors.surface, AppColors.neonMint];

  static const List<StoreItem> items = [
    StoreItem(
      id: 'amber_fire',
      name: 'Amber Fire Die Skin',
      cost: 150,
      type: StoreItemType.diceSkin,
      previewColors: [Color(0xFF3A2A12), AppColors.amberGold],
      icon: Icons.local_fire_department_rounded,
    ),
    StoreItem(
      id: 'cyber_crystal',
      name: 'Cyber Crystal Die Skin',
      cost: 300,
      type: StoreItemType.diceSkin,
      previewColors: [Color(0xFF0B1A2A), Color(0xFF4CC9F0)],
      icon: Icons.diamond_rounded,
    ),
    StoreItem(
      id: 'streak_shield',
      name: 'Streak Freeze Shield',
      cost: 80,
      type: StoreItemType.shield,
      previewColors: [Color(0xFF1B2A3A), Color(0xFF74C69D)],
      icon: Icons.shield_rounded,
    ),
  ];

  static List<Color> colorsForSkin(String skinId) {
    if (skinId == defaultSkinId) return defaultSkinColors;
    final match = items.where((i) => i.id == skinId && i.type == StoreItemType.diceSkin);
    if (match.isEmpty) return defaultSkinColors;
    return match.first.previewColors;
  }

  static StoreItem byId(String id) => items.firstWhere((i) => i.id == id);
}
