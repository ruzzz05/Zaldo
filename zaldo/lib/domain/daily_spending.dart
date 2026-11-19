import 'category.dart';
import 'expense.dart';

class DaySpending {
  const DaySpending(this.date, this.byCategory);
  final DateTime date;

  /// Only categories with spending, in [Category] enum order.
  final Map<Category, int> byCategory;

  int get totalCents => byCategory.values.fold(0, (a, b) => a + b);
}

/// Spending for the last [days] days ending on [today], oldest first.
List<DaySpending> lastDaysSpending(
  List<Expense> all,
  DateTime today,
  int days,
) {
  final end = DateTime(today.year, today.month, today.day);
  final result = <DaySpending>[];
  for (var i = days - 1; i >= 0; i--) {
    final day = DateTime(end.year, end.month, end.day - i);
    final sums = <Category, int>{};
    for (final e in all) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      if (d == day) sums[e.category] = (sums[e.category] ?? 0) + e.amountCents;
    }
    result.add(
      DaySpending(day, {
        for (final c in Category.values)
          if (sums.containsKey(c)) c: sums[c]!,
      }),
    );
  }
  return result;
}
