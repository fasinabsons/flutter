// models/vector_image.dart
import 'dart:ui';

class VectorImage {
  const VectorImage({
    required this.items,
    this.size,
  });

  final List<PathSvgItem> items;
  final Size? size;
}

class PathSvgItem {
  PathSvgItem({
    required this.path,
    this.fill,
  });

  final Path path;
  Color? fill;

  PathSvgItem copyWith({Path? path, Color? fill}) {
    return PathSvgItem(
      path: path ?? this.path,
      fill: fill ?? this.fill,
    );
  }
}