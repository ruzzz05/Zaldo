import 'package:flutter_test/flutter_test.dart';
import 'package:zaldo/domain/category.dart';
import 'package:zaldo/domain/expense.dart';
import 'package:zaldo/domain/expense_filter.dart';
import 'package:zaldo/domain/summary.dart';

Expense e(String id, int cents, Category c, DateTime d, [String desc = '']) =>
    Expense(
      id: id,
      amountCents: cents,
      category: c,
      date: d,
      description: desc,
    );

void main() {
  group('Expense', () {
    test('json round trip keeps all fields', () {
      final x = e(
        '1',
        450,
        Category.alimentacion,
        DateTime(2026, 11, 3),
        'café',
      );
      final y = Expense.fromJson(x.toJson());
      expect(y.id, '1');
      expect(y.amountCents, 450);
      expect(y.category, Category.alimentacion);
      expect(y.date, DateTime(2026, 11, 3));
      expect(y.description, 'café');
    });
  });

  group('Category', () {
    test('alimentacion hint explains what it includes', () {
      expect(Category.alimentacion.hint, 'Cafés, comidas y supermercado');
    });
    test('every category has label, icon and hint', () {
      for (final c in Category.values) {
        expect(c.label, isNotEmpty);
        expect(c.hint, isNotEmpty);
      }
    });
  });

  group('ExpenseFilter', () {
    final list = [
      e('a', 100, Category.transporte, DateTime(2026, 11, 2)),
      e('b', 200, Category.ocio, DateTime(2026, 11, 5)),
      e('c', 300, Category.transporte, DateTime(2026, 11, 9)),
    ];
    test('empty filter returns everything', () {
      expect(const ExpenseFilter().apply(list).length, 3);
      expect(const ExpenseFilter().isActive, isFalse);
    });
    test('category filter', () {
      final r = ExpenseFilter(category: Category.transporte).apply(list);
      expect(r.map((x) => x.id), ['a', 'c']);
    });
    test('date range is inclusive on both ends', () {
      final r = ExpenseFilter(
        from: DateTime(2026, 11, 5),
        to: DateTime(2026, 11, 9),
      ).apply(list);
      expect(r.map((x) => x.id), ['b', 'c']);
    });
    test('combined filters', () {
      final r = ExpenseFilter(
        category: Category.transporte,
        from: DateTime(2026, 11, 3),
      ).apply(list);
      expect(r.map((x) => x.id), ['c']);
    });
    test('hour of day is ignored', () {
      final r = ExpenseFilter(to: DateTime(2026, 11, 2))
          .apply([e('z', 1, Category.otros, DateTime(2026, 11, 2, 23, 59))]);
      expect(r.length, 1);
    });
  });

  group('MonthlySummary', () {
    test('totals only selected month and sorts categories desc', () {
      final s = MonthlySummary.of([
        e('1', 500, Category.ocio, DateTime(2026, 11, 1)),
        e('2', 1500, Category.alimentacion, DateTime(2026, 11, 30)),
        e('3', 250, Category.ocio, DateTime(2026, 11, 15)),
        e('4', 9999, Category.otros, DateTime(2026, 10, 31)),
      ], DateTime(2026, 11, 20));
      expect(s.totalCents, 2250);
      expect(s.byCategory.map((x) => x.category), [
        Category.alimentacion,
        Category.ocio,
      ]);
      expect(s.byCategory.last.cents, 750);
      expect(s.isEmpty, isFalse);
    });
    test('empty month', () {
      final s = MonthlySummary.of([], DateTime(2026, 11, 1));
      expect(s.isEmpty, isTrue);
      expect(s.totalCents, 0);
    });
  });
}
