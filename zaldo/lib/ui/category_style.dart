import 'package:flutter/material.dart';

import '../domain/category.dart';

/// Fill pattern drawn over a category colour so categories can be told apart
/// without relying on colour (RNF03).
enum BarPattern { solid, diagonal, dots, horizontal, grid }

extension CategoryStyle on Category {
  /// All colours reach >= 3:1 against white (graphical objects, WCAG 1.4.11).
  Color get color => switch (this) {
    Category.alimentacion => const Color(0xFFB84A00),
    Category.transporte => const Color(0xFF0072B2),
    Category.ocio => const Color(0xFF8E2C9E),
    Category.compras => const Color(0xFF00796B),
    Category.otros => const Color(0xFF5C5C5C),
  };

  BarPattern get pattern => switch (this) {
    Category.alimentacion => BarPattern.diagonal,
    Category.transporte => BarPattern.solid,
    Category.ocio => BarPattern.dots,
    Category.compras => BarPattern.horizontal,
    Category.otros => BarPattern.grid,
  };
}

/// Paints [rect] with [color] and the [pattern] on top in white.
void paintPatternRect(
  Canvas canvas,
  Rect rect,
  Color color,
  BarPattern pattern,
) {
  canvas.save();
  canvas.clipRect(rect);
  canvas.drawRect(rect, Paint()..color = color);
  final line = Paint()
    ..color = Colors.white.withValues(alpha: 0.85)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;
  const step = 8.0;
  switch (pattern) {
    case BarPattern.solid:
      break;
    case BarPattern.diagonal:
      for (var x = rect.left - rect.height; x < rect.right; x += step) {
        canvas.drawLine(
          Offset(x, rect.bottom),
          Offset(x + rect.height, rect.top),
          line,
        );
      }
    case BarPattern.dots:
      final dot = Paint()..color = Colors.white.withValues(alpha: 0.9);
      for (var y = rect.top + 4; y < rect.bottom; y += step) {
        for (var x = rect.left + 4; x < rect.right; x += step) {
          canvas.drawCircle(Offset(x, y), 1.8, dot);
        }
      }
    case BarPattern.horizontal:
      for (var y = rect.top + 4; y < rect.bottom; y += step) {
        canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), line);
      }
    case BarPattern.grid:
      for (var y = rect.top + 4; y < rect.bottom; y += step) {
        canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), line);
      }
      for (var x = rect.left + 4; x < rect.right; x += step) {
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), line);
      }
  }
  canvas.restore();
}
