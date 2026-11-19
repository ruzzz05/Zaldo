import 'package:flutter_test/flutter_test.dart';
import 'package:zaldo/domain/category.dart';
import 'package:zaldo/domain/daily_spending.dart';
import 'package:zaldo/domain/expense.dart';

Expense e(int cents, Category c, DateTime d) => Expense(
  id: '$cents-${d.day}-${c.name}',
  amountCents: cents,
  category: c,
  date: d,
  description: '',
);

void main() {
  final today = DateTime(2026, 11, 18, 15, 30);

  test('returns 7 days, oldest first, ending today, empty days at zero', () {
    final days = lastDaysSpending([], today, 7);
    expect(days, hasLength(7));
    expect(days.first.date, DateTime(2026, 11, 12));
    expect(days.last.date, DateTime(2026, 11, 18));
    expect(days.every((d) => d.totalCents == 0), isTrue);
  });

  test('sums per day and per category', () {
    final days = lastDaysSpending(
      [
        e(450, Category.alimentacion, DateTime(2026, 11, 17)),
        e(300, Category.alimentacion, DateTime(2026, 11, 17)),
        e(1200, Category.transporte, DateTime(2026, 11, 17)),
        e(999, Category.ocio, DateTime(2026, 11, 18)),
      ],
      today,
      7,
    );
    final d17 = days.firstWhere((d) => d.date.day == 17);
    expect(d17.totalCents, 1950);
    expect(d17.byCategory[Category.alimentacion], 750);
    expect(d17.byCategory[Category.transporte], 1200);
    expect(days.last.totalCents, 999);
  });

  test('ignores expenses outside the window', () {
    final days = lastDaysSpending(
      [
        e(500, Category.otros, DateTime(2026, 11, 11)),
        e(500, Category.otros, DateTime(2026, 11, 19)),
      ],
      today,
      7,
    );
    expect(days.every((d) => d.totalCents == 0), isTrue);
  });

  test('categories listed in enum order for stable stacking', () {
    final days = lastDaysSpending(
      [
        e(100, Category.otros, DateTime(2026, 11, 18)),
        e(100, Category.alimentacion, DateTime(2026, 11, 18)),
      ],
      today,
      7,
    );
    expect(days.last.byCategory.keys.toList(), [
      Category.alimentacion,
      Category.otros,
    ]);
  });
}
