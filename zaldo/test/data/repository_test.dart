import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaldo/data/expense_repository.dart';
import 'package:zaldo/domain/category.dart';
import 'package:zaldo/domain/expense.dart';

Expense ex(String id) => Expense(
  id: id,
  amountCents: 100,
  category: Category.ocio,
  date: DateTime(2026, 1, 1),
);

void main() {
  test('prefs repository persists across instances (RNF11)', () async {
    SharedPreferences.setMockInitialValues({});
    final a = PrefsExpenseRepository(await SharedPreferences.getInstance());
    await a.save([ex('1'), ex('2')]);
    final b = PrefsExpenseRepository(await SharedPreferences.getInstance());
    expect((await b.load()).map((e) => e.id), ['1', '2']);
  });
  test('load returns empty when nothing stored', () async {
    SharedPreferences.setMockInitialValues({});
    final r = PrefsExpenseRepository(await SharedPreferences.getInstance());
    expect(await r.load(), isEmpty);
  });
  test('corrupt data yields empty list instead of crash', () async {
    SharedPreferences.setMockInitialValues({'expenses_v1': 'not json'});
    final r = PrefsExpenseRepository(await SharedPreferences.getInstance());
    expect(await r.load(), isEmpty);
  });
  test('in-memory repository round trips', () async {
    final r = InMemoryExpenseRepository();
    await r.save([ex('1')]);
    expect((await r.load()).single.id, '1');
  });
}
