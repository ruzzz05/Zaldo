import 'package:flutter/material.dart';

import '../../domain/category.dart';
import '../../domain/expense_filter.dart';
import '../../domain/format.dart';
import '../../state/expense_store.dart';
import '../theme.dart';
import '../widgets.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key, required this.store, required this.now});
  final ExpenseStore store;
  final DateTime Function() now;

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  DateTime? _from;
  DateTime? _to;
  Category? _category;

  @override
  void initState() {
    super.initState();
    final f = widget.store.filter;
    _from = f.from;
    _to = f.to;
    _category = f.category;
  }

  Future<DateTime?> _pick(DateTime? current, String help) {
    final n = widget.now();
    return showDatePicker(
      context: context,
      initialDate: current ?? DateTime(n.year, n.month, n.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: help,
    );
  }

  void _apply() {
    widget.store.setFilter(
      ExpenseFilter(from: _from, to: _to, category: _category),
    );
    Navigator.of(context).pop();
  }

  void _clear() {
    widget.store.clearFilter();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filtrar gastos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(kPad),
          children: [
            _DateField(
              fieldKey: const Key('filter-from'),
              label: 'Desde',
              value: _from,
              onTap: () async {
                final d = await _pick(_from, 'Fecha inicial');
                if (d != null) setState(() => _from = d);
              },
              onClear: () => setState(() => _from = null),
            ),
            const SizedBox(height: kGap),
            _DateField(
              fieldKey: const Key('filter-to'),
              label: 'Hasta',
              value: _to,
              onTap: () async {
                final d = await _pick(_to, 'Fecha final');
                if (d != null) setState(() => _to = d);
              },
              onClear: () => setState(() => _to = null),
            ),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: const Text(
                'Categoría',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            CategoryWrap(
              selected: _category,
              onChanged: (c) =>
                  setState(() => _category = c == _category ? null : c),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toca de nuevo la categoría elegida para quitarla.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _apply,
              child: const Text('Aplicar filtros'),
            ),
            const SizedBox(height: kGap),
            OutlinedButton(
              onPressed: _clear,
              child: const Text('Limpiar filtros'),
            ),
            const SizedBox(height: kGap),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });
  final Key fieldKey;
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? 'Sin fecha' : formatShortDate(value!);
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label:
                '$label: ${value == null ? 'sin fecha' : formatDate(value!)}',
            hint: 'Elegir fecha',
            excludeSemantics: true,
            onTap: onTap,
            child: Material(
              color: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: AppColors.fieldBorder,
                  width: 1.5,
                ),
              ),
              child: InkWell(
                key: fieldKey,
                borderRadius: BorderRadius.circular(12),
                onTap: onTap,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          text,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (value != null)
          IconButton(
            tooltip: 'Quitar fecha $label',
            constraints: const BoxConstraints(
              minWidth: kMinTouch,
              minHeight: kMinTouch,
            ),
            icon: const Icon(Icons.close),
            onPressed: onClear,
          ),
      ],
    );
  }
}
