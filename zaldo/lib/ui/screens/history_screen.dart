import 'package:flutter/material.dart';

import '../../domain/expense.dart';
import '../../domain/expense_filter.dart';
import '../../domain/format.dart';
import '../../state/expense_store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'detail_screen.dart';
import 'filter_screen.dart';

String describeFilter(ExpenseFilter f) {
  final parts = <String>[
    if (f.category != null) f.category!.label,
    if (f.from != null) 'desde ${formatShortDate(f.from!)}',
    if (f.to != null) 'hasta ${formatShortDate(f.to!)}',
  ];
  return parts.join(', ');
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.store, required this.now});
  final ExpenseStore store;
  final DateTime Function() now;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = store.visible;
        final filter = store.filter;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(kPad, 8, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: const Text(
                        'Historial',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Filtrar gastos',
                    iconSize: 28,
                    constraints: const BoxConstraints(
                      minWidth: kMinTouch,
                      minHeight: kMinTouch,
                    ),
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FilterScreen(store: store, now: now),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (filter.isActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(kPad, 8, kPad, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filtro activo: ${describeFilter(filter)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: store.clearFilter,
                          child: const Text('Limpiar filtros'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: EmptyState(
                          title: 'No hay gastos que mostrar',
                          detail: filter.isActive
                              ? 'Prueba con otros filtros o límpialos.'
                              : 'Cuando guardes un gasto aparecerá aquí.',
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(kPad),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _ExpenseTile(
                        expense: items[i],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              store: store,
                              expenseId: items[i].id,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense, required this.onTap});
  final Expense expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = expense.category;
    return Semantics(
      button: true,
      onTap: onTap,
      label:
          '${c.label}, ${spokenEuros(expense.amountCents)}, ${formatDate(expense.date)}'
          '${expense.description.isEmpty ? '' : ', ${expense.description}'}',
      hint: 'Abrir detalle',
      excludeSemantics: true,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(c.icon, color: AppColors.primary, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.label,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formatShortDate(expense.date),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatEuros(expense.amountCents),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
