import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF0F4FA);
  static const card = Color(0xFFFFFFFF);
  static const text = Color(0xFF0E0E0E);
  static const textSecondary = Color(0xFF5A6478);
  static const primary = Color(0xFF2A5FE0);
  static const onPrimary = Color(0xFFFFFFFF);
  static const navBackground = Color(0xFF0E0E0E);
  static const navInactive = Color(0xFF9AA3B2);
  static const fieldBorder = Color(0xFF7A8294);
  static const error = Color(0xFFC82828);
}

const double kMinTouch = 48;

ThemeData buildTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    surface: AppColors.card,
    onSurface: AppColors.text,
    error: AppColors.error,
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.fieldBorder, width: 1.5),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.error, width: 2.5),
      ),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
      floatingLabelStyle: const TextStyle(color: AppColors.text),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(kMinTouch, 56),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: AppColors.card,
        minimumSize: const Size(kMinTouch, 56),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(kMinTouch, kMinTouch),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}
