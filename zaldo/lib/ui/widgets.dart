import 'package:flutter/material.dart';

import '../domain/category.dart';
import 'theme.dart';

const kPad = 16.0;
const kGap = 12.0;

/// Error text that never relies on colour alone: icon + text (RNF03/RNF07).
class ErrorLine extends StatelessWidget {
  const ErrorLine(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Error: $text',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 22,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Category selector: name + icon always visible, check when selected.
class CategoryChoice extends StatelessWidget {
  const CategoryChoice({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });
  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.onPrimary : AppColors.text;
    return Semantics(
      button: true,
      selected: selected,
      label: category.label,
      hint: category.hint,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? AppColors.primary : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.fieldBorder,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 56,
              minWidth: kMinTouch,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Icon(Icons.check, color: fg, size: 20),
                    const SizedBox(width: 6),
                  ],
                  Icon(category.icon, color: fg, size: 22),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      category.label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 16,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryWrap extends StatelessWidget {
  const CategoryWrap({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final Category? selected;
  final ValueChanged<Category> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in Category.values)
          CategoryChoice(
            category: c,
            selected: c == selected,
            onTap: () => onChanged(c),
          ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.detail});
  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (detail != null) ...[
            const SizedBox(height: 8),
            Text(
              detail!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

void showConfirmationOn(ScaffoldMessengerState m, String message) {
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      backgroundColor: AppColors.text,
      duration: const Duration(seconds: 5),
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
