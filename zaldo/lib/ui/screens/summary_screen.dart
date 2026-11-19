import 'package:flutter/material.dart';

import '../../domain/format.dart';
import '../../state/expense_store.dart';
import '../theme.dart';
import '../widgets.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.store, required this.now});
  final ExpenseStore store;
  final DateTime Function() now;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final s = store.summary;
        final m = store.month;
        final n = now();
        final canNext = DateTime(
          m.year,
          m.month + 1,
        ).isBefore(DateTime(n.year, n.month + 1));
        return ListView(
          padding: const EdgeInsets.all(kPad),
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Resumen económico',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: kPad),
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Mes anterior',
                  constraints: const BoxConstraints(
                    minWidth: 56,
                    minHeight: 56,
                  ),
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () =>
                      store.setMonth(DateTime(m.year, m.month - 1)),
                ),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      formatMonth(m),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Mes siguiente',
                  constraints: const BoxConstraints(
                    minWidth: 56,
                    minHeight: 56,
                  ),
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canNext
                      ? () => store.setMonth(DateTime(m.year, m.month + 1))
                      : null,
                ),
              ],
            ),
            const SizedBox(height: kPad),
            if (s.isEmpty)
              const Card(
                child: EmptyState(
                  title: 'No hay gastos en este mes',
                  detail: 'Prueba con otro mes.',
                ),
              )
            else ...[
              Card(
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Semantics(
                    label: 'Total gastado: ${spokenEuros(s.totalCents)}',
                    excludeSemantics: true,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total gastado',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            formatEuros(s.totalCents),
                            style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: const Text(
                  'Gasto por categoría',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              for (final c in s.byCategory)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CategoryRow(
                    name: c.category.label,
                    icon: c.category.icon,
                    cents: c.cents,
                    fraction: c.cents / s.totalCents,
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.name,
    required this.icon,
    required this.cents,
    required this.fraction,
  });
  final String name;
  final IconData icon;
  final int cents;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final pct = (fraction * 100).round();
    return Semantics(
      label: '$name: ${spokenEuros(cents)}, $pct por ciento del total',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    formatEuros(cents),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$pct %',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Decorative bar: the same info is already in text.
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 8,
                  backgroundColor: AppColors.background,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
