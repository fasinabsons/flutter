// utils/svg_renderer.dart (updated)
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgRenderer extends StatelessWidget {
  final String svgPath;
  final Color? color;

  const SvgRenderer({
    super.key,
    required this.svgPath,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgPath,
      fit: BoxFit.contain,
      colorFilter: color != null 
          ? ColorFilter.mode(color!, BlendMode.srcIn) 
          : null,
      placeholderBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}