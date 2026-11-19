import 'package:flutter/material.dart';

import '../../domain/format.dart';
import '../../state/expense_store.dart';
import '../theme.dart';
import '../widgets.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.store, required this.expenseId});
  final ExpenseStore store;
  final String expenseId;

  Future<void> _confirmDelete(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar este gasto?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actionsOverflowDirection: VerticalDirection.down,
        actionsOverflowButtonSpacing: 8,
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar gasto'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await store.delete(expenseId);
    navigator.pop();
    showConfirmationOn(messenger, 'Gasto eliminado');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del gasto')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final e = store.byId(expenseId);
            if (e == null) {
              return const EmptyState(title: 'Este gasto ya no existe');
            }
            return ListView(
              padding: const EdgeInsets.all(kPad),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Row(
                          'Importe',
                          formatEuros(e.amountCents),
                          spoken: spokenEuros(e.amountCents),
                          big: true,
                        ),
                        _Row(
                          'Categoría',
                          e.category.label,
                          icon: e.category.icon,
                        ),
                        _Row('Fecha', formatDate(e.date)),
                        _Row(
                          'Descripción',
                          e.description.isEmpty
                              ? 'Sin descripción'
                              : e.description,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver al historial'),
                ),
                const SizedBox(height: kGap),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                  ),
                  onPressed: () => _confirmDelete(context),
                  child: const Text('Eliminar gasto'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
    this.label,
    this.value, {
    this.icon,
    this.big = false,
    this.spoken,
  });
  final String label;
  final String value;
  final IconData? icon;
  final bool big;
  final String? spoken;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Semantics(
        label: '$label: ${spoken ?? value}',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: big ? 30 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
