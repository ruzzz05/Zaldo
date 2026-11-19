import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaldo/data/expense_repository.dart';
import 'package:zaldo/domain/category.dart';
import 'package:zaldo/state/expense_store.dart';
import 'package:zaldo/ui/app.dart';

Future<ExpenseStore> seededStore({bool seed = true}) async {
  final s = ExpenseStore(
    InMemoryExpenseRepository(),
    now: () => DateTime(2026, 11, 18),
  );
  if (seed) {
    await s.add(
      cents: 450,
      category: Category.alimentacion,
      date: DateTime(2026, 11, 17),
      description: 'café',
    );
    await s.add(
      cents: 1200,
      category: Category.transporte,
      date: DateTime(2026, 11, 10),
      description: 'tren',
    );
    await s.add(
      cents: 2500,
      category: Category.ocio,
      date: DateTime(2026, 11, 5),
    );
    await s.add(
      cents: 999,
      category: Category.otros,
      date: DateTime(2026, 10, 20),
    );
  }
  return s;
}

Future<void> pumpApp(
  WidgetTester tester,
  ExpenseStore store, {
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = const Size(411 * 2.625, 891 * 2.625);
  tester.view.devicePixelRatio = 2.625;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ZaldoApp(store: store, now: () => DateTime(2026, 11, 18)),
  );
  await tester.pumpAndSettle();
}
