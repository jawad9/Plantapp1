import 'package:flutter/material.dart';

enum StoreItemType { diceSkin, shield }

/// A redeemable item in the Reward Store.
class StoreItem {
  final String id;
  final String name;
  final int cost;
  final StoreItemType type;
  final List<Color> previewColors;
  final IconData icon;

  const StoreItem({
    required this.id,
    required this.name,
    required this.cost,
    required this.type,
    required this.previewColors,
    required this.icon,
  });
}
