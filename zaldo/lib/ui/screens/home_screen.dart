import 'package:flutter/material.dart';

import '../../domain/daily_spending.dart';
import '../../domain/format.dart';
import '../daily_chart.dart';
import '../../state/expense_store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.store,
    required this.now,
    required this.onHistory,
    required this.onSummary,
  });
  final ExpenseStore store;
  final DateTime Function() now;
  final VoidCallback onHistory;
  final VoidCallback onSummary;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final last = store.lastExpense;
        return ListView(
          padding: const EdgeInsets.all(kPad),
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Zaldo',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: kPad),
            _LastExpenseCard(
              child: last == null
                  ? const Text(
                      'Todavía no has registrado ningún gasto',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Semantics(
                      label:
                          'Último gasto: ${spokenEuros(last.amountCents)}, ${last.category.label}, ${formatDate(last.date)}',
                      excludeSemantics: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Último gasto',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatEuros(last.amountCents),
                            style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${last.category.label} · ${formatShortDate(last.date)}',
                            style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: kPad),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Añadir gasto'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(store: store, now: now),
                ),
              ),
            ),
            const SizedBox(height: kPad),
            _AccessButton(
              icon: Icons.list_alt,
              title: 'Historial',
              description: 'Ver gastos uno a uno',
              onTap: onHistory,
            ),
            const SizedBox(height: kGap),
            _AccessButton(
              icon: Icons.pie_chart_outline,
              title: 'Resumen económico',
              description: 'Ver el total del mes y el gasto por categoría',
              onTap: onSummary,
            ),
            const SizedBox(height: kPad),
            DailyChart(days: lastDaysSpending(store.all, now(), kChartDays)),
          ],
        );
      },
    );
  }
}

class _LastExpenseCard extends StatelessWidget {
  const _LastExpenseCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.primary,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}

class _AccessButton extends StatelessWidget {
  const _AccessButton({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $description',
      excludeSemantics: true,
      onTap: onTap,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
