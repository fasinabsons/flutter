// utils/svg_utils.dart
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart'; // Updated import
import 'package:xml/xml.dart';
import '../models/vector_image.dart';

VectorImage getVectorImageFromStringXml(String svgData) {
  List<PathSvgItem> items = [];

  // Step 1: Parse the XML
  XmlDocument document = XmlDocument.parse(svgData);

  // Step 2: Get the size of the SVG
  Size? size;
  String? width = document.findAllElements('svg').first.getAttribute('width');
  String? height = document.findAllElements('svg').first.getAttribute('height');
  String? viewBox = document.findAllElements('svg').first.getAttribute('viewBox');
  if (width != null && height != null) {
    width = width.replaceAll(RegExp(r'[^0-9.]'), '');
    height = height.replaceAll(RegExp(r'[^0-9.]'), '');
    size = Size(double.parse(width), double.parse(height));
  } else if (viewBox != null) {
    List<String> viewBoxList = viewBox.split(' ');
    size = Size(double.parse(viewBoxList[2]), double.parse(viewBoxList[3]));
  }

  // Step 3: Get the paths
  final List<XmlElement> paths = document.findAllElements('path').toList();
  for (int i = 0; i < paths.length; i++) {
    final XmlElement element = paths[i];

    // Get the path
    String? pathString = element.getAttribute('d');
    if (pathString == null) {
      continue;
    }
    Path path = parseSvgPathData(pathString); // Use parseSvgPathData from path_drawing

    // Get the fill color
    String? fill = element.getAttribute('fill');
    String? style = element.getAttribute('style');
    if (style != null) {
      fill = _getFillColor(style);
    }

    // Get the transformations
    String? transformAttribute = element.getAttribute('transform');
    double scaleX = 1.0;
    double scaleY = 1.0;
    double? translateX;
    double? translateY;
    if (transformAttribute != null) {
      var scale = _getScale(transformAttribute);
      if (scale != null) {
        scaleX = scale.x;
        scaleY = scale.y;
      }
      var translate = _getTranslate(transformAttribute);
      if (translate != null) {
        translateX = translate.x;
        translateY = translate.y;
      }
    }

    final Matrix4 matrix4 = Matrix4.identity();
    if (translateX != null && translateY != null) {
      matrix4.translate(translateX, translateY);
    }
    matrix4.scale(scaleX, scaleY);

    path = path.transform(matrix4.storage);

    items.add(PathSvgItem(
      fill: _getColorFromString(fill),
      path: path,
    ));
  }

  return VectorImage(items: items, size: size);
}

({double x, double y})? _getScale(String data) {
  RegExp regExp = RegExp(r'scale\(([^,]+),([^)]+)\)');
  var match = regExp.firstMatch(data);

  if (match != null) {
    try {
      double scaleX = double.parse(match.group(1)!);
      double scaleY = double.parse(match.group(2)!);
      return (x: scaleX, y: scaleY);
    } catch (e) {
      debugPrint('Error parsing scale: $e');
      return null;
    }
  }
  return null;
}

({double x, double y})? _getTranslate(String data) {
  RegExp regExp = RegExp(r'translate\(([^,]+),([^)]+)\)');
  var match = regExp.firstMatch(data);

  if (match != null) {
    try {
      double translateX = double.parse(match.group(1)!);
      double translateY = double.parse(match.group(2)!);
      return (x: translateX, y: translateY);
    } catch (e) {
      debugPrint('Error parsing translate: $e');
      return null;
    }
  }
  return null;
}

String? _getFillColor(String data) {
  RegExp regExp = RegExp(r'fill:\s*(#[a-fA-F0-9]{6})');
  RegExpMatch? match = regExp.firstMatch(data);
  return match?.group(1);
}

Color _hexToColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

Color? _getColorFromString(String? colorString) {
  if (colorString == null) return null;
  if (colorString.startsWith('#')) {
    return _hexToColor(colorString);
  } else {
    switch (colorString) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      default:
        return Colors.transparent;
    }
  }
}