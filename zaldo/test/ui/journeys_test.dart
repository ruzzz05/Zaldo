import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaldo/domain/category.dart';

import 'helpers.dart';

void main() {
  group('Inicio', () {
    testWidgets('shows three accesses with explanatory text', (t) async {
      await pumpApp(t, await seededStore());
      expect(find.text('Añadir gasto'), findsOneWidget);
      expect(find.text('Historial'), findsWidgets);
      expect(find.text('Ver gastos uno a uno'), findsOneWidget);
      expect(find.text('Resumen económico'), findsOneWidget);
      expect(
        find.text('Ver el total del mes y el gasto por categoría'),
        findsOneWidget,
      );
    });
    testWidgets('shows last expense card', (t) async {
      await pumpApp(t, await seededStore());
      expect(find.text('Último gasto'), findsOneWidget);
      expect(find.textContaining('9,99 €'), findsOneWidget);
    });
    testWidgets('empty state without expenses', (t) async {
      await pumpApp(t, await seededStore(seed: false));
      expect(
        find.text('Todavía no has registrado ningún gasto'),
        findsOneWidget,
      );
    });
  });

  group('Recorrido 1: registrar gasto', () {
    testWidgets('saves a coffee and confirms', (t) async {
      final store = await seededStore(seed: false);
      await pumpApp(t, store);
      await t.tap(find.text('Añadir gasto'));
      await t.pumpAndSettle();
      expect(find.text('Importe (€)'), findsOneWidget);
      expect(
        find.text('Cafés, comidas y supermercado: Alimentación'),
        findsOneWidget,
      );
      await t.enterText(find.byKey(const Key('amount')), '4,50');
      await t.tap(find.text('Alimentación'));
      await t.pump();
      await t.tap(find.text('Guardar gasto'));
      await t.pumpAndSettle();
      expect(store.all.single.amountCents, 450);
      expect(store.all.single.category, Category.alimentacion);
      expect(find.text('Gasto guardado'), findsOneWidget);
      expect(find.text('Último gasto'), findsOneWidget);
    });
    testWidgets('date defaults to today (RF02)', (t) async {
      await pumpApp(t, await seededStore(seed: false));
      await t.tap(find.text('Añadir gasto'));
      await t.pumpAndSettle();
      expect(find.textContaining('18 de noviembre de 2026'), findsOneWidget);
      expect(find.text('Cambiar fecha'), findsOneWidget);
    });
    testWidgets(
      'empty form shows errors with icon and text, keeps data (RNF07)',
      (t) async {
        final store = await seededStore(seed: false);
        await pumpApp(t, store);
        await t.tap(find.text('Añadir gasto'));
        await t.pumpAndSettle();
        await t.enterText(find.byKey(const Key('description')), 'comida');
        await t.tap(find.text('Guardar gasto'));
        await t.pumpAndSettle();
        expect(
          find.text('Escribe el importe. Por ejemplo: 4,50.'),
          findsOneWidget,
        );
        expect(find.text('Elige una categoría.'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(2));
        expect(find.text('comida'), findsOneWidget);
        expect(store.all, isEmpty);
      },
    );
    testWidgets('zero amount message, then correct and save', (t) async {
      final store = await seededStore(seed: false);
      await pumpApp(t, store);
      await t.tap(find.text('Añadir gasto'));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('amount')), '0');
      await t.tap(find.text('Ocio'));
      await t.pump();
      await t.tap(find.text('Guardar gasto'));
      await t.pumpAndSettle();
      expect(
        find.text(
          'El importe debe ser mayor que 0. Escribe un valor como 4,50.',
        ),
        findsOneWidget,
      );
      await t.enterText(find.byKey(const Key('amount')), '3');
      await t.tap(find.text('Guardar gasto'));
      await t.pumpAndSettle();
      expect(store.all.single.amountCents, 300);
    });
    testWidgets('invalid format message', (t) async {
      await pumpApp(t, await seededStore(seed: false));
      await t.tap(find.text('Añadir gasto'));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('amount')), 'abc');
      await t.tap(find.text('Guardar gasto'));
      await t.pumpAndSettle();
      expect(
        find.text('El importe no es válido. Escribe un valor como 4,50.'),
        findsOneWidget,
      );
    });
    testWidgets('cancel returns without saving', (t) async {
      final store = await seededStore(seed: false);
      await pumpApp(t, store);
      await t.tap(find.text('Añadir gasto'));
      await t.pumpAndSettle();
      await t.tap(find.text('Cancelar'));
      await t.pumpAndSettle();
      expect(find.text('Último gasto'), findsNothing);
      expect(find.text('Añadir gasto'), findsOneWidget);
      expect(store.all, isEmpty);
    });
    testWidgets('selected category shows check (RNF03)', (t) async {
      await pumpApp(t, await seededStore(seed: false));
      await t.tap(find.text('Añadir gasto'));
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsNothing);
      await t.tap(find.text('Ocio'));
      await t.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('Recorrido 2: historial', () {
    Future<void> openHistory(WidgetTester t) async {
      await t.tap(find.text('Ver gastos uno a uno'));
      await t.pumpAndSettle();
    }

    testWidgets('lists newest first with date, amount and category name', (
      t,
    ) async {
      await pumpApp(t, await seededStore());
      await openHistory(t);
      final tops = [
        '4,50 €',
        '12,00 €',
        '25,00 €',
        '9,99 €',
      ].map((s) => t.getTopLeft(find.textContaining(s).first).dy).toList();
      expect(
        tops[0] < tops[1] && tops[1] < tops[2] && tops[2] < tops[3],
        isTrue,
      );
      expect(find.text('Alimentación'), findsOneWidget);
      expect(find.textContaining('17/11/2026'), findsOneWidget);
    });
    testWidgets('no delete button in list', (t) async {
      await pumpApp(t, await seededStore());
      await openHistory(t);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.text('Eliminar gasto'), findsNothing);
    });
    testWidgets('filter by category and clear', (t) async {
      await pumpApp(t, await seededStore());
      await openHistory(t);
      await t.tap(find.byTooltip('Filtrar gastos'));
      await t.pumpAndSettle();
      expect(find.text('Desde'), findsWidgets);
      expect(find.text('Hasta'), findsWidgets);
      await t.tap(find.text('Transporte'));
      await t.pump();
      await t.tap(find.text('Aplicar filtros'));
      await t.pumpAndSettle();
      expect(find.textContaining('12,00 €'), findsOneWidget);
      expect(find.textContaining('4,50 €'), findsNothing);
      expect(find.textContaining('Filtro activo'), findsOneWidget);
      await t.tap(find.text('Limpiar filtros'));
      await t.pumpAndSettle();
      expect(find.textContaining('4,50 €'), findsOneWidget);
      expect(find.textContaining('Filtro activo'), findsNothing);
    });
    testWidgets('filter cancel keeps previous filter', (t) async {
      final store = await seededStore();
      await pumpApp(t, store);
      await openHistory(t);
      await t.tap(find.byTooltip('Filtrar gastos'));
      await t.pumpAndSettle();
      await t.tap(find.text('Ocio'));
      await t.pump();
      await t.tap(find.text('Cancelar'));
      await t.pumpAndSettle();
      expect(store.filter.isActive, isFalse);
    });
    testWidgets('date range filter via date pickers', (t) async {
      final store = await seededStore();
      await pumpApp(t, store);
      await openHistory(t);
      await t.tap(find.byTooltip('Filtrar gastos'));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('filter-from')));
      await t.pumpAndSettle();
      await t.tap(find.text('10'));
      await t.tap(find.text('ACEPTAR'));
      await t.pumpAndSettle();
      await t.tap(find.text('Aplicar filtros'));
      await t.pumpAndSettle();
      expect(store.filter.from, DateTime(2026, 11, 10));
      expect(store.visible.length, 2);
    });
    testWidgets('empty result message (RF09)', (t) async {
      final store = await seededStore(seed: false);
      await pumpApp(t, store);
      await t.tap(find.text('Ver gastos uno a uno'));
      await t.pumpAndSettle();
      expect(find.text('No hay gastos que mostrar'), findsOneWidget);
    });
    testWidgets('detail shows all data and back keeps filters', (t) async {
      final store = await seededStore();
      await pumpApp(t, store);
      await openHistory(t);
      await t.tap(find.byTooltip('Filtrar gastos'));
      await t.pumpAndSettle();
      await t.tap(find.text('Transporte'));
      await t.pump();
      await t.tap(find.text('Aplicar filtros'));
      await t.pumpAndSettle();
      await t.tap(find.textContaining('12,00 €'));
      await t.pumpAndSettle();
      expect(find.text('Detalle del gasto'), findsOneWidget);
      expect(find.text('tren'), findsOneWidget);
      expect(find.text('10 de noviembre de 2026'), findsOneWidget);
      await t.tap(find.text('Volver al historial'));
      await t.pumpAndSettle();
      expect(store.filter.isActive, isTrue);
      expect(find.textContaining('Filtro activo'), findsOneWidget);
    });
    testWidgets('delete from detail asks confirmation', (t) async {
      final store = await seededStore();
      await pumpApp(t, store);
      await openHistory(t);
      await t.tap(find.textContaining('12,00 €'));
      await t.pumpAndSettle();
      await t.tap(find.text('Eliminar gasto'));
      await t.pumpAndSettle();
      expect(find.text('¿Eliminar este gasto?'), findsOneWidget);
      await t.tap(find.text('Cancelar'));
      await t.pumpAndSettle();
      expect(store.all.length, 4);
      await t.tap(find.text('Eliminar gasto'));
      await t.pumpAndSettle();
      await t.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Eliminar gasto'),
        ),
      );
      await t.pumpAndSettle();
      expect(store.all.length, 3);
      expect(find.text('Detalle del gasto'), findsNothing);
    });
  });

  group('Recorrido 3: resumen', () {
    Future<void> openSummary(WidgetTester t) async {
      await t.tap(find.text('Ver el total del mes y el gasto por categoría'));
      await t.pumpAndSettle();
    }

    testWidgets('month, total and breakdown in order', (t) async {
      await pumpApp(t, await seededStore());
      await openSummary(t);
      double y(String s) => t.getTopLeft(find.textContaining(s).first).dy;
      expect(find.text('Noviembre de 2026'), findsOneWidget);
      expect(y('Noviembre de 2026') < y('Total gastado'), isTrue);
      expect(find.textContaining('41,50 €'), findsWidgets);
      expect(y('Ocio') < y('Transporte'), isTrue);
      expect(y('Transporte') < y('Alimentación'), isTrue);
    });
    testWidgets('previous month button changes period', (t) async {
      await pumpApp(t, await seededStore());
      await openSummary(t);
      await t.tap(find.byTooltip('Mes anterior'));
      await t.pumpAndSettle();
      expect(find.text('Octubre de 2026'), findsOneWidget);
      expect(find.textContaining('9,99 €'), findsWidgets);
      await t.tap(find.byTooltip('Mes siguiente'));
      await t.pumpAndSettle();
      expect(find.text('Noviembre de 2026'), findsOneWidget);
    });
    testWidgets('empty month message (RF09)', (t) async {
      await pumpApp(t, await seededStore());
      await openSummary(t);
      await t.tap(find.byTooltip('Mes anterior'));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Mes anterior'));
      await t.pumpAndSettle();
      expect(find.text('No hay gastos en este mes'), findsOneWidget);
    });
    testWidgets('percentage given as text', (t) async {
      await pumpApp(t, await seededStore());
      await openSummary(t);
      expect(find.textContaining('%'), findsWidgets);
    });
  });

  group('Barra inferior', () {
    testWidgets('has three labelled destinations', (t) async {
      await pumpApp(t, await seededStore());
      final bar = find.byType(NavigationBar);
      for (final l in ['Inicio', 'Historial', 'Resumen']) {
        expect(
          find.descendant(of: bar, matching: find.text(l)),
          findsOneWidget,
        );
      }
      await t.tap(find.descendant(of: bar, matching: find.text('Resumen')));
      await t.pumpAndSettle();
      expect(find.text('Resumen económico'), findsOneWidget);
    });
  });
}
