import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaldo/ui/contrast.dart';
import 'package:zaldo/ui/theme.dart';

void main() {
  test('black on white is 21:1', () {
    expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
  });

  // RNF01: pairs documented in the memoria, with required minimum.
  final pairs = <String, (Color, Color, double)>{
    'texto sobre fondo': (AppColors.text, AppColors.background, 4.5),
    'texto sobre tarjeta': (AppColors.text, AppColors.card, 4.5),
    'texto secundario sobre fondo': (
      AppColors.textSecondary,
      AppColors.background,
      4.5,
    ),
    'texto secundario sobre tarjeta': (
      AppColors.textSecondary,
      AppColors.card,
      4.5,
    ),
    'boton principal': (AppColors.onPrimary, AppColors.primary, 4.5),
    'boton secundario': (AppColors.primary, AppColors.background, 4.5),
    'barra navegacion inactiva': (
      AppColors.navInactive,
      AppColors.navBackground,
      4.5,
    ),
    'barra navegacion activa': (AppColors.onPrimary, AppColors.primary, 4.5),
    'borde de campos': (AppColors.fieldBorder, AppColors.card, 3.0),
    'error sobre fondo': (AppColors.error, AppColors.background, 4.5),
    'error sobre tarjeta': (AppColors.error, AppColors.card, 4.5),
  };
  pairs.forEach((name, p) {
    test('contraste $name >= ${p.$3}', () {
      expect(contrastRatio(p.$1, p.$2), greaterThanOrEqualTo(p.$3));
    });
  });

  test('palette matches memoria', () {
    expect(AppColors.background, const Color(0xFFF0F4FA));
    expect(AppColors.primary, const Color(0xFF2A5FE0));
    expect(AppColors.text, const Color(0xFF0E0E0E));
  });
}
