import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<void> guidelines(WidgetTester t) async {
  await expectLater(t, meetsGuideline(androidTapTargetGuideline));
  await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(t, meetsGuideline(textContrastGuideline));
}

Future<void> tapScroll(WidgetTester t, Finder f) async {
  await t.dragUntilVisible(
    f,
    find.byType(ListView).last,
    const Offset(0, -150),
  );
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
}

Future<void> toAdd(WidgetTester t) async {
  await tapScroll(t, find.text('Añadir gasto'));
}

Future<void> toHistory(WidgetTester t) async {
  await tapScroll(t, find.text('Ver gastos uno a uno'));
}

Future<void> toFilter(WidgetTester t) async {
  await toHistory(t);
  await t.tap(find.byTooltip('Filtrar gastos'));
  await t.pumpAndSettle();
}

Future<void> toDetail(WidgetTester t) async {
  await toHistory(t);
  await t.tap(find.textContaining('12,00 €'));
  await t.pumpAndSettle();
}

Future<void> toSummary(WidgetTester t) async {
  await tapScroll(
    t,
    find.text('Ver el total del mes y el gasto por categoría'),
  );
}

final screens = <String, Future<void> Function(WidgetTester)>{
  'inicio': (t) async {},
  'añadir': toAdd,
  'historial': toHistory,
  'filtrar': toFilter,
  'detalle': toDetail,
  'resumen': toSummary,
};

void main() {
  for (final e in screens.entries) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('${e.key} @${scale}x: guidelines (RNF01,02,04,05)', (
        t,
      ) async {
        final h = t.ensureSemantics();
        await pumpApp(t, await seededStore(), textScale: scale);
        await e.value(t);
        await guidelines(t);
        expect(t.takeException(), isNull);
        h.dispose();
      });
    }
  }

  testWidgets('añadir with errors @2x has no overflow', (t) async {
    await pumpApp(t, await seededStore(), textScale: 2.0);
    await toAdd(t);
    await tapScroll(t, find.text('Guardar gasto'));
    expect(t.takeException(), isNull);
    expect(
      find.text('Elige una categoría.', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('category chips expose name and selected state (RNF04)', (
    t,
  ) async {
    final h = t.ensureSemantics();
    await pumpApp(t, await seededStore());
    await toAdd(t);
    await t.tap(find.text('Ocio'));
    await t.pump();
    final node = t.getSemantics(find.text('Ocio'));
    expect(node.label, contains('Ocio'));
    expect(node.flagsCollection.isSelected == Tristate.isTrue, isTrue);
    h.dispose();
  });
}
