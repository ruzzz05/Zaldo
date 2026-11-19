import 'package:flutter_test/flutter_test.dart';
import 'package:zaldo/data/expense_repository.dart';
import 'package:zaldo/domain/amount_parser.dart';
import 'package:zaldo/domain/category.dart';
import 'package:zaldo/domain/expense_filter.dart';
import 'package:zaldo/state/expense_store.dart';

Future<ExpenseStore> newStore([ExpenseRepository? repo]) async {
  final s = ExpenseStore(
    repo ?? InMemoryExpenseRepository(),
    now: () => DateTime(2026, 11, 18),
  );
  await s.load();
  return s;
}

void main() {
  group('validateDraft', () {
    test('reports amount and category errors together', () {
      final v = validateDraft(amountText: '', category: null);
      expect(v.amountError, AmountError.empty);
      expect(v.categoryMissing, isTrue);
      expect(v.isValid, isFalse);
    });
    test('valid draft', () {
      final v = validateDraft(amountText: '4,50', category: Category.ocio);
      expect(v.isValid, isTrue);
      expect(v.cents, 450);
    });
    test('zero amount invalid', () {
      expect(
        validateDraft(amountText: '0', category: Category.ocio).amountError,
        AmountError.notPositive,
      );
    });
  });

  group('ExpenseStore', () {
    test('add stores expense and persists it', () async {
      final repo = InMemoryExpenseRepository();
      final s = await newStore(repo);
      await s.add(
        cents: 450,
        category: Category.alimentacion,
        date: DateTime(2026, 11, 18),
        description: 'café',
      );
      expect(s.all.length, 1);
      expect((await repo.load()).single.description, 'café');
    });
    test('list ordered newest first', () async {
      final s = await newStore();
      await s.add(
        cents: 1,
        category: Category.ocio,
        date: DateTime(2026, 11, 1),
      );
      await s.add(
        cents: 2,
        category: Category.ocio,
        date: DateTime(2026, 11, 9),
      );
      await s.add(
        cents: 3,
        category: Category.ocio,
        date: DateTime(2026, 11, 5),
      );
      expect(s.visible.map((e) => e.amountCents), [2, 3, 1]);
    });
    test('filter applies to visible and can be cleared', () async {
      final s = await newStore();
      await s.add(
        cents: 1,
        category: Category.ocio,
        date: DateTime(2026, 11, 1),
      );
      await s.add(
        cents: 2,
        category: Category.transporte,
        date: DateTime(2026, 11, 2),
      );
      s.setFilter(const ExpenseFilter(category: Category.transporte));
      expect(s.visible.length, 1);
      expect(s.filter.isActive, isTrue);
      s.clearFilter();
      expect(s.visible.length, 2);
    });
    test('delete removes and persists', () async {
      final repo = InMemoryExpenseRepository();
      final s = await newStore(repo);
      await s.add(
        cents: 1,
        category: Category.ocio,
        date: DateTime(2026, 11, 1),
      );
      await s.delete(s.all.single.id);
      expect(s.all, isEmpty);
      expect(await repo.load(), isEmpty);
    });
    test('load restores previous data', () async {
      final repo = InMemoryExpenseRepository();
      final a = await newStore(repo);
      await a.add(
        cents: 7,
        category: Category.otros,
        date: DateTime(2026, 11, 1),
      );
      final b = await newStore(repo);
      expect(b.all.single.amountCents, 7);
    });
    test('summary follows selected month, default current month', () async {
      final s = await newStore();
      await s.add(
        cents: 100,
        category: Category.ocio,
        date: DateTime(2026, 11, 1),
      );
      await s.add(
        cents: 900,
        category: Category.ocio,
        date: DateTime(2026, 10, 1),
      );
      expect(s.summary.totalCents, 100);
      s.setMonth(DateTime(2026, 10, 15));
      expect(s.summary.totalCents, 900);
    });
    test('last expense is most recently added', () async {
      final s = await newStore();
      expect(s.lastExpense, isNull);
      await s.add(
        cents: 1,
        category: Category.ocio,
        date: DateTime(2026, 11, 9),
      );
      await s.add(
        cents: 2,
        category: Category.ocio,
        date: DateTime(2026, 11, 1),
      );
      expect(s.lastExpense!.amountCents, 2);
    });
    test('get by id', () async {
      final s = await newStore();
      await s.add(
        cents: 1,
        category: Category.ocio,
        date: DateTime(2026, 11, 9),
      );
      expect(s.byId(s.all.single.id), isNotNull);
      expect(s.byId('nope'), isNull);
    });
    test('1000 expenses: filter and summary under 2s (RNF13)', () async {
      final s = await newStore();
      for (var i = 0; i < 1000; i++) {
        await s.add(
          cents: 100 + i,
          category: Category.values[i % 5],
          date: DateTime(2026, 11, 1 + i % 28),
        );
      }
      final sw = Stopwatch()..start();
      s.setFilter(const ExpenseFilter(category: Category.ocio));
      final n = s.visible.length;
      final t = s.summary.totalCents;
      sw.stop();
      expect(n, 200);
      expect(t, greaterThan(0));
      expect(sw.elapsedMilliseconds, lessThan(2000));
    });
  });
}
