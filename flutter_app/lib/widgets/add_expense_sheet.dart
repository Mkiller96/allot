import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseSheet extends StatefulWidget {
  final Expense? expense; // null = new
  const AddExpenseSheet({super.key, this.expense});
  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  String?  _catId;
  DateTime _date = DateTime.now();
  bool _saving   = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.expense!;
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _noteCtrl.text   = e.note ?? '';
      _catId           = e.categoryId;
      _date            = DateTime.tryParse(e.date) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_catId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona una categoría')));
      return;
    }
    setState(() => _saving = true);
    try {
      final ep     = context.read<ExpenseProvider>();
      final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));
      final dateStr = DateFormat('yyyy-MM-dd').format(_date);
      final note    = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();

      if (_isEdit) {
        await ep.updateExpense(widget.expense!.id, {
          'amount': amount, 'categoryId': _catId,
          'date': dateStr,  'note': note,
        });
      } else {
        await ep.addExpense({'amount': amount, 'category_id': _catId,
            'date': dateStr, 'note': note});
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<ExpenseProvider>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + kb),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),

            Text(_isEdit ? 'Editar gasto' : 'Nuevo gasto',
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),

            // Amount
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Importe (€)',
                prefixIcon: Icon(Icons.euro),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Número inválido';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Category
            DropdownButtonFormField<String>(
              value: _catId,
              decoration: const InputDecoration(
                  labelText: 'Categoría', prefixIcon: Icon(Icons.category_outlined)),
              items: ep.categories.map((c) => DropdownMenuItem(
                value: c.id,
                child: Row(children: [
                  Text(c.icon), const SizedBox(width: 8), Text(c.name),
                ]),
              )).toList(),
              onChanged: (v) => setState(() => _catId = v),
              validator: (v) => v == null ? 'Selecciona una categoría' : null,
            ),
            const SizedBox(height: 14),

            // Date
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Fecha', prefixIcon: Icon(Icons.calendar_today_outlined)),
                child: Text(DateFormat('dd/MM/yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 14),

            // Note
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLength: 120,
            ),
            const SizedBox(height: 20),

            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEdit ? 'Guardar cambios' : 'Añadir gasto',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
