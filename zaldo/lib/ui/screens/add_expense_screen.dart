import 'package:flutter/material.dart';

import '../../domain/amount_parser.dart';
import '../../domain/category.dart';
import '../../domain/format.dart';
import '../../state/expense_store.dart';
import '../theme.dart';
import '../widgets.dart';

String amountErrorText(AmountError e) => switch (e) {
  AmountError.empty => 'Escribe el importe. Por ejemplo: 4,50.',
  AmountError.invalid => 'El importe no es válido. Escribe un valor como 4,50.',
  AmountError.notPositive =>
    'El importe debe ser mayor que 0. Escribe un valor como 4,50.',
};

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, required this.store, required this.now});
  final ExpenseStore store;
  final DateTime Function() now;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amount = TextEditingController();
  final _description = TextEditingController();
  Category? _category;
  late DateTime _date;
  DraftValidation? _errors;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final n = widget.now();
    _date = DateTime(n.year, n.month, n.day);
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = widget.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year, today.month, today.day),
      helpText: 'Fecha del gasto',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final v = validateDraft(amountText: _amount.text, category: _category);
    setState(() => _errors = v);
    if (!v.isValid || _saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await widget.store.add(
      cents: v.cents!,
      category: _category!,
      date: _date,
      description: _description.text,
    );
    navigator.pop();
    showConfirmationOn(messenger, 'Gasto guardado');
  }

  @override
  Widget build(BuildContext context) {
    final amountError = _errors?.amountError;
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir gasto')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(kPad),
          children: [
            TextField(
              key: const Key('amount'),
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              onChanged: (_) {
                if (_errors?.amountError != null) {
                  setState(() => _errors = null);
                }
              },
              decoration: InputDecoration(
                labelText: 'Importe (€)',
                hintText: '0,00',
                error: amountError == null
                    ? null
                    : ErrorLine(amountErrorText(amountError)),
              ),
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
              onChanged: (c) => setState(() {
                _category = c;
                if (_errors?.categoryMissing ?? false) _errors = null;
              }),
            ),
            const SizedBox(height: 8),
            Text(
              '${Category.alimentacion.hint}: ${Category.alimentacion.label}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            if (_errors?.categoryMissing ?? false) ...[
              const SizedBox(height: 8),
              const ErrorLine('Elige una categoría.'),
            ],
            const SizedBox(height: 20),
            Text(
              'Fecha: ${formatDate(_date)}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _pickDate,
                child: const Text('Cambiar fecha'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('description'),
              controller: _description,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Guardando…' : 'Guardar gasto'),
            ),
            const SizedBox(height: kGap),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
