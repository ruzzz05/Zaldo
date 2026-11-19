import 'package:flutter/material.dart';

import '../domain/category.dart';
import '../domain/daily_spending.dart';
import '../domain/format.dart';
import 'category_style.dart';
import 'theme.dart';
import 'widgets.dart';

const kChartDays = 7;
const _barAreaHeight = 150.0;

/// Stacked daily bar chart. Colour + pattern per category, a legend, a single
/// summary node for screen readers and a text list as equivalent alternative.
class DailyChart extends StatelessWidget {
  const DailyChart({super.key, required this.days});
  final List<DaySpending> days;

  int get _total => days.fold(0, (a, d) => a + d.totalCents);

  String get _summary {
    final top = days.reduce((a, b) => b.totalCents > a.totalCents ? b : a);
    return 'Gráfico de barras: gasto de los últimos $kChartDays días. '
        'Total ${spokenEuros(_total)}. '
        'Mayor gasto el ${spokenDay(top.date)}: ${spokenEuros(top.totalCents)}. '
        'Los detalles por día están en la lista siguiente.';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Gasto de los últimos 7 días',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: kGap),
            if (_total == 0)
              const Text(
                'No hay gastos en los últimos 7 días',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              )
            else ...[
              _Bars(days: days, summary: _summary),
              const SizedBox(height: kPad),
              const _Legend(key: Key('chart-legend')),
              const SizedBox(height: kPad),
              _DayList(key: const Key('chart-days'), days: days),
            ],
          ],
        ),
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars({required this.days, required this.summary});
  final List<DaySpending> days;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final maxCents = days
        .map((d) => d.totalCents)
        .reduce((a, b) => a > b ? a : b);
    return Semantics(
      key: const Key('chart-bars'),
      label: summary,
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in days)
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: _barAreaHeight,
                    width: double.infinity,
                    child: CustomPaint(painter: _BarPainter(d, maxCents)),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${weekdayInitial(d.date)}\n${d.date.day}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.day, this.maxCents);
  final DaySpending day;
  final int maxCents;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = AppColors.fieldBorder
        ..strokeWidth = 2,
    );
    if (day.totalCents == 0) return;
    final barW = size.width * 0.7;
    final left = (size.width - barW) / 2;
    final usable = size.height - 2;
    var bottom = usable;
    for (final e in day.byCategory.entries) {
      final h = usable * e.value / maxCents;
      final rect = Rect.fromLTRB(left, bottom - h, left + barW, bottom);
      paintPatternRect(canvas, rect, e.key.color, e.key.pattern);
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = AppColors.card,
      );
      bottom -= h;
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.day != day || old.maxCents != maxCents;
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.category);
  final Category category;
  @override
  void paint(Canvas canvas, Size size) {
    paintPatternRect(
      canvas,
      Offset.zero & size,
      category.color,
      category.pattern,
    );
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => old.category != category;
}

class _Legend extends StatelessWidget {
  const _Legend({super.key});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final c in Category.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CustomPaint(painter: _SwatchPainter(c)),
                ),
              ),
              const SizedBox(width: 6),
              Icon(c.icon, size: 18, color: AppColors.text),
              const SizedBox(width: 4),
              Flexible(
                child: Text(c.label, style: const TextStyle(fontSize: 15)),
              ),
            ],
          ),
      ],
    );
  }
}

class _DayList extends StatelessWidget {
  const _DayList({super.key, required this.days});
  final List<DaySpending> days;
  @override
  Widget build(BuildContext context) {
    final withSpending = days.reversed.where((d) => d.totalCents > 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final d in withSpending)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Semantics(
              label: '${spokenDay(d.date)}: ${spokenEuros(d.totalCents)}',
              excludeSemantics: true,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${weekdayName(d.date)} ${d.date.day}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    formatEuros(d.totalCents),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
