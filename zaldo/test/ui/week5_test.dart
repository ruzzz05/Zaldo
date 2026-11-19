import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaldo/data/expense_repository.dart';
import 'package:zaldo/domain/expense.dart';
import 'package:zaldo/state/expense_store.dart';
import 'package:zaldo/ui/app.dart';
import 'package:zaldo/ui/widgets.dart';

import 'a11y_test.dart' show guidelines, tapScroll, toAdd, toSummary;
import 'helpers.dart';

/// Repository whose save() completes only when the test says so.
class SlowRepository extends InMemoryExpenseRepository {
  final gate = Completer<void>();
  int saves = 0;
  @override
  Future<void> save(List<Expense> expenses) async {
    saves++;
    await gate.future;
    await super.save(expenses);
  }
}

/// Labels of the semantics nodes, in screen-reader traversal order.
List<String> readingOrder(WidgetTester t) {
  final out = <String>[];
  void walk(SemanticsNode n) {
    if (n.label.isNotEmpty) out.add(n.label);
    n.visitChildren((c) {
      walk(c);
      return true;
    });
  }

  walk(t.getSemantics(find.byType(Scaffold).first));
  return out;
}

int indexOfLabel(List<String> labels, String part) {
  final i = labels.indexWhere((l) => l.contains(part));
  expect(i, greaterThanOrEqualTo(0), reason: '"$part" not in $labels');
  return i;
}

void main() {
  group('Escala de texto muy aumentada', () {
    for (final name in ['añadir', 'resumen']) {
      testWidgets('$name @3x: operable, sin overflow', (t) async {
        final h = t.ensureSemantics();
        await pumpApp(t, await seededStore(), textScale: 3.0);
        await (name == 'añadir' ? toAdd(t) : toSummary(t));
        await guidelines(t);
        expect(t.takeException(), isNull);
        h.dispose();
      });
    }

    testWidgets('app does not clamp the system text scale', (t) async {
      await pumpApp(t, await seededStore(), textScale: 2.0);
      final ctx = t.element(find.byType(Scaffold).first);
      expect(MediaQuery.textScalerOf(ctx).scale(10), 20);
    });
  });

  group('Orden de lectura', () {
    testWidgets('resumen: mes, total y desglose (RNF08)', (t) async {
      final h = t.ensureSemantics();
      await pumpApp(t, await seededStore());
      await toSummary(t);
      final l = readingOrder(t);
      final title = indexOfLabel(l, 'Resumen económico');
      final month = indexOfLabel(l, 'oviembre');
      final total = indexOfLabel(l, 'Total gastado');
      final breakdown = indexOfLabel(l, 'Gasto por categoría');
      final firstCat = indexOfLabel(l, 'Ocio:');
      expect(title < month, isTrue);
      expect(month < total, isTrue);
      expect(total < breakdown, isTrue);
      expect(breakdown < firstCat, isTrue);
      h.dispose();
    });

    testWidgets('añadir: importe, categoría, fecha, guardar, cancelar', (
      t,
    ) async {
      final h = t.ensureSemantics();
      await pumpApp(t, await seededStore());
      await toAdd(t);
      final l = readingOrder(t);
      final order = [
        indexOfLabel(l, 'Importe'),
        indexOfLabel(l, 'Categoría'),
        indexOfLabel(l, 'Alimentación'),
        indexOfLabel(l, 'Fecha'),
        indexOfLabel(l, 'Guardar gasto'),
        indexOfLabel(l, 'Cancelar'),
      ];
      expect(order, [...order]..sort());
      h.dispose();
    });

    testWidgets('barra decorativa del resumen no añade ruido', (t) async {
      final h = t.ensureSemantics();
      await pumpApp(t, await seededStore());
      await toSummary(t);
      final l = readingOrder(t);
      expect(l.where((s) => s.contains('Ocio')).length, 1);
      h.dispose();
    });
  });

  group('Estados y feedback', () {
    testWidgets('mes siguiente deshabilitado en el mes actual', (t) async {
      final h = t.ensureSemantics();
      await pumpApp(t, await seededStore());
      await toSummary(t);
      final node = t.getSemantics(find.byTooltip('Mes siguiente'));
      expect(node.flagsCollection.isEnabled == Tristate.isFalse, isTrue);
      expect(node.flagsCollection.isButton, isTrue);
      h.dispose();
    });

    testWidgets('guardar deshabilitado y anunciado mientras guarda', (t) async {
      final h = t.ensureSemantics();
      final repo = SlowRepository();
      final store = ExpenseStore(repo, now: () => DateTime(2026, 11, 18));
      await pumpApp(t, store);
      await t.tap(find.text('Añadir gasto'));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('amount')), '4,50');
      await t.tap(find.text('Alimentación'));
      await t.pump();
      await t.tap(find.text('Guardar gasto'));
      await t.pump();
      // second tap while the first save is pending
      await t.tap(find.text('Guardando…'), warnIfMissed: false);
      await t.pump();
      expect(repo.saves, 1, reason: 'double tap must not save twice');
      expect(find.text('Guardando…'), findsOneWidget);
      final node = t.getSemantics(find.text('Guardando…'));
      expect(node.flagsCollection.isEnabled == Tristate.isFalse, isTrue);
      repo.gate.complete();
      await t.pumpAndSettle();
      expect(store.all, hasLength(1));
      expect(find.text('Gasto guardado'), findsOneWidget);
      h.dispose();
    });

    testWidgets('confirmación "Gasto guardado" está en el árbol semántico', (
      t,
    ) async {
      final h = t.ensureSemantics();
      final store = await seededStore(seed: false);
      await pumpApp(t, store);
      await t.tap(find.text('Añadir gasto'));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('amount')), '4,50');
      await t.tap(find.text('Alimentación'));
      await t.pump();
      await tapScroll(t, find.text('Guardar gasto'));
      expect(readingOrder(t).any((s) => s.contains('Gasto guardado')), isTrue);
      h.dispose();
    });

    testWidgets('error de importe: icono+texto y región viva', (t) async {
      final h = t.ensureSemantics();
      await pumpApp(t, await seededStore());
      await toAdd(t);
      await tapScroll(t, find.text('Guardar gasto'));
      final node = t.getSemantics(find.byType(ErrorLine).first);
      expect(node.label, contains('Error:'));
      expect(node.flagsCollection.isLiveRegion, isTrue);
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
      h.dispose();
    });
  });

  // Keep ZaldoApp import used for clarity of what is under test.
  test('ZaldoApp is the unit under test', () {
    expect(ZaldoApp, isNotNull);
  });
}
