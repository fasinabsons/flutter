// utils/svg_renderer.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgRenderer extends StatelessWidget {
  final String svgPath;

  const SvgRenderer({
    super.key,
    required this.svgPath,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgPath,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }
}
