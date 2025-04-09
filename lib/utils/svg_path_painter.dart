// utils/svg_path_painter.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SvgPathPainter extends CustomPainter {
  final String pathData;
  final Color color;
  final Size size;
  final double svgWidth;
  final double svgHeight;

  SvgPathPainter({
    required this.pathData,
    required this.color,
    required this.size,
    required this.svgWidth,
    required this.svgHeight,
  });

  // Helper to approximate an elliptical arc with cubic Bézier curves
  void _addArcToPath(
    ui.Path path,
    Offset startPoint,
    double rx,
    double ry,
    double xAxisRotation,
    int largeArcFlag,
    int sweepFlag,
    Offset endPoint,
  ) {
    rx *= size.width / svgWidth;
    ry *= size.height / svgHeight;
    final phi = xAxisRotation * math.pi / 180.0;
    final dx = (startPoint.dx - endPoint.dx) / 2.0;
    final dy = (startPoint.dy - endPoint.dy) / 2.0;
    final x1p = math.cos(phi) * dx + math.sin(phi) * dy;
    final y1p = -math.sin(phi) * dx + math.cos(phi) * dy;
    final rxs = rx * rx;
    final rys = ry * ry;
    final x1ps = x1p * x1p;
    final y1ps = y1p * y1p;
    final lambda = x1ps / rxs + y1ps / rys;
    if (lambda > 1) {
      rx *= math.sqrt(lambda);
      ry *= math.sqrt(lambda);
    }
    final sign = (largeArcFlag == sweepFlag) ? -1 : 1;
    final coef = sign *
        math.sqrt(
          (rxs * rys - rxs * y1ps - rys * x1ps) /
              (rxs * y1ps + rys * x1ps),
        ).clamp(0, double.infinity);
    final cxp = coef * rx * y1p / ry;
    final cyp = coef * -ry * x1p / rx;
    final cx = math.cos(phi) * cxp - math.sin(phi) * cyp + (startPoint.dx + endPoint.dx) / 2.0;
    final cy = math.sin(phi) * cxp + math.cos(phi) * cyp + (startPoint.dy + endPoint.dy) / 2.0;
    final theta = _angle(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry);
    var delta = _angle(
      (x1p - cxp) / rx,
      (y1p - cyp) / ry,
      (-x1p - cxp) / rx,
      (-y1p - cyp) / ry,
    );
    delta = delta % (2 * math.pi);
    if (sweepFlag == 0 && delta > 0) {
      delta -= 2 * math.pi;
    } else if (sweepFlag == 1 && delta < 0) {
      delta += 2 * math.pi;
    }
    const segments = 4;
    final dTheta = delta / segments;
    for (var i = 0; i < segments; i++) {
      final t0 = i * dTheta;
      final t1 = (i + 1) * dTheta;
      final p0 = _pointOnEllipse(cx, cy, rx, ry, phi, theta + t0);
      final p1 = _pointOnEllipse(cx, cy, rx, ry, phi, theta + t1);
      final alpha = math.sin(dTheta) * (math.sqrt(4 + 3 * math.tan(dTheta / 2) * math.tan(dTheta / 2)) - 1) / 3;
      final d0 = _derivativeOnEllipse(rx, ry, phi, theta + t0);
      final d1 = _derivativeOnEllipse(rx, ry, phi, theta + t1);
      final cp0 = Offset(p0.dx + alpha * d0.dx, p0.dy + alpha * d0.dy);
      final cp1 = Offset(p1.dx - alpha * d1.dx, p1.dy - alpha * d1.dy);
      path.cubicTo(cp0.dx, cp0.dy, cp1.dx, cp1.dy, p1.dx, p1.dy);
    }
  }

  double _angle(double ux, double uy, double vx, double vy) {
    final dot = ux * vx + uy * vy;
    final det = ux * vy - uy * vx;
    return math.atan2(det, dot);
  }

  Offset _pointOnEllipse(double cx, double cy, double rx, double ry, double phi, double theta) {
    final x = rx * math.cos(theta);
    final y = ry * math.sin(theta);
    return Offset(
      cx + math.cos(phi) * x - math.sin(phi) * y,
      cy + math.sin(phi) * x + math.cos(phi) * y,
    );
  }

  Offset _derivativeOnEllipse(double rx, double ry, double phi, double theta) {
    final dx = -rx * math.sin(theta);
    final dy = ry * math.cos(theta);
    return Offset(
      math.cos(phi) * dx - math.sin(phi) * dy,
      math.sin(phi) * dx + math.cos(phi) * dy,
    );
  }

  ui.Path _parsePath() {
    final path = ui.Path();
    Offset currentPoint = Offset.zero;
    Offset? lastControlPoint;

    final commands = pathData.split(RegExp(r'(?=[MmLlHhVvCcSsQqTtAaZz])'));
    for (final command in commands) {
      final parts = command.trim().replaceAll(',', ' ').split(RegExp(r'\s+'));
      if (parts.isEmpty) continue;

      final type = parts[0];
      final isRelative = type.toLowerCase() == type;

      try {
        switch (type.toUpperCase()) {
          case 'M':
            final x = double.parse(parts[1]);
            final y = double.parse(parts[2]);
            currentPoint = Offset(
              (isRelative ? currentPoint.dx + x : x) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y : y) * size.height / svgHeight,
            );
            path.moveTo(currentPoint.dx, currentPoint.dy);
            break;

          case 'L':
            final x = double.parse(parts[1]);
            final y = double.parse(parts[2]);
            final newPoint = Offset(
              (isRelative ? currentPoint.dx + x : x) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y : y) * size.height / svgHeight,
            );
            path.lineTo(newPoint.dx, newPoint.dy);
            currentPoint = newPoint;
            break;

          case 'H':
            final x = double.parse(parts[1]);
            final newPoint = Offset(
              (isRelative ? currentPoint.dx + x : x) * size.width / svgWidth,
              currentPoint.dy,
            );
            path.lineTo(newPoint.dx, newPoint.dy);
            currentPoint = newPoint;
            break;

          case 'V':
            final y = double.parse(parts[1]);
            final newPoint = Offset(
              currentPoint.dx,
              (isRelative ? currentPoint.dy + y : y) * size.height / svgHeight,
            );
            path.lineTo(newPoint.dx, newPoint.dy);
            currentPoint = newPoint;
            break;

          case 'C':
            final x1 = double.parse(parts[1]);
            final y1 = double.parse(parts[2]);
            final x2 = double.parse(parts[3]);
            final y2 = double.parse(parts[4]);
            final x = double.parse(parts[5]);
            final y = double.parse(parts[6]);
            final newPoint = Offset(
              (isRelative ? currentPoint.dx + x : x) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y : y) * size.height / svgHeight,
            );
            path.cubicTo(
              (isRelative ? currentPoint.dx + x1 : x1) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y1 : y1) * size.height / svgHeight,
              (isRelative ? currentPoint.dx + x2 : x2) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y2 : y2) * size.height / svgHeight,
              newPoint.dx,
              newPoint.dy,
            );
            lastControlPoint = Offset(
              (isRelative ? currentPoint.dx + x2 : x2) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y2 : y2) * size.height / svgHeight,
            );
            currentPoint = newPoint;
            break;

          case 'S':
            final x2 = double.parse(parts[1]);
            final y2 = double.parse(parts[2]);
            final x = double.parse(parts[3]);
            final y = double.parse(parts[4]);
            final newPoint = Offset(
              (isRelative ? currentPoint.dx + x : x) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y : y) * size.height / svgHeight,
            );
            final control1 = lastControlPoint != null
                ? Offset(
                    2 * currentPoint.dx - lastControlPoint.dx,
                    2 * currentPoint.dy - lastControlPoint.dy,
                  )
                : currentPoint;
            path.cubicTo(
              control1.dx,
              control1.dy,
              (isRelative ? currentPoint.dx + x2 : x2) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y2 : y2) * size.height / svgHeight,
              newPoint.dx,
              newPoint.dy,
            );
            lastControlPoint = Offset(
              (isRelative ? currentPoint.dx + x2 : x2) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y2 : y2) * size.height / svgHeight,
            );
            currentPoint = newPoint;
            break;

          case 'Q':
            final x1 = double.parse(parts[1]);
            final y1 = double.parse(parts[2]);
            final x = double.parse(parts[3]);
            final y = double.parse(parts[4]);
            final newPoint = Offset(
              (isRelative ? currentPoint.dx + x : x) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y : y) * size.height / svgHeight,
            );
            path.quadraticBezierTo(
              (isRelative ? currentPoint.dx + x1 : x1) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y1 : y1) * size.height / svgHeight,
              newPoint.dx,
              newPoint.dy,
            );
            lastControlPoint = Offset(
              (isRelative ? currentPoint.dx + x1 : x1) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y1 : y1) * size.height / svgHeight,
            );
            currentPoint = newPoint;
            break;

          case 'A':
            final rx = double.parse(parts[1]);
            final ry = double.parse(parts[2]);
            final xAxisRotation = double.parse(parts[3]);
            final largeArcFlag = int.parse(parts[4]);
            final sweepFlag = int.parse(parts[5]);
            final x = double.parse(parts[6]);
            final y = double.parse(parts[7]);
            final newPoint = Offset(
              (isRelative ? currentPoint.dx + x : x) * size.width / svgWidth,
              (isRelative ? currentPoint.dy + y : y) * size.height / svgHeight,
            );
            _addArcToPath(
              path,
              currentPoint,
              rx,
              ry,
              xAxisRotation,
              largeArcFlag,
              sweepFlag,
              newPoint,
            );
            currentPoint = newPoint;
            break;

          case 'Z':
            path.close();
            break;
        }
      } catch (e) {
        continue;
      }
    }
    return path;
  }

  Rect computeBounds() {
    if (pathData.isEmpty) return Rect.zero;
    return _parsePath().getBounds();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (pathData.isEmpty || color == Colors.transparent) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = _parsePath();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}