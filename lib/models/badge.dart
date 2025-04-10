// badge.dart
class Badge {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final int levelRequired;
  final DateTime? unlockedAt;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    this.levelRequired = 1,
    this.unlockedAt,
  });
}