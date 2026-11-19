import 'category.dart';
import 'expense.dart';

class CategoryTotal {
  const CategoryTotal(this.category, this.cents);
  final Category category;
  final int cents;
}

class MonthlySummary {
  const MonthlySummary(this.month, this.totalCents, this.byCategory);
  final DateTime month;
  final int totalCents;
  final List<CategoryTotal> byCategory;

  bool get isEmpty => byCategory.isEmpty;

  factory MonthlySummary.of(List<Expense> all, DateTime month) {
    final sums = <Category, int>{};
    var total = 0;
    for (final e in all) {
      if (e.date.year != month.year || e.date.month != month.month) continue;
      sums[e.category] = (sums[e.category] ?? 0) + e.amountCents;
      total += e.amountCents;
    }
    final list = sums.entries.map((x) => CategoryTotal(x.key, x.value)).toList()
      ..sort((a, b) => b.cents.compareTo(a.cents));
    return MonthlySummary(DateTime(month.year, month.month), total, list);
  }
}
