import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> load();
  Future<void> save(List<Expense> expenses);
}

class InMemoryExpenseRepository implements ExpenseRepository {
  List<Expense> _items = [];
  @override
  Future<List<Expense>> load() async => List.of(_items);
  @override
  Future<void> save(List<Expense> expenses) async => _items = List.of(expenses);
}

/// Local-only storage (RNF12): nothing leaves the device.
class PrefsExpenseRepository implements ExpenseRepository {
  PrefsExpenseRepository(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'expenses_v1';

  @override
  Future<List<Expense>> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> save(List<Expense> expenses) async {
    await _prefs.setString(
      _key,
      jsonEncode(expenses.map((e) => e.toJson()).toList()),
    );
  }
}
