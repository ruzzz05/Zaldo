import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaldo/domain/category.dart';
import 'package:zaldo/ui/category_style.dart';
import 'package:zaldo/ui/contrast.dart';
import 'package:zaldo/ui/theme.dart';

import 'a11y_test.dart' show guidelines;
import 'helpers.dart';

Future<void> addExpenses(dynamic store) async {
  await store.add(
    cents: 450,
    category: Category.alimentacion,
    date: DateTime(2026, 11, 17),
  );
  await store.add(
    cents: 1200,
    category: Category.transporte,
    date: DateTime(2026, 11, 17),
  );
  await store.add(
    cents: 999,
    category: Category.ocio,
    date: DateTime(2026, 11, 18),
  );
}

void main() {
  group('Paleta de categorías (RNF01, RNF03)', () {
    test('cada categoría tiene un color distinto', () {
      final colors = Category.values.map((c) => c.color).toSet();
      expect(colors.length, Category.values.length);
    });

    test('cada color contrasta >= 3:1 con la tarjeta blanca', () {
      for (final c in Category.values) {
        expect(
          contrastRatio(c.color, AppColors.card),
          greaterThanOrEqualTo(3.0),
          reason: c.label,
        );
      }
    });

    test('cada categoría tiene un patrón distinto (no solo color)', () {
      final patterns = Category.values.map((c) => c.pattern).toSet();
      expect(patterns.length, Category.values.length);
    });
  });

  group('Gráfico diario en Inicio', () {
    testWidgets('muestra título, leyenda con las 5 categorías', (t) async {
      final store = await seededStore();
      await addExpenses(store);
      await pumpApp(t, store);
      await t.scrollUntilVisible(
        find.text('Gasto de los últimos 7 días'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Gasto de los últimos 7 días'), findsOneWidget);
      for (final c in Category.values) {
        expect(
          find.descendant(
            of: find.byKey(const Key('chart-legend')),
            matching: find.text(c.label),
            skipOffstage: false,
          ),
          findsOneWidget,
          reason: c.label,
        );
      }
    });

    testWidgets('alternativa textual: lista de totales por día', (t) async {
      final store = await seededStore(seed: false);
      await addExpenses(store);
      await pumpApp(t, store);
      await t.scrollUntilVisible(
        find.byKey(const Key('chart-days')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('17,49 €', skipOffstage: false), findsNothing);
      expect(
        find.textContaining('16,50 €', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.textContaining('9,99 €', skipOffstage: false), findsWidgets);
    });

    testWidgets('el gráfico es un único nodo semántico con resumen', (t) async {
      final h = t.ensureSemantics();
      final store = await seededStore(seed: false);
      await addExpenses(store);
      await pumpApp(t, store);
      await t.scrollUntilVisible(
        find.byKey(const Key('chart-bars')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final node = t.getSemantics(find.byKey(const Key('chart-bars')));
      expect(node.label, contains('Gráfico de barras'));
      expect(node.label, contains('últimos 7 días'));
      expect(node.label, contains('26 euros con 49 céntimos'));
      h.dispose();
    });

    testWidgets('sin gastos en 7 días muestra mensaje, no barras vacías', (
      t,
    ) async {
      await pumpApp(t, await seededStore(seed: false));
      await t.scrollUntilVisible(
        find.text('No hay gastos en los últimos 7 días'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('chart-bars')), findsNothing);
    });

    for (final scale in [1.0, 2.0, 3.0]) {
      testWidgets('inicio con gráfico @${scale}x cumple guidelines', (t) async {
        final h = t.ensureSemantics();
        final store = await seededStore();
        await addExpenses(store);
        await pumpApp(t, store, textScale: scale);
        await t.scrollUntilVisible(
          find.byKey(const Key('chart-days')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await guidelines(t);
        expect(t.takeException(), isNull);
        h.dispose();
      });
    }
  });
}
