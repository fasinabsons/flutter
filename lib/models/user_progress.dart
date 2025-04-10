import 'package:flutter/material.dart';

class UserProgress {
  int level;
  int coins;
  List<String> badges;
  Map<String, Map<String, Color>> coloredParts; // Page ID -> Part ID -> Color
  bool isGuest; // new

  UserProgress({
    this.level = 1,
    this.coins = 0,
    this.badges = const [],
    this.coloredParts = const {},
    this.isGuest = true,
  });
}
