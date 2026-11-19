import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../data/expense_repository.dart';
import '../domain/amount_parser.dart';
import '../domain/category.dart';
import '../domain/expense.dart';
import '../domain/expense_filter.dart';
import '../domain/summary.dart';

class DraftValidation {
  const DraftValidation({
    this.cents,
    this.amountError,
    required this.categoryMissing,
  });
  final int? cents;
  final AmountError? amountError;
  final bool categoryMissing;
  bool get isValid => amountError == null && !categoryMissing;
}

DraftValidation validateDraft({
  required String amountText,
  required Category? category,
}) {
  final r = parseAmount(amountText);
  return DraftValidation(
    cents: r.cents,
    amountError: r.error,
    categoryMissing: category == null,
  );
}

class ExpenseStore extends ChangeNotifier {
  ExpenseStore(this._repo, {DateTime Function()? now})
    : _now = now ?? DateTime.now {
    _month = _now();
  }

  final ExpenseRepository _repo;
  final DateTime Function() _now;
  List<Expense> _all = [];
  ExpenseFilter _filter = const ExpenseFilter();
  late DateTime _month;
  int _seq = 0;

  /// Insertion order.
  List<Expense> get all => List.unmodifiable(_all);
  ExpenseFilter get filter => _filter;
  DateTime get month => DateTime(_month.year, _month.month);

  /// Filtered list, newest first.
  List<Expense> get visible {
    final list = _filter.apply(_all);
    final order = {for (var i = 0; i < _all.length; i++) _all[i].id: i};
    list.sort((a, b) {
      final c = b.date.compareTo(a.date);
      return c != 0 ? c : order[b.id]!.compareTo(order[a.id]!);
    });
    return list;
  }

  MonthlySummary get summary => MonthlySummary.of(_all, _month);
  Expense? get lastExpense => _all.isEmpty ? null : _all.last;
  Expense? byId(String id) {
    for (final e in _all) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<void> load() async {
    _all = await _repo.load();
    notifyListeners();
  }

  Future<void> add({
    required int cents,
    required Category category,
    required DateTime date,
    String description = '',
  }) async {
    _all = [
      ..._all,
      Expense(
        id: '${_now().microsecondsSinceEpoch}-${_seq++}',
        amountCents: cents,
        category: category,
        date: date,
        description: description.trim(),
      ),
    ];
    await _repo.save(_all);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _all = _all.where((e) => e.id != id).toList();
    await _repo.save(_all);
    notifyListeners();
  }

  void setFilter(ExpenseFilter f) {
    _filter = f;
    notifyListeners();
  }

  void clearFilter() => setFilter(const ExpenseFilter());

  void setMonth(DateTime m) {
    _month = DateTime(m.year, m.month);
    notifyListeners();
  }
}
