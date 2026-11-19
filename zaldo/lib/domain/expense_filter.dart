import 'category.dart';
import 'expense.dart';

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

class ExpenseFilter {
  const ExpenseFilter({this.from, this.to, this.category});
  final DateTime? from;
  final DateTime? to;
  final Category? category;

  bool get isActive => from != null || to != null || category != null;

  List<Expense> apply(List<Expense> items) => items.where((e) {
    final d = _day(e.date);
    if (from != null && d.isBefore(_day(from!))) return false;
    if (to != null && d.isAfter(_day(to!))) return false;
    if (category != null && e.category != category) return false;
    return true;
  }).toList();
}
